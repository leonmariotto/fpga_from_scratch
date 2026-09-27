"""FPGA bitstream programming runner."""

import subprocess
from pathlib import Path
from shlex import join

from loguru import logger

from logic_lab.targets import SynthTarget


class Programmer:
    """Program synthesized bitstreams using openFPGALoader."""

    def __init__(self, oss_cad_path: str | Path) -> None:
        oss_cad_bin = Path(oss_cad_path).expanduser().resolve() / "bin"
        self.openfpgaloader_path = oss_cad_bin / "openFPGALoader"

        # These options are intentionally fixed for now.
        self.program_options = ["-b", "tangconsole"]

    def run(self, target: SynthTarget) -> None:
        """Load a target's generated bitstream into the FPGA SRAM."""

        bitstream = target.project_path / "build" / f"{target.name}.fs"
        if not bitstream.is_file():
            raise FileNotFoundError(
                f"Bitstream does not exist for target '{target.name}': {bitstream}"
            )

        logger.info("Programming target [{}]", target.name)
        command = [
            str(self.openfpgaloader_path),
            *self.program_options,
            str(bitstream),
        ]
        logger.debug("Run from [{}]: {}", target.project_path, join(command))
        subprocess.run(command, cwd=target.project_path, check=True)
