-- file: gc_dv_video_DAC_tb.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_video_DAC_tb is
end entity;

architecture behav of gc_dv_video_DAC_tb is
	component gc_dv_video_DAC is
		port(
            vclk		: in	std_logic;
            pclk		: in	std_logic;
            Y			: in	std_logic_vector(7 downto 0);
            Cb			: in	std_logic_vector(7 downto 0);
            Cr			: in	std_logic_vector(7 downto 0);
            H_sync		: in	std_logic;
            V_sync		: in	std_logic;
            C_sync		: in	std_logic;
            Blanking	: in	std_logic;
            dvalid		: in	std_logic;
            RGB_out_en	: in	std_logic;
            pclk_out	: out	std_logic;
            G_Y_out		: out	std_logic_vector(7 downto 0);
            B_Cb_out	: out	std_logic_vector(7 downto 0);
            R_Cr_out	: out	std_logic_vector(7 downto 0);
            H_sync_out	: out	std_logic;
            V_sync_out	: out	std_logic;
            C_sync_out	: out	std_logic;
            Blanking_out: out	std_logic;
            dvalid_out	: out	std_logic
		);
	end component;
	
	-- Test bench signals
	signal vclk_tb			: std_logic;
	signal pclk_tb			: std_logic;
	signal Y_tb				: std_logic_vector(7 downto 0);
	signal Cb_tb			: std_logic_vector(7 downto 0);
	signal Cr_tb			: std_logic_vector(7 downto 0);
	signal H_sync_tb		: std_logic;
	signal V_sync_tb		: std_logic;
	signal C_sync_tb		: std_logic;
	signal Blanking_tb		: std_logic;
	signal dvalid_tb		: std_logic;
    signal RGB_out_en_tb    : std_logic;
	signal pclk_out_tb		: std_logic;
	signal G_Y_out_tb		: std_logic_vector(7 downto 0);
	signal B_Cb_out_tb		: std_logic_vector(7 downto 0);
	signal R_Cr_out_tb		: std_logic_vector(7 downto 0);
	signal H_sync_out_tb	: std_logic;
	signal V_sync_out_tb	: std_logic;
	signal C_sync_out_tb	: std_logic;
	signal Blanking_out_tb	: std_logic;
	signal dvalid_out_tb	: std_logic;
	
	-- Declare record type to build a test vector for this test bench
	type test_vector is record
		vclk_tb			: std_logic;
		pclk_tb			: std_logic;
		Y_tb			: std_logic_vector(7 downto 0);
		Cb_tb			: std_logic_vector(7 downto 0);
		Cr_tb			: std_logic_vector(7 downto 0);
		H_sync_tb		: std_logic;
		V_sync_tb		: std_logic;
		C_sync_tb		: std_logic;
		Blanking_tb		: std_logic;
		dvalid_tb		: std_logic;
        RGB_out_en_tb   : std_logic;
	end record;

	type test_vector_array is array (natural range <>) of test_vector;
	constant test_vectors : test_vector_array := (
		-- vclk	pclk,	Y,		Cb      Cr,     H_sync,	V_sync,	C_sync,	Blanking,	dvalid,	RGB_out_en
		  ('0',	'0',	x"01",	x"02",	x"03",	'1',	'0',	'1',	'0',	    '0',	'0'),
		  ('1',	'0',	x"01",	x"02",	x"03",	'1',	'0',	'1',	'0',	    '0',	'0'),

		  ('0',	'1',	x"01",	x"02",	x"03",	'1',	'0',	'1',	'0',	    '0',	'0'),
		  ('1',	'1',	x"01",	x"02",	x"03",	'1',	'0',	'1',	'0',	    '0',	'0'),

		  ('0',	'0',	x"07",	x"08",	x"09",	'0',	'1',	'0',	'1',	    '0',	'0'),
		  ('1',	'0',	x"07",	x"08",	x"09",	'0',	'1',	'0',	'1',    	'0',	'0'),

		  ('0',	'1',	x"07",	x"08",	x"09",	'0',	'1',	'0',	'1',    	'0',	'0'),
		  ('1',	'1',	x"07",	x"08",	x"09",	'0',	'1',	'0',	'1',    	'0',	'0'),

		  ('0',	'0',	x"55",	x"AA",	x"FF",	'1',	'0',	'0',	'0',    	'1',	'0'),
		  ('1',	'0',	x"55",	x"AA",	x"FF",	'1',	'0',	'0',	'0',    	'1',	'0'),

		  ('0',	'1',	x"55",	x"AA",	x"FF",	'1',	'0',	'0',	'0',    	'1',	'0'),
		  ('1',	'1',	x"55",	x"AA",	x"FF",	'1',	'0',	'0',	'0',    	'1',	'0')
		);
begin
	uut: component gc_dv_video_DAC port map (
		vclk			=> vclk_tb,
		pclk			=> pclk_tb,
		Y				=> Y_tb,
		Cb			    => Cb_tb,
		Cr		    	=> Cr_tb,
		H_sync			=> H_sync_tb,
		V_sync			=> V_sync_tb,
		C_sync			=> C_sync_tb,
		Blanking		=> Blanking_tb,
		dvalid			=> dvalid_tb,
        RGB_out_en		=> RGB_out_en_tb,
		pclk_out		=> pclk_out_tb,
		G_Y_out			=> G_Y_out_tb,
		B_Cb_out		=> B_Cb_out_tb,
		R_Cr_out		=> R_Cr_out_tb,
		H_sync_out		=> H_sync_out_tb,
		V_sync_out		=> V_sync_out_tb,
		C_sync_out		=> C_sync_out_tb,
		Blanking_out	=> Blanking_out_tb,
		dvalid_out		=> dvalid_out_tb
	);
	
	tb1 : process
		constant period: time := 20 ns;
	begin
		for i in test_vectors'range loop
			-- Feed in test data from ith test vector line
			vclk_tb <= test_vectors(i).vclk_tb;
			pclk_tb <= test_vectors(i).pclk_tb;
			Y_tb <= test_vectors(i).Y_tb;
			Cb_tb <= test_vectors(i).Cb_tb;
			Cr_tb <= test_vectors(i).Cr_tb;
			H_sync_tb <= test_vectors(i).H_sync_tb;
			V_sync_tb <= test_vectors(i).V_sync_tb;
			C_sync_tb <= test_vectors(i).C_sync_tb;
			Blanking_tb <= test_vectors(i).Blanking_tb;
			dvalid_tb <= test_vectors(i).dvalid_tb;
			RGB_out_en_tb <= test_vectors(i).RGB_out_en_tb;

			wait for period;
		end loop;
		
		wait;
	end process; 
end behav;
