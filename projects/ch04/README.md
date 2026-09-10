# Chapter 04 examples

Theses circuit are not intended to be run on board, that's why not `top` module 
is present. This mean :
- `make` will fail.
- `NAME=XXX make schematic` will generate schematic of module XXX in file 
XXX.sv.
- `NAME=XXX make sim` will run testbench tb_XXX.sv for file XXX.sv, and will
generate a waveform in build/XXX.vcd.

## Circuits

### Inverter

This project implements the complete inverter truth table:

| `in` | `out` |
|---:|---:|
| 0 | 1 |
| 1 | 0 |

### Gates

This test various boolean operation on 4 pins inputs. The testbench test every 
possible inputs.
