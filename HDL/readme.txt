-- Usefull text
https://surf-vhdl.com/how-to-implement-clock-divider-vhdl/
https://surf-vhdl.com/how-to-implement-fir-filter-in-vhdl/
https://www.allaboutcircuits.com/technical-articles/std-logic-vector-data-type-in-vhdl-code/
https://www.allaboutcircuits.com/technical-articles/review-of-vhdl-signed-unsigned-data-types/
https://www.allaboutcircuits.com/technical-articles/variable-valuable-object-in-sequential-vhdl/
https://www.allaboutcircuits.com/technical-articles/twos-complement-representation-theory-and-examples/
https://www.allaboutcircuits.com/technical-articles/considerations-for-fpga-implementation-of-linear-phase-fir-filters/
https://www.allaboutcircuits.com/technical-articles/pipelined-direct-form-fir-versus-the-transposed-structure/
https://www.allaboutcircuits.com/technical-articles/considerations-for-adding-reset-capability-to-an-fpga-design/
https://www.allaboutcircuits.com/technical-articles/introduction-to-clock-domain-crossing-double-flopping/
https://www.allaboutcircuits.com/technical-articles/introduction-to-distributed-arithmetic/
https://www.allaboutcircuits.com/technical-articles/basic-binary-division-the-algorithm-and-the-vhdl-code/
https://insights.sigasi.com/opinion/jan/vhdls-crown-jewel/
https://vhdlwhiz.com/delta-cycles-explained/
https://vhdlguide.readthedocs.io/en/latest/vhdl/testbench.html

ghdl -a gc_dv_decode.vhd; ghdl -a gc_dv_decode_tb01.vhd; ghdl -e gc_dv_decode_tb; ghdl -r gc_dv_decode_tb --wave=gc_dv_decode_tb01.ghw
ghdl -a gc_dv_decode.vhd; ghdl -a gc_dv_decode_tb03.vhd; ghdl -e gc_dv_decode_tb; ghdl -r gc_dv_decode_tb --vcd=gc_dv_decode_tb03.vcd
ghdl -a gc_dv_422_to_444.vhd; ghdl -a gc_dv_422_to_444_tb01.vhd; ghdl -e gc_dv_422_to_444_tb; ghdl -r gc_dv_422_to_444_tb --vcd=gc_dv_422_to_444_tb01.vcd

ghdl -a gc_dv_decode.vhd;
ghdl -a gc_dv_422_to_444.vhd;
ghdl -a gc_dv_YCbCr_to_RGB.vhd;
ghdl -a gc_dv_video_DAC.vhd;
ghdl -a gc_dv_top_level.vhd;
ghdl -a gc_dv_top_level_tb01.vhd;
ghdl -e gc_dv_top_level_tb;
ghdl -r gc_dv_top_level_tb --vcd=gc_dv_top_level_tb01.vcd