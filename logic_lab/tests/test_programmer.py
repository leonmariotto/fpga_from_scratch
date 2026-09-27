from pathlib import Path
from subprocess import CompletedProcess

import pytest
from pytest import MonkeyPatch

from logic_lab.programmer import Programmer
from logic_lab.targets import SynthTarget


def test_programmer_runs_openfpgaloader(
    tmp_path: Path, monkeypatch: MonkeyPatch
) -> None:
    bitstream = tmp_path / "build" / "board.fs"
    bitstream.parent.mkdir()
    bitstream.touch()
    target = SynthTarget(
        name="board",
        sources=("board.sv",),
        top="board",
        cst="board.cst",
        project_path=tmp_path,
    )
    calls: list[tuple[list[str], Path, bool]] = []

    def record_run(
        command: list[str], *, cwd: Path, check: bool
    ) -> CompletedProcess[str]:
        calls.append((command, cwd, check))
        return CompletedProcess(command, 0)

    monkeypatch.setattr("logic_lab.programmer.subprocess.run", record_run)
    Programmer("/opt/oss-cad-suite").run(target)

    assert calls == [
        (
            [
                "/opt/oss-cad-suite/bin/openFPGALoader",
                "-b",
                "tangconsole",
                str(bitstream),
            ],
            tmp_path,
            True,
        )
    ]


def test_programmer_requires_existing_bitstream(tmp_path: Path) -> None:
    target = SynthTarget(
        name="board",
        sources=("board.sv",),
        top="board",
        cst="board.cst",
        project_path=tmp_path,
    )

    with pytest.raises(FileNotFoundError, match="Bitstream does not exist"):
        Programmer("/opt/oss-cad-suite").run(target)
