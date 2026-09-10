# Inverter

This project implements the complete inverter truth table:

| `in` | `out` |
|---:|---:|
| 0 | 1 |
| 1 | 0 |

## Pins

Use three pins on the `PMOD0` header:

- PMOD0 pin 11: `in` (FPGA `V18`). Its pull-up makes an open input read `1`.
- PMOD0 pin 12: `out` (FPGA `V19`).
- PMOD0 pin 3 or 4: `GND`. Fixed power pins do not appear in `inverter.cst`.

Measure `out` relative to `GND`: leaving `in` open produces about 0 V; connecting
`in` to `GND` produces about 3.3 V. Never connect a PMOD pin to more than 3.3 V.

Run `make sim` to test both input values, or `make` to build the bitstream.

## Physical test

1. Turn the board off and connect a jumper wire to PMOD0 pin 11 (`in`). Leave
   its other end disconnected for now.
2. Turn the board on and load the inverter with `make program`. Use `make flash`
   instead if it must remain loaded after power-off or reconfiguration.
3. Set a multimeter to DC volts. Keep its black probe on PMOD0 pin 3 or 4
   (`GND`) and touch its red probe to PMOD0 pin 12 (`out`).
4. Leave the pin 11 jumper disconnected. The pull-up makes `in = 1`, so pin 12
   should measure about 0 V.
5. Touch the free end of the pin 11 jumper to PMOD0 pin 3 or 4. This makes
   `in = 0`, so pin 12 should measure about 3.3 V.
6. Remove the jumper from ground. Pin 12 should return to about 0 V.

Do not connect pin 11 or pin 12 to 5 V, and do not connect pin 12 directly to
ground or 3.3 V. The `CFG` button and RGB LED only show configuration activity;
they are not part of this inverter test.
