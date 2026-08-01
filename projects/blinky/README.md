# Blinky

This small project blinks the green LED built into the Tang Console dock. It is
intended to show each step of the open-source FPGA toolchain without hiding the
commands behind a framework.

The design uses the dock's 50 MHz clock on pin `V22` and its active-low green
LED on pin `V13`. These pin assignments come from the official DDR example in
`../ext/TangMega-138K-example/ddr_memory/ddr_memory_test_uart/`.

## Build and load

Connect the Tang Console over USB, then run:

```sh
make
make program
```

`make` runs the tools in order:

1. Yosys synthesizes `blinky.v` into a JSON netlist.
2. nextpnr-himbaechel places and routes it using `blinky.cst`.
3. Apicula's `gowin_pack` creates `build/blinky.fs`.

`make program` loads the bitstream into FPGA SRAM for quick testing. It is lost
when power is removed. Once the design works, store it persistently with:

```sh
make flash
```

Remove generated files with `make clean`.
