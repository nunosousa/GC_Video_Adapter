-- file: gc_dv_video_DAC_tb.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_video_DAC_tb is
end entity;

architecture behav of gc_dv_video_DAC_tb is
	component gc_dv_video_DAC is
		port(
			vclk			: in	std_logic;
			pclk			: in	std_logic;
			G_Y				: in	std_logic_vector(7 downto 0);
			B_Cb			: in	std_logic_vector(7 downto 0);
			R_Cr			: in	std_logic_vector(7 downto 0);
			H_sync			: in	std_logic;
			V_sync			: in	std_logic;
			C_sync			: in	std_logic;
			Blanking		: in	std_logic;
			dvalid			: in	std_logic;
			G_Y_DAC			: out	std_logic_vector(7 downto 0);
			B_Cb_DAC		: out	std_logic_vector(7 downto 0);
			R_Cr_DAC		: out	std_logic_vector(7 downto 0);
			clk_DAC			: out	std_logic;
			nC_sync_DAC		: out	std_logic;
			nBlanking_DAC	: out	std_logic
		);
	end component;
	
	-- Test bench signals
	signal vclk_tb			: std_logic;
	signal pclk_tb			: std_logic;
	signal G_Y_tb			: std_logic_vector(7 downto 0);
	signal B_Cb_tb			: std_logic_vector(7 downto 0);
	signal R_Cr_tb			: std_logic_vector(7 downto 0);
	signal H_sync_tb		: std_logic;
	signal V_sync_tb		: std_logic;
	signal C_sync_tb		: std_logic;
	signal Blanking_tb		: std_logic;
	signal dvalid_tb		: std_logic;
	signal G_Y_DAC_tb		: std_logic_vector(7 downto 0);
	signal B_Cb_DAC_tb		: std_logic_vector(7 downto 0);
	signal R_Cr_DAC_tb		: std_logic_vector(7 downto 0);
	signal clk_DAC_tb		: std_logic;
	signal nC_sync_DAC_tb	: std_logic;
	signal nBlanking_DAC_tb	: std_logic;
	
	-- Declare record type to build a test vector for this test bench
	type test_vector is record
		vclk_tb			: std_logic;
		pclk_tb			: std_logic;
		G_Y_tb			: std_logic_vector(7 downto 0);
		B_Cb_tb			: std_logic_vector(7 downto 0);
		R_Cr_tb			: std_logic_vector(7 downto 0);
		H_sync_tb		: std_logic;
		V_sync_tb		: std_logic;
		C_sync_tb		: std_logic;
		Blanking_tb		: std_logic;
		dvalid_tb		: std_logic;
	end record;

	type test_vector_array is array (natural range <>) of test_vector;
	constant test_vectors : test_vector_array := (
		-- vclk	pclk,	G_Y,	B_Cb,   R_Cr,   H_sync,	V_sync,	C_sync,	Blanking,	dvalid
		  ('0',	'0',	x"01",	x"02",	x"03",	'1',	'0',	'1',	'0',	    '0'),
		  ('1',	'0',	x"01",	x"02",	x"03",	'1',	'0',	'1',	'0',	    '0'),

		  ('0',	'1',	x"01",	x"02",	x"03",	'1',	'0',	'1',	'0',	    '0'),
		  ('1',	'1',	x"01",	x"02",	x"03",	'1',	'0',	'1',	'0',	    '0'),

		  ('0',	'0',	x"07",	x"08",	x"09",	'0',	'1',	'0',	'1',	    '0'),
		  ('1',	'0',	x"07",	x"08",	x"09",	'0',	'1',	'0',	'1',    	'0'),

		  ('0',	'1',	x"07",	x"08",	x"09",	'0',	'1',	'0',	'1',    	'0'),
		  ('1',	'1',	x"07",	x"08",	x"09",	'0',	'1',	'0',	'1',    	'0'),

		  ('0',	'0',	x"55",	x"AA",	x"FF",	'1',	'0',	'0',	'0',    	'1'),
		  ('1',	'0',	x"55",	x"AA",	x"FF",	'1',	'0',	'0',	'0',    	'1'),

		  ('0',	'1',	x"55",	x"AA",	x"FF",	'1',	'0',	'0',	'0',    	'1'),
		  ('1',	'1',	x"55",	x"AA",	x"FF",	'1',	'0',	'0',	'0',    	'1')
		);
begin
	uut: component gc_dv_video_DAC port map (
		vclk			=> vclk_tb,
		pclk			=> pclk_tb,
		G_Y				=> G_Y_tb,
		B_Cb			=> B_Cb_tb,
		R_Cr			=> R_Cr_tb,
		H_sync			=> H_sync_tb,
		V_sync			=> V_sync_tb,
		C_sync			=> C_sync_tb,
		Blanking		=> Blanking_tb,
		dvalid			=> dvalid_tb,
		G_Y_DAC			=> G_Y_DAC_tb,
		B_Cb_DAC		=> B_Cb_DAC_tb,
		R_Cr_DAC		=> R_Cr_DAC_tb,
		clk_DAC			=> clk_DAC_tb,
		nC_sync_DAC		=> nC_sync_DAC_tb,
		nBlanking_DAC	=> nBlanking_DAC_tb
	);
	
	tb1 : process
		constant period: time := 20 ns;
	begin
		for i in test_vectors'range loop
			-- Feed in test data from ith test vector line
			vclk_tb <= test_vectors(i).vclk_tb;
			pclk_tb <= test_vectors(i).pclk_tb;
			G_Y_tb <= test_vectors(i).G_Y_tb;
			B_Cb_tb <= test_vectors(i).B_Cb_tb;
			R_Cr_tb <= test_vectors(i).R_Cr_tb;
			H_sync_tb <= test_vectors(i).H_sync_tb;
			V_sync_tb <= test_vectors(i).V_sync_tb;
			C_sync_tb <= test_vectors(i).C_sync_tb;
			Blanking_tb <= test_vectors(i).Blanking_tb;
			dvalid_tb <= test_vectors(i).dvalid_tb;

			wait for period;
		end loop;
		
		wait;
	end process; 
end behav;
