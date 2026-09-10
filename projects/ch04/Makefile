YOSYS ?= yosys
NEXTPNR ?= nextpnr-himbaechel
GOWIN_PACK ?= gowin_pack
LOADER ?= openFPGALoader
IVERILOG ?= iverilog
VVP ?= vvp

NAME ?= inverter

BUILD := build
SYNTH := $(BUILD)/$(NAME)-synth.json
PNR := $(BUILD)/$(NAME).json
BITSTREAM := $(BUILD)/$(NAME).fs
SCHEMATIC := $(BUILD)/$(NAME).svg
FSM_KISS2 := $(BUILD)/$(NAME).kiss2
SIM := $(BUILD)/$(NAME).vvp

# Icarus is sufficient for these small RTL exercises. Consider Verilator for
# faster full-core simulation and SymbiYosys for formal checks as the CPU grows.

.DEFAULT_GOAL := all

.PHONY: all schematic sim program flash clean

all: $(BITSTREAM)

schematic: $(SCHEMATIC)

sim: $(SIM)
	$(VVP) $<

fsm_info:
	$(YOSYS) -p "\
    	read_verilog -sv $(NAME).sv;\
    	hierarchy -top $(NAME);\
    	proc;\
    	opt -nosdff -nodffe;\
    	fsm -nomap -norecode\
  	"

# TODO LMA: no tool to parse kiss2 fsm and output a clean svg? do it then.
fsm_export: $(FSM_KISS2)

$(FSM_KISS2): $(NAME).sv | $(BUILD)
	$(YOSYS) -p "\
    	read_verilog -sv $(NAME).sv;\
    	hierarchy -top $(NAME);\
    	proc;\
    	opt -nosdff -nodffe;\
    	fsm -nomap -norecode;\
    	fsm_export -o build/$(NAME).kiss2\
  "

$(BUILD):
	mkdir -p $@

$(SYNTH): $(NAME).sv | $(BUILD)
	$(YOSYS) -p "read_verilog -sv $<; synth_gowin -top top -family gw5a -json $@"

$(SCHEMATIC): $(NAME).sv | $(BUILD)
	$(YOSYS) -p "read_verilog -sv $<; hierarchy -top $(NAME); proc; opt; show -format svg -stretch -width -colors 2 -prefix $(basename $@)"

$(SIM): $(NAME).sv tb_$(NAME).sv | $(BUILD)
	$(IVERILOG) -g2012 -s tb_$(NAME) -o $@ $^

$(PNR): $(SYNTH) $(NAME).cst
	$(NEXTPNR) --device GW5AST-LV138PG484AC1/I0 \
		--json $(SYNTH) --write $@ --vopt cst=$(NAME).cst \
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
