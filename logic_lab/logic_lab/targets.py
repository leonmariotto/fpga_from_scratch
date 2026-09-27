"""Validated LogicLab target definitions."""

from dataclasses import dataclass, field
from pathlib import Path


@dataclass(frozen=True)
class SynthTarget:
    """A validated synthesis target."""

    name: str
    sources: tuple[str, ...]
    top: str
    cst: str
    project_path: Path = field(default_factory=Path.cwd)


@dataclass(frozen=True)
class SimTarget:
    """A validated simulation target."""

    name: str
    sources: tuple[str, ...]
    project_path: Path = field(default_factory=Path.cwd)
