# Directories
SOURCEPATH = ./source/
TESTBENCHPATH = ./testbench/
SIMULATIONPATH = ./simulation/
VHDLEX = .vhd

# GHDL configuration
GHDL_CMD = ghdl
GHDL_AFLAGS =
GHDL_EFLAGS =
GHDL_SFLAGS =

.PHONY: clean

all: gc_dv_top_level_tb01 gc_dv_top_level_tb02 gc_dv_video_DAC_tb01 gc_dv_YCbCr_to_RGB_tb01 gc_dv_422_to_444_tb01 gc_dv_decode_tb01 gc_dv_decode_tb02 gc_dv_decode_tb03

GC_DV_TOP_LEVEL_TB = gc_dv_top_level_tb
gc_dv_top_level_tb01: gc_dv_top_level
	$(GHDL_CMD) -a $(GHDL_AFLAGS) $(TESTBENCHPATH)$@$(VHDLEX)
	$(GHDL_CMD) -e $(GHDL_EFLAGS) $(GC_DV_TOP_LEVEL_TB)
	$(GHDL_CMD) -r $(GHDL_RFLAGS) $(GC_DV_TOP_LEVEL_TB) --vcd=$(SIMULATIONPATH)$@".vcd"
gc_dv_top_level_tb02: gc_dv_top_level
	$(GHDL_CMD) -a $(GHDL_AFLAGS) $(TESTBENCHPATH)$@$(VHDLEX)
	$(GHDL_CMD) -e $(GHDL_EFLAGS) $(GC_DV_TOP_LEVEL_TB)
	$(GHDL_CMD) -r $(GHDL_RFLAGS) $(GC_DV_TOP_LEVEL_TB) --vcd=$(SIMULATIONPATH)$@".vcd"
gc_dv_top_level: gc_dv_decode gc_dv_422_to_444 gc_dv_YCbCr_to_RGB gc_dv_video_DAC
	$(GHDL_CMD) -a $(GHDL_AFLAGS) $(SOURCEPATH)$@$(VHDLEX)

GC_DV_VIDEO_DAC_TB = gc_dv_video_DAC_tb
gc_dv_video_DAC_tb01: gc_dv_video_DAC
	$(GHDL_CMD) -a $(GHDL_AFLAGS) $(TESTBENCHPATH)$@$(VHDLEX)
	$(GHDL_CMD) -e $(GHDL_EFLAGS) $(GC_DV_VIDEO_DAC_TB)
	$(GHDL_CMD) -r $(GHDL_RFLAGS) $(GC_DV_VIDEO_DAC_TB) --vcd=$(SIMULATIONPATH)$@".vcd"
gc_dv_video_DAC:
	$(GHDL_CMD) -a $(GHDL_AFLAGS) $(SOURCEPATH)$@$(VHDLEX)

GC_DV_YCBCR_TO_RGB_TB = gc_dv_YCbCr_to_RGB_tb
gc_dv_YCbCr_to_RGB_tb01: gc_dv_YCbCr_to_RGB
	$(GHDL_CMD) -a $(GHDL_AFLAGS) $(TESTBENCHPATH)$@$(VHDLEX)
	$(GHDL_CMD) -e $(GHDL_EFLAGS) $(GC_DV_YCBCR_TO_RGB_TB)
	$(GHDL_CMD) -r $(GHDL_RFLAGS) $(GC_DV_YCBCR_TO_RGB_TB) --vcd=$(SIMULATIONPATH)$@".vcd"
gc_dv_YCbCr_to_RGB:
	$(GHDL_CMD) -a $(GHDL_AFLAGS) $(SOURCEPATH)$@$(VHDLEX)

GC_DV_422_TO_444_TB = gc_dv_422_to_444_tb
gc_dv_422_to_444_tb01: gc_dv_422_to_444
	$(GHDL_CMD) -a $(GHDL_AFLAGS) $(TESTBENCHPATH)$@$(VHDLEX)
	$(GHDL_CMD) -e $(GHDL_EFLAGS) $(GC_DV_422_TO_444_TB)
	$(GHDL_CMD) -r $(GHDL_RFLAGS) $(GC_DV_422_TO_444_TB) --vcd=$(SIMULATIONPATH)$@".vcd"
gc_dv_422_to_444:
	$(GHDL_CMD) -a $(GHDL_AFLAGS) $(SOURCEPATH)$@$(VHDLEX)

GC_DV_DECODE_TB = gc_dv_decode_tb
gc_dv_decode_tb01: gc_dv_decode
	$(GHDL_CMD) -a $(GHDL_AFLAGS) $(TESTBENCHPATH)$@$(VHDLEX)
	$(GHDL_CMD) -e $(GHDL_EFLAGS) $(GC_DV_DECODE_TB)
	$(GHDL_CMD) -r $(GHDL_RFLAGS) $(GC_DV_DECODE_TB) --vcd=$(SIMULATIONPATH)$@".vcd"
gc_dv_decode_tb02: gc_dv_decode
	$(GHDL_CMD) -a $(GHDL_AFLAGS) $(TESTBENCHPATH)$@$(VHDLEX)
	$(GHDL_CMD) -e $(GHDL_EFLAGS) $(GC_DV_DECODE_TB)
	$(GHDL_CMD) -r $(GHDL_RFLAGS) $(GC_DV_DECODE_TB) --vcd=$(SIMULATIONPATH)$@".vcd"
gc_dv_decode_tb03: gc_dv_decode
	$(GHDL_CMD) -a $(GHDL_AFLAGS) $(TESTBENCHPATH)$@$(VHDLEX)
	$(GHDL_CMD) -e $(GHDL_EFLAGS) $(GC_DV_DECODE_TB)
	$(GHDL_CMD) -r $(GHDL_RFLAGS) $(GC_DV_DECODE_TB) --vcd=$(SIMULATIONPATH)$@".vcd"
gc_dv_decode: 
	$(GHDL_CMD) -a $(GHDL_AFLAGS) $(SOURCEPATH)$@$(VHDLEX)

clean:
	@$(GHDL_CMD) --remove
