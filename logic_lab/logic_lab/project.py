"""Validated LogicLab project configuration."""

from collections.abc import Mapping, Sequence
from dataclasses import dataclass
from pathlib import Path
from typing import Any, cast

from logic_lab.yaml_parser import YamlParser, YamlParserError


class LogicLabProjectError(Exception):
    """Raised when a LogicLab project definition is invalid."""


@dataclass(frozen=True)
class SynthTarget:
    """A validated synthesis target."""

    name: str
    sources: tuple[str, ...]
    top: str
    cst: str


@dataclass(frozen=True)
class SimTarget:
    """A validated simulation target."""

    name: str
    sources: tuple[str, ...]


class LogicLabProject:
    """Load and validate the ``logiclab.yaml`` for a project directory."""

    def __init__(self, project_path: str | Path) -> None:
        self.project_path = Path(project_path).resolve()
        if not self.project_path.is_dir():
            raise LogicLabProjectError(
                f"Project path is not a directory: {self.project_path}"
            )

        parser = YamlParser()
        config_path = self.project_path / "logiclab.yaml"
        try:
            parser.parse(str(config_path))
        except YamlParserError as err:
            raise LogicLabProjectError(
                f"Unable to load project configuration: {config_path}"
            ) from err

        self.synth_targets = self._parse_synth_targets(parser.data)
        self.sim_targets = self._parse_sim_targets(parser.data)

    def show_off(self) -> dict[str, list[str]]:
        """Return the synthesis and simulation targets available to run."""

        return {
            "synth_targets": list(self.synth_targets),
            "sim_targets": list(self.sim_targets),
        }

    def run_synth(self, targets: list[str]) -> list[SynthTarget]:
        """Select synthesis targets, or every synthesis target for an empty list."""

        return self._select_targets(targets, self.synth_targets, "synthesis")

    def run_sim(self, targets: list[str]) -> list[SimTarget]:
        """Select simulation targets, or every simulation target for an empty list."""

        return self._select_targets(targets, self.sim_targets, "simulation")

    @classmethod
    def _parse_synth_targets(
        cls, data: Mapping[str, Any]
    ) -> dict[str, SynthTarget]:
        raw_targets = cls._target_list(data, "synth_targets")
        targets: dict[str, SynthTarget] = {}
        for index, raw_target in enumerate(raw_targets):
            target = cls._target_mapping(raw_target, "synth_targets", index)
            name = cls._required_string(target, "name", "synth_targets", index)
            cls._ensure_unique(name, targets, "synthesis")
            targets[name] = SynthTarget(
                name=name,
                sources=cls._sources(target, "synth_targets", index),
                top=cls._required_string(target, "top", "synth_targets", index),
                cst=cls._required_string(target, "cst", "synth_targets", index),
            )
        return targets

    @classmethod
    def _parse_sim_targets(cls, data: Mapping[str, Any]) -> dict[str, SimTarget]:
        raw_targets = cls._target_list(data, "sim_targets")
        targets: dict[str, SimTarget] = {}
        for index, raw_target in enumerate(raw_targets):
            target = cls._target_mapping(raw_target, "sim_targets", index)
            name = cls._required_string(target, "name", "sim_targets", index)
            cls._ensure_unique(name, targets, "simulation")
            targets[name] = SimTarget(
                name=name,
                sources=cls._sources(target, "sim_targets", index),
            )
        return targets

    @staticmethod
    def _target_list(data: Mapping[str, Any], key: str) -> Sequence[Any]:
        value = data.get(key)
        if not isinstance(value, list):
            raise LogicLabProjectError(f"'{key}' must be a list")
        return cast(list[Any], value)

    @staticmethod
    def _target_mapping(value: Any, section: str, index: int) -> Mapping[str, Any]:
        if not isinstance(value, Mapping):
            raise LogicLabProjectError(f"'{section}[{index}]' must be a mapping")
        return cast(Mapping[str, Any], value)

    @staticmethod
    def _required_string(
        target: Mapping[str, Any], key: str, section: str, index: int
    ) -> str:
        value = target.get(key)
        if not isinstance(value, str) or not value.strip():
            raise LogicLabProjectError(
                f"'{section}[{index}].{key}' must be a non-empty string"
            )
        return value

    @classmethod
    def _sources(
        cls, target: Mapping[str, Any], section: str, index: int
    ) -> tuple[str, ...]:
        sources = target.get("sources")
        if not isinstance(sources, list) or not sources:
            raise LogicLabProjectError(
                f"'{section}[{index}].sources' must be a non-empty list"
            )
        parsed_sources: list[str] = []
        for source_index, source in enumerate(cast(list[Any], sources)):
            if not isinstance(source, str) or not source.strip():
                raise LogicLabProjectError(
                    f"'{section}[{index}].sources[{source_index}]' must be "
                    "a non-empty string"
                )
            parsed_sources.append(source)
        return tuple(parsed_sources)

    @staticmethod
    def _ensure_unique(name: str, targets: Mapping[str, Any], kind: str) -> None:
        if name in targets:
            raise LogicLabProjectError(f"Duplicate {kind} target name: {name}")

    @staticmethod
    def _select_targets[T](
        requested: list[str], available: Mapping[str, T], kind: str
    ) -> list[T]:
        names = requested or list(available)
        unknown = [name for name in names if name not in available]
        if unknown:
            raise LogicLabProjectError(
                f"Unknown {kind} target(s): {', '.join(unknown)}"
            )
        return [available[name] for name in names]
