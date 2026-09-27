"""OSS CAD Suite simulation runner."""

import subprocess
from pathlib import Path

from logic_lab.targets import SimTarget


class Simulator:
    """Compile and run SystemVerilog simulations with fixed Icarus options."""

    def __init__(self, oss_cad_path: str | Path) -> None:
        oss_cad_bin = Path(oss_cad_path).expanduser().resolve() / "bin"
        self.iverilog_path = oss_cad_bin / "iverilog"
        self.vvp_path = oss_cad_bin / "vvp"

        # These options are intentionally fixed for now.
        self.iverilog_options = ["-g2012"]
        self.vvp_options: list[str] = []

    def run(self, target: SimTarget) -> None:
        """Compile and execute one simulation target."""

        build_path = target.project_path / "build"
        build_path.mkdir(parents=True, exist_ok=True)
        simulation = build_path / f"{target.name}.vvp"

        self._run(
            [
                str(self.iverilog_path),
                *self.iverilog_options,
                "-s",
                target.name,
                "-o",
                str(simulation),
                *target.sources,
            ],
            target.project_path,
        )
        self._run(
            [str(self.vvp_path), *self.vvp_options, str(simulation)],
            target.project_path,
        )

    @staticmethod
    def _run(command: list[str], cwd: Path) -> None:
        subprocess.run(command, cwd=cwd, check=True)
