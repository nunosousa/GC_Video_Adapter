# Directories
SOURCEPATH = ./source/
TESTBENCHPATH = ./testbench/
SIMULATIONPATH = ./simulation/
VHDLEX = .vhd

# GHDL configuration
GHDL_CMD = ghdl
GHDL_FLAGS =
GHDL_SIM_OPT =

.PHONY: clean

build:
	@$(GHDL_CMD) -i $(GHDL_FLAGS) --workdir=simulation --work=work $(TESTBENCHPATH) $(FILES)
	@$(GHDL_CMD) -m  $(GHDL_FLAGS) --workdir=simulation --work=work $(TESTBENCHFILE)

run:
	simulation/$(TESTBENCHFILE) $(GHDL_SIM_OPT) --vcd=$(SIMDIR)/$(TESTBENCHFILE).vcd




gc_dv_top_level_tb01: gc_dv_top_level
	
gc_dv_top_level: gc_dv_decode gc_dv_422_to_444 gc_dv_YCbCr_to_RGB gc_dv_video_DAC
	
gc_dv_video_DAC_tb01: gc_dv_video_DAC
	
gc_dv_video_DAC:
	
gc_dv_YCbCr_to_RGB_tb01: gc_dv_YCbCr_to_RGB
	
gc_dv_YCbCr_to_RGB:
	
gc_dv_422_to_444_tb01: gc_dv_422_to_444
	
gc_dv_422_to_444:
	$(GHDL_CMD) -a $(GHDL_FLAGS) --workdir=$(SIMULATIONPATH) $(SOURCEPATH)$@$(VHDLEX)
gc_dv_decode_tb01: gc_dv_decode
	$(GHDL_CMD) -a $(GHDL_FLAGS) $(TESTBENCHPATH)$@$(VHDLEX)
gc_dv_decode_tb02: gc_dv_decode
	$(GHDL_CMD) -a $(GHDL_FLAGS) $(TESTBENCHPATH)$@$(VHDLEX)
gc_dv_decode_tb03: gc_dv_decode
	$(GHDL_CMD) -a $(GHDL_FLAGS) $(TESTBENCHPATH)$@$(VHDLEX)
	$(GHDL_CMD) -e gc_dv_top_level_tb;
gc_dv_decode: 
	$(GHDL_CMD) -a $(GHDL_FLAGS) $(SOURCEPATH)$@$(VHDLEX)
clean:
	@$(GHDL_CMD) --remove
