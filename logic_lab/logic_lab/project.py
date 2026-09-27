"""Validated LogicLab project configuration."""

from collections.abc import Mapping, Sequence
from pathlib import Path
from typing import Any, cast

from logic_lab.programmer import Programmer
from logic_lab.simulator import Simulator
from logic_lab.synthetizer import Synthetizer
from logic_lab.targets import SimTarget, SynthTarget
from logic_lab.yaml_parser import YamlParser, YamlParserError


class LogicLabProjectError(Exception):
    """Raised when a LogicLab project definition is invalid."""


class LogicLabProject:
    """Load and validate the ``logiclab.yml`` for a project directory."""

    def __init__(
        self,
        project_path: str | Path,
        synthetizer: Synthetizer,
        simulator: Simulator,
        programmer: Programmer,
    ) -> None:
        self.project_path = Path(project_path).resolve()
        self.synthetizer = synthetizer
        self.simulator = simulator
        self.programmer = programmer
        if not self.project_path.is_dir():
            raise LogicLabProjectError(
                f"Project path is not a directory: {self.project_path}"
            )

        parser = YamlParser()
        config_path = self.project_path / "logiclab.yml"
        try:
            parser.parse(str(config_path))
        except YamlParserError as err:
            raise LogicLabProjectError(
                f"Unable to load project configuration: {config_path}"
            ) from err

        self.synth_targets = self._parse_synth_targets(parser.data)
        self.sim_targets = self._parse_sim_targets(parser.data)

    def show_off(self) -> dict[str, list[str]]:
        """Print project and target details, then return the available names."""

        available = {
            "synth_targets": list(self.synth_targets),
            "sim_targets": list(self.sim_targets),
        }
        print(f"LogicLab project: {self.project_path}")
        print("Synthesis targets:")
        if not self.synth_targets:
            print("  (none)")
        for target in self.synth_targets.values():
            print(f"  - {target.name}")
            print(f"    top: {target.top}")
            print(f"    cst: {target.cst}")
            print("    sources:")
            for source in target.sources:
                print(f"      - {source}")

        print("Simulation targets:")
        if not self.sim_targets:
            print("  (none)")
        for target in self.sim_targets.values():
            print(f"  - {target.name}")
            print("    sources:")
            for source in target.sources:
                print(f"      - {source}")
        return available

    def run_synth(self, targets: list[str]) -> list[SynthTarget]:
        """Run selected synthesis targets using the injected synthetizer."""

        selected = self._select_targets(targets, self.synth_targets, "synthesis")
        for target in selected:
            self.synthetizer.run(target)
        return selected

    def run_sim(self, targets: list[str]) -> list[SimTarget]:
        """Run selected simulation targets using the injected simulator."""

        selected = self._select_targets(targets, self.sim_targets, "simulation")
        for target in selected:
            self.simulator.run(target)
        return selected

    def run_program(self, target_name: str | None) -> SynthTarget:
        """Program exactly one synthesis target's generated bitstream."""

        if target_name is None:
            if len(self.synth_targets) != 1:
                raise LogicLabProjectError(
                    "A synthesis target must be selected with -t/--target when "
                    "the project does not contain exactly one synthesis target"
                )
            target = next(iter(self.synth_targets.values()))
        else:
            selected = self._select_targets(
                [target_name], self.synth_targets, "synthesis"
            )
            target = selected[0]

        self.programmer.run(target)
        return target

    def _parse_synth_targets(self, data: Mapping[str, Any]) -> dict[str, SynthTarget]:
        raw_targets = self._target_list(data, "synth_targets")
        targets: dict[str, SynthTarget] = {}
        for index, raw_target in enumerate(raw_targets):
            target = self._target_mapping(raw_target, "synth_targets", index)
            name = self._required_string(target, "name", "synth_targets", index)
            self._ensure_unique(name, targets, "synthesis")
            targets[name] = SynthTarget(
                name=name,
                sources=self._sources(target, "synth_targets", index),
                top=self._required_string(target, "top", "synth_targets", index),
                cst=self._required_string(target, "cst", "synth_targets", index),
                project_path=self.project_path,
            )
        return targets

    def _parse_sim_targets(self, data: Mapping[str, Any]) -> dict[str, SimTarget]:
        raw_targets = self._target_list(data, "sim_targets")
        targets: dict[str, SimTarget] = {}
        for index, raw_target in enumerate(raw_targets):
            target = self._target_mapping(raw_target, "sim_targets", index)
            name = self._required_string(target, "name", "sim_targets", index)
            self._ensure_unique(name, targets, "simulation")
            targets[name] = SimTarget(
                name=name,
                sources=self._sources(target, "sim_targets", index),
                project_path=self.project_path,
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
