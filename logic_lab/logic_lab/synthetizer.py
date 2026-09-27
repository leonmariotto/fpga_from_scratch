"""OSS CAD Suite synthesis runner."""

import subprocess
from pathlib import Path
from shlex import join

from loguru import logger

from logic_lab.targets import SynthTarget


class Synthetizer:
    """Synthesize targets with fixed Gowin Tang Console options."""

    def __init__(self, oss_cad_path: str | Path) -> None:
        oss_cad_bin = Path(oss_cad_path).expanduser().resolve() / "bin"
        self.yosys_path = oss_cad_bin / "yosys"
        self.nextpnr_path = oss_cad_bin / "nextpnr-himbaechel"
        self.gowin_pack_path = oss_cad_bin / "gowin_pack"

        # These options are intentionally fixed for now.
        self.fpga_family = "gw5a"
        self.fpga_device = "GW5AST-LV138PG484AC1/I0"
        self.pack_device = "GW5AST-138C"
        self.frequency_mhz = 50
        self.generate_schematic = True
        self.yosys_options = ["-p"]
        self.nextpnr_options = ["--timing-allow-fail", "-r"]
        self.gowin_pack_options = ["--cpu_as_gpio"]

    def run(self, target: SynthTarget) -> None:
        """Run synthesis, place-and-route, packing, and schematic generation."""

        logger.info("Synthesizing target [{}]", target.name)
        build_path = target.project_path / "build"
        build_path.mkdir(parents=True, exist_ok=True)
        synth_json = build_path / f"{target.name}-synth.json"
        pnr_json = build_path / f"{target.name}.json"
        bitstream = build_path / f"{target.name}.fs"

        sources = " ".join(target.sources)
        synth_script = (
            f"read_verilog -sv {sources}; "
            f"synth_gowin -top {target.top} -family {self.fpga_family} "
            f"-json {synth_json}"
        )
        self._run(
            [str(self.yosys_path), *self.yosys_options, synth_script],
            target.project_path,
        )

        if self.generate_schematic:
            schematic_prefix = build_path / target.name
            schematic_script = (
                f"read_verilog -sv {sources}; hierarchy -top {target.top}; "
                "proc; opt; "
                f"show -format svg -stretch -width -colors 2 "
                f"-prefix {schematic_prefix}"
            )
            self._run(
                [str(self.yosys_path), *self.yosys_options, schematic_script],
                target.project_path,
            )

        self._run(
            [
                str(self.nextpnr_path),
                "--device",
                self.fpga_device,
                "--json",
                str(synth_json),
                "--write",
                str(pnr_json),
                "--vopt",
                f"cst={target.cst}",
                "--freq",
                str(self.frequency_mhz),
                *self.nextpnr_options,
            ],
            target.project_path,
        )
        self._run(
            [
                str(self.gowin_pack_path),
                *self.gowin_pack_options,
                "-d",
                self.pack_device,
                "-o",
                str(bitstream),
                str(pnr_json),
            ],
            target.project_path,
        )

    @staticmethod
    def _run(command: list[str], cwd: Path) -> None:
        logger.debug("Run from [{}]: {}", cwd, join(command))
        subprocess.run(command, cwd=cwd, check=True)
