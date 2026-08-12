# FPGA project

The goal is to create an educational RISCV core from scratch following the book
*Digital design and computer architecture: RISCV edition* by Sarah L Harris and David Harris on a
Tang 138K console.

## Hardware

My Tang 138K contains :
- GOWIN GW5AST-LV138PG484AC1/I0
- 2x Winbond W9825G6KH-6: small SDR SRAM of 32KB each. Easier access than DDR3.
- 2x SK hynix H5TQ4G63EFR-RDC: larger SRAM of 1GB each, DDR3-1866-class RDC speed grade

## Toolchain

Fully open-source toolchain :
- yosys: parse verilog.
- nextpnr-himbaechel: routing.
- apycula: generate the bitstream.
- openFPGALoader: load the bitstream.
Install the [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build/releases),
which includes Yosys, nextpnr-himbaechel, Apicula, and openFPGALoader into
`./oss-cad-suite` folder.
Then, each time, to use it, source the environment file :
```
. ./oss-cad-suite/environment
```

Install udev rules once :
```
sudo curl https://raw.githubusercontent.com/trabucayre/openFPGALoader/refs/heads/master/70-openfpgaloader.rules -o /etc/udev/rules.d/70-openfpgaloader.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```
Then, with "MCU" USB-C connected (not "FPGA"), the board should be detected by openFPGALoader: `openFPGALoader -b tangconsole --detect`.

## Course notes

Check `courses` folder for my notes following the book *Digital design and computer architecture:
RISCV edition* by Sarah L Harris and David Harris.
Each chapter should contain markdown notes, and exercices made.
The markdown should build with mdbook in CI and produce a static page / pdf. !TODO!
