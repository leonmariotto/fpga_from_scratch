YOSYS ?= yosys
NEXTPNR ?= nextpnr-himbaechel
GOWIN_PACK ?= gowin_pack
LOADER ?= openFPGALoader
IVERILOG ?= iverilog
VVP ?= vvp

BUILD := build
SYNTH := $(BUILD)/blinky-synth.json
PNR := $(BUILD)/blinky.json
BITSTREAM := $(BUILD)/blinky.fs
SCHEMATIC := $(BUILD)/blinky.svg
SIM := $(BUILD)/blinky.vvp

# Icarus is sufficient for these small RTL exercises. Consider Verilator for
# faster full-core simulation and SymbiYosys for formal checks as the CPU grows.

.DEFAULT_GOAL := all

.PHONY: all schematic sim program flash clean

all: $(BITSTREAM)

schematic: $(SCHEMATIC)

sim: $(SIM)
	$(VVP) $<

$(BUILD):
	mkdir -p $@

$(SYNTH): blinky.sv | $(BUILD)
	$(YOSYS) -p "read_verilog -sv $<; synth_gowin -top top -family gw5a -json $@"

$(SCHEMATIC): blinky.sv | $(BUILD)
	$(YOSYS) -p "read_verilog -sv $<; hierarchy -top top; proc; opt; show -format svg -prefix $(basename $@)"

$(SIM): blinky.sv tb_blinky.sv | $(BUILD)
	$(IVERILOG) -g2012 -s tb_blinky -o $@ $^

$(PNR): $(SYNTH) blinky.cst
	$(NEXTPNR) --device GW5AST-LV138PG484AC1/I0 \
		--json $(SYNTH) --write $@ --vopt cst=blinky.cst \
		--freq 50 --timing-allow-fail -r

$(BITSTREAM): $(PNR)
	$(GOWIN_PACK) --cpu_as_gpio -d GW5AST-138C -o $@ $<

program: $(BITSTREAM)
	$(LOADER) -b tangconsole $<

flash: $(BITSTREAM)
	$(LOADER) -b tangconsole -f $<

detect:
	$(LOADER) -b tangconsole --detect

clean:
	rm -rf $(BUILD)
