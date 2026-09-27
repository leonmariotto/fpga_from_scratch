from pathlib import Path

from click.testing import CliRunner
from pytest import MonkeyPatch

from logic_lab.logic_lab import logic_lab


def test_cli_requires_oss_cad_path() -> None:
    runner = CliRunner()

    result = runner.invoke(logic_lab, env={"OSS_CAD_PATH": ""})

    assert result.exit_code == 1
    assert "OSS_CAD_PATH environment variable is not set" in result.output


def test_cli_uses_current_directory_by_default(
    tmp_path: Path, monkeypatch: MonkeyPatch
) -> None:
    runner = CliRunner()
    monkeypatch.chdir(tmp_path)

    result = runner.invoke(logic_lab, env={"OSS_CAD_PATH": "/opt/oss-cad-suite"})

    assert result.exit_code == 0
    assert "Project: ." in result.output


def test_cli_accepts_short_project_path_option(tmp_path: Path) -> None:
    runner = CliRunner()

    result = runner.invoke(
        logic_lab,
        ["-p", str(tmp_path)],
        env={"OSS_CAD_PATH": "/opt/oss-cad-suite"},
    )

    assert result.exit_code == 0
    assert f"Project: {tmp_path}" in result.output
