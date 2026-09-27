import subprocess
from pathlib import Path

from pytest import MonkeyPatch

from logic_lab.simulator import Simulator
from logic_lab.targets import SimTarget


def test_simulator_calls_iverilog_and_vvp(
    tmp_path: Path, monkeypatch: MonkeyPatch
) -> None:
    commands: list[list[str]] = []

    def record_run(command: list[str], *, cwd: Path, check: bool) -> None:
        assert cwd == tmp_path
        assert check is True
        commands.append(command)

    monkeypatch.setattr(subprocess, "run", record_run)
    target = SimTarget(
        "tb_alu", ("single_cycle.sv", "tests/tb_alu.sv"), tmp_path
    )
    simulator = Simulator(tmp_path / "oss-cad-suite")

    simulator.run(target)

    assert [Path(command[0]).name for command in commands] == ["iverilog", "vvp"]
    assert commands[0][1:4] == ["-g2012", "-s", "tb_alu"]
    assert commands[0][-2:] == ["single_cycle.sv", "tests/tb_alu.sv"]
    assert commands[1][-1].endswith("build/tb_alu.vvp")
