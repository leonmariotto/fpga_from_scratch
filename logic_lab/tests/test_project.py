from pathlib import Path

import pytest

from logic_lab.programmer import Programmer
from logic_lab.project import LogicLabProject, LogicLabProjectError
from logic_lab.simulator import Simulator
from logic_lab.synthetizer import Synthetizer
from logic_lab.targets import SimTarget, SynthTarget

VALID_CONFIG = """\
synth_targets:
  - name: cpu
    sources:
      - single_cycle.sv
    top: single_cycle
    cst: board.cst
sim_targets:
  - name: extend
    sources:
      - single_cycle.sv
      - tests/tb_extend.sv
  - name: alu
    sources:
      - single_cycle.sv
      - tests/tb_alu.sv
"""


class RecordingSynthetizer(Synthetizer):
    def __init__(self, oss_cad_path: Path) -> None:
        super().__init__(oss_cad_path)
        self.targets: list[SynthTarget] = []

    def run(self, target: SynthTarget) -> None:
        self.targets.append(target)


class RecordingSimulator(Simulator):
    def __init__(self, oss_cad_path: Path) -> None:
        super().__init__(oss_cad_path)
        self.targets: list[SimTarget] = []

    def run(self, target: SimTarget) -> None:
        self.targets.append(target)


class RecordingProgrammer(Programmer):
    def __init__(self, oss_cad_path: Path) -> None:
        super().__init__(oss_cad_path)
        self.targets: list[SynthTarget] = []

    def run(self, target: SynthTarget) -> None:
        self.targets.append(target)


def make_project(tmp_path: Path, config: str = VALID_CONFIG) -> LogicLabProject:
    (tmp_path / "logiclab.yml").write_text(config, encoding="utf-8")
    return LogicLabProject(
        tmp_path,
        RecordingSynthetizer(tmp_path),
        RecordingSimulator(tmp_path),
        RecordingProgrammer(tmp_path),
    )


def test_project_lists_and_selects_targets(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    project = make_project(tmp_path)

    assert project.show_off() == {
        "synth_targets": ["cpu"],
        "sim_targets": ["extend", "alu"],
    }
    output = capsys.readouterr().out
    assert f"LogicLab project: {tmp_path}" in output
    assert "  - cpu" in output
    assert "    top: single_cycle" in output
    assert "    cst: board.cst" in output
    assert "      - tests/tb_extend.sv" in output
    assert [target.name for target in project.run_synth([])] == ["cpu"]
    assert [target.name for target in project.run_sim([])] == ["extend", "alu"]
    assert [target.name for target in project.run_sim(["alu"])] == ["alu"]


@pytest.mark.parametrize("missing_field", ["top", "cst"])
def test_synth_target_requires_top_and_cst(tmp_path: Path, missing_field: str) -> None:
    config = VALID_CONFIG.replace(
        f"    {missing_field}: "
        + ("single_cycle" if missing_field == "top" else "board.cst")
        + "\n",
        "",
    )

    with pytest.raises(LogicLabProjectError, match=missing_field):
        make_project(tmp_path, config)


def test_sim_target_does_not_require_top(tmp_path: Path) -> None:
    project = make_project(tmp_path)
    assert project.sim_targets["extend"].sources == (
        "single_cycle.sv",
        "tests/tb_extend.sv",
    )


def test_unknown_requested_target_is_rejected(tmp_path: Path) -> None:
    project = make_project(tmp_path)
    with pytest.raises(LogicLabProjectError, match="Unknown simulation target"):
        project.run_sim(["missing"])


def test_program_uses_only_synth_target_by_default(tmp_path: Path) -> None:
    project = make_project(tmp_path)

    assert project.run_program(None).name == "cpu"


def test_program_requires_selection_for_multiple_synth_targets(tmp_path: Path) -> None:
    second_target = """\
  - name: board
    sources:
      - board.sv
    top: board
    cst: board.cst
"""
    config = VALID_CONFIG.replace("sim_targets:", second_target + "sim_targets:")
    project = make_project(tmp_path, config)

    with pytest.raises(LogicLabProjectError, match="must be selected"):
        project.run_program(None)

    assert project.run_program("board").name == "board"
