import subprocess
from pathlib import Path

from pytest import MonkeyPatch

from logic_lab.synthetizer import Synthetizer
from logic_lab.targets import SynthTarget


def test_synthetizer_calls_oss_cad_tools(
    tmp_path: Path, monkeypatch: MonkeyPatch
) -> None:
    commands: list[list[str]] = []

    def record_run(command: list[str], *, cwd: Path, check: bool) -> None:
        assert cwd == tmp_path
        assert check is True
        commands.append(command)

    monkeypatch.setattr(subprocess, "run", record_run)
    target = SynthTarget(
        "cpu", ("single_cycle.sv",), "single_cycle", "board.cst", tmp_path
    )
    synthetizer = Synthetizer(tmp_path / "oss-cad-suite")

    synthetizer.run(target)

    assert [Path(command[0]).name for command in commands] == [
        "yosys",
        "yosys",
        "nextpnr-himbaechel",
        "gowin_pack",
    ]
    assert "synth_gowin -top single_cycle -family gw5a" in commands[0][2]
    assert "--device" in commands[2]
    assert "cst=board.cst" in commands[2]
    assert (tmp_path / "build").is_dir()
