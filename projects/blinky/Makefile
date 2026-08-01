YOSYS ?= yosys
NEXTPNR ?= nextpnr-himbaechel
GOWIN_PACK ?= gowin_pack
LOADER ?= openFPGALoader

BUILD := build
SYNTH := $(BUILD)/blinky-synth.json
PNR := $(BUILD)/blinky.json
BITSTREAM := $(BUILD)/blinky.fs

.DEFAULT_GOAL := all

.PHONY: all program flash clean

all: $(BITSTREAM)

$(BUILD):
	mkdir -p $@

$(SYNTH): blinky.v | $(BUILD)
	$(YOSYS) -p "read_verilog $<; synth_gowin -top top -family gw5a -json $@"

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
