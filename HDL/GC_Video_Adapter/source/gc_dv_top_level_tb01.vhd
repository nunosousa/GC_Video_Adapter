-- file: gc_dv_top_level_tb01.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_top_level_tb is
end entity;

architecture behav of gc_dv_top_level_tb is

	component gc_dv_top_level is
        port(
            vclk			: in	std_logic;
            vphase			: in	std_logic;
            vdata			: in	std_logic_vector(7 downto 0);
            RGB_out_en		: in	std_logic;
            G_Y_DAC			: out	std_logic_vector(7 downto 0) := x"10";
            B_Cb_DAC		: out	std_logic_vector(7 downto 0) := x"80";
            R_Cr_DAC		: out	std_logic_vector(7 downto 0) := x"80";
            clk_DAC			: out	std_logic;
            nC_sync_DAC		: out	std_logic;
            nBlanking_DAC	: out	std_logic
        );
	end component;
	
	-- Test bench signals
	signal vclk_tb          : std_logic;
	signal vphase_tb        : std_logic;
	signal vdata_tb		    : std_logic_vector(7 downto 0);
    signal RGB_out_en_tb	: std_logic;
	signal G_Y_DAC_tb       : std_logic_vector(7 downto 0);
	signal B_Cb_DAC_tb      : std_logic_vector(7 downto 0);
	signal R_Cr_DAC_tb      : std_logic_vector(7 downto 0);
	signal clk_DAC_tb       : std_logic;
    signal nC_sync_DAC_tb   : std_logic;
	signal nBlanking_tb     : std_logic;
	
	-- Declare record type to build a test vector for this test bench
	type test_vector is record
			vclk_tb		    : std_logic;
			vphase_tb	    : std_logic;
			vdata_tb	    : std_logic_vector(7 downto 0);
            RGB_out_en_tb   : std_logic;
	end record;

	type test_vector_array is array (natural range <>) of test_vector;
	constant test_vectors : test_vector_array := (
		-- vclk, vphase, vdata, RGB_out_en
		  ('0',  '0',    x"00", '0'),	-- fast data, blanking data, raw flags high
		  ('1',  '0',    x"00", '0'),
		  ('0',  '0',    x"00", '0'),
		  ('1',  '0',    x"00", '0'),
		  
		  ('0',  '1',    x"00", '0'),	-- fast data, blanking data, raw flag bit 4 low (H_sync)
		  ('1',  '1',    x"00", '0'),
		  ('0',  '1',    x"EF", '0'),
		  ('1',  '1',    x"EF", '0'),
		  
		  ('0',  '0',    x"00", '0'),	-- fast data, blanking data, raw flag bit 5 low (V_sync)
		  ('1',  '0',    x"00", '0'),
		  ('0',  '0',    x"DF", '0'),
		  ('1',  '0',    x"DF", '0'),
		  
		  ('0',  '1',    x"00", '0'),	-- fast data, blanking data, raw flag bit 7 low (C_sync)
		  ('1',  '1',    x"00", '0'),
		  ('0',  '1',    x"7F", '0'),
		  ('1',  '1',    x"7F", '0'),
		  
		  ('0',  '0',    x"00", '0'),	-- fast data, blanking data
		  ('1',  '0',    x"00", '0'),
		  ('0',  '0',    x"FF", '0'),
		  ('1',  '0',    x"FF", '0'),
		  
		  ('0',  '1',    x"01", '0'),
		  ('1',  '1',    x"01", '0'),
		  ('0',  '1',    x"01", '0'),
		  ('1',  '1',    x"01", '0'),
		  
		  ('0',  '0',    x"02", '0'),
		  ('1',  '0',    x"02", '0'),
		  ('0',  '0',    x"02", '0'),
		  ('1',  '0',    x"02", '0'),
		  
		  ('0',  '1',    x"04", '0'),
		  ('1',  '1',    x"04", '0'),
		  ('0',  '1',    x"04", '0'),
		  ('1',  '1',    x"04", '0'),
		  
		  ('0',  '0',    x"08", '0'),
		  ('1',  '0',    x"08", '0'),
		  ('0',  '0',    x"08", '0'),
		  ('1',  '0',    x"08", '0'),
		  
		  ('0',  '1',    x"10", '0'),
		  ('1',  '1',    x"10", '0'),
		  ('0',  '1',    x"10", '0'),
		  ('1',  '1',    x"10", '0'),
		  
		  ('0',  '0',    x"20", '0'),
		  ('1',  '0',    x"20", '0'),
		  ('0',  '0',    x"20", '0'),
		  ('1',  '0',    x"20", '0'),
		  
		  ('0',  '1',    x"40", '0'),
		  ('1',  '1',    x"40", '0'),
		  ('0',  '1',    x"40", '0'),
		  ('1',  '1',    x"40", '0'),
		  
		  ('0',  '0',    x"88", '0'),
		  ('1',  '0',    x"88", '0'),
		  ('0',  '0',    x"88", '0'),
		  ('1',  '0',    x"88", '0'),
		  
		  ('0',  '1',    x"00", '0'),
		  ('1',  '1',    x"00", '0'),
		  ('0',  '1',    x"00", '0'),
		  ('1',  '1',    x"00", '0'),
		  
		  ('0',  '0',    x"00", '0'),
		  ('1',  '0',    x"00", '0'),
		  ('0',  '0',    x"00", '0'),
		  ('1',  '0',    x"00", '0'),
		  
		  ('0',  '1',    x"00", '0'),
		  ('1',  '1',    x"00", '0'),
		  ('0',  '1',    x"00", '0'),
		  ('1',  '1',    x"00", '0'),
		  
		  ('0',  '0',    x"00", '0'),
		  ('1',  '0',    x"00", '0'),
		  ('0',  '0',    x"00", '0'),
		  ('1',  '0',    x"00", '0'),
		  
		  ('0',  '1',    x"00", '0'),
		  ('1',  '1',    x"00", '0'),
		  ('0',  '1',    x"00", '0'),
		  ('1',  '1',    x"00", '0'),
		  
		  ('0',  '0',    x"00", '0'),
		  ('1',  '0',    x"00", '0'),
		  ('0',  '0',    x"00", '0'),
		  ('1',  '0',    x"00", '0')
		);
begin
	
	uut: component gc_dv_top_level port map (
        vclk	    	=> vclk_tb,
        vphase	    	=> vphase_tb,
        vdata		    => vdata_tb,
        RGB_out_en  	=> RGB_out_en_tb,
        G_Y_DAC	    	=> G_Y_DAC_tb,
        B_Cb_DAC    	=> B_Cb_DAC_tb,
        R_Cr_DAC    	=> R_Cr_DAC_tb,
        clk_DAC	    	=> clk_DAC_tb,
        nC_sync_DAC		=> nC_sync_DAC_tb,
        nBlanking_DAC   => nBlanking_tb
	);

	tb1 : process
		constant period: time := 20 ns;
	begin
		for i in test_vectors'range loop
			-- Feed in test data from ith test vector line
			vclk_tb <= test_vectors(i).vclk_tb;
			vphase_tb <= test_vectors(i).vphase_tb;
			vdata_tb <= test_vectors(i).vdata_tb;
            RGB_out_en_tb <= test_vectors(i).RGB_out_en_tb;

			wait for period;
		end loop;
		
		wait;
	end process;
end behav;
