from pathlib import Path

from click.testing import CliRunner
from pytest import MonkeyPatch

from logic_lab.logic_lab import logic_lab
from logic_lab.programmer import Programmer
from logic_lab.simulator import Simulator
from logic_lab.synthetizer import Synthetizer
from logic_lab.targets import SimTarget, SynthTarget

CONFIG = """\
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


def write_config(project_path: Path) -> None:
    (project_path / "logiclab.yml").write_text(CONFIG, encoding="utf-8")


def test_cli_requires_oss_cad_path(tmp_path: Path) -> None:
    write_config(tmp_path)
    runner = CliRunner()

    result = runner.invoke(
        logic_lab, ["-p", str(tmp_path), "show"], env={"OSS_CAD_PATH": ""}
    )

    assert result.exit_code == 1
    assert "OSS_CAD_PATH environment variable is not set" in result.output


def test_show_uses_current_directory_by_default(
    tmp_path: Path, monkeypatch: MonkeyPatch
) -> None:
    write_config(tmp_path)
    runner = CliRunner()
    monkeypatch.chdir(tmp_path)

    result = runner.invoke(
        logic_lab, ["show"], env={"OSS_CAD_PATH": "/opt/oss-cad-suite"}
    )

    assert result.exit_code == 0
    assert f"LogicLab project: {tmp_path}" in result.output
    assert "Synthesis targets:" in result.output
    assert "Simulation targets:" in result.output


def test_synth_accepts_multiple_targets(
    tmp_path: Path, monkeypatch: MonkeyPatch
) -> None:
    write_config(tmp_path)
    selected: list[str] = []

    def record_run(self: Synthetizer, target: SynthTarget) -> None:
        selected.append(target.name)

    monkeypatch.setattr(Synthetizer, "run", record_run)
    result = CliRunner().invoke(
        logic_lab,
        ["-p", str(tmp_path), "synth", "-t", "cpu"],
        env={"OSS_CAD_PATH": "/opt/oss-cad-suite"},
    )

    assert result.exit_code == 0
    assert selected == ["cpu"]


def test_sim_accepts_repeated_target_options(
    tmp_path: Path, monkeypatch: MonkeyPatch
) -> None:
    write_config(tmp_path)
    selected: list[str] = []

    def record_run(self: Simulator, target: SimTarget) -> None:
        selected.append(target.name)

    monkeypatch.setattr(Simulator, "run", record_run)
    result = CliRunner().invoke(
        logic_lab,
        ["-p", str(tmp_path), "sim", "--target", "alu", "-t", "extend"],
        env={"OSS_CAD_PATH": "/opt/oss-cad-suite"},
    )

    assert result.exit_code == 0
    assert selected == ["alu", "extend"]


def test_program_accepts_target(tmp_path: Path, monkeypatch: MonkeyPatch) -> None:
    write_config(tmp_path)
    selected: list[str] = []

    def record_run(self: Programmer, target: SynthTarget) -> None:
        selected.append(target.name)

    monkeypatch.setattr(Programmer, "run", record_run)
    result = CliRunner().invoke(
        logic_lab,
        ["-p", str(tmp_path), "program", "-t", "cpu"],
        env={"OSS_CAD_PATH": "/opt/oss-cad-suite"},
    )

    assert result.exit_code == 0
    assert selected == ["cpu"]
