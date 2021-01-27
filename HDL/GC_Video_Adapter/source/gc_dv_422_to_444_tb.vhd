-- file: gc_dv_422_to_444_tb.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_422_to_444_tb is
end entity;

architecture behav of gc_dv_422_to_444_tb is

	component gc_dv_422_to_444 is
		port(
			pclk		: in	std_logic;
			Y			: in	std_logic_vector(7 downto 0);
			CbCr		: in	std_logic_vector(7 downto 0);
			is_Cr		: in	std_logic;
			is_odd		: in	std_logic;
			H_sync		: in	std_logic;
			V_sync		: in	std_logic;
			C_sync		: in	std_logic;
			Blanking	: in	std_logic;
			dvalid		: in	std_logic;
			reset		: in	std_logic;
			Y_dly		: out	std_logic_vector(7 downto 0);
			Cb_flt		: out	std_logic_vector(7 downto 0);
			Cr_flt		: out	std_logic_vector(7 downto 0);
			H_sync_dly	: out	std_logic;
			V_sync_dly	: out	std_logic;
			C_sync_dly	: out	std_logic;
			dvalid_dly	: out	std_logic
		);
	end component;
	
	-- Test bench signals
	signal pclk_tb			: std_logic;
	signal Y_tb				: std_logic_vector(7 downto 0);
	signal CbCr_tb			: std_logic_vector(7 downto 0);
	signal is_Cr_tb			: std_logic;
	signal is_odd_tb		: std_logic;
	signal H_sync_tb		: std_logic;
	signal V_sync_tb		: std_logic;
	signal C_sync_tb		: std_logic;
	signal Blanking_tb		: std_logic;
	signal dvalid_tb		: std_logic;
	signal reset_tb			: std_logic;
	signal Y_dly_tb			: std_logic_vector(7 downto 0);
	signal Cb_flt_tb		: std_logic_vector(7 downto 0);
	signal Cr_flt_tb		: std_logic_vector(7 downto 0);
	signal H_sync_dly_tb	: std_logic;
	signal V_sync_dly_tb	: std_logic;
	signal C_sync_dly_tb	: std_logic;
	signal dvalid_dly_tb	: std_logic;
	
	-- Declare record type to build a test vector for this test bench
	type test_vector is record
		pclk_tb			: std_logic;
		Y_tb			: std_logic_vector(7 downto 0);
		CbCr_tb			: std_logic_vector(7 downto 0);
		is_Cr_tb		: std_logic;
		is_odd_tb		: std_logic;
		H_sync_tb		: std_logic;
		V_sync_tb		: std_logic;
		C_sync_tb		: std_logic;
		Blanking_tb		: std_logic;
		dvalid_tb		: std_logic;
		reset_tb		: std_logic;
		Y_dly_tb		: std_logic_vector(7 downto 0);
		Cb_flt_tb		: std_logic_vector(7 downto 0);
		Cr_flt_tb		: std_logic_vector(7 downto 0);
		H_sync_dly_tb	: std_logic;
		V_sync_dly_tb	: std_logic;
		C_sync_dly_tb	: std_logic;
		dvalid_dly_tb	: std_logic;
	end record;

	type test_vector_array is array (natural range <>) of test_vector;
	constant test_vectors : test_vector_array := (
		-- pclk,	Y,		CbCr,	is_Cr,	is_odd,	H_sync,	V_sync,	C_sync,	Blanking,	dvalid,	reset
		  ('0',		x"01",	x"02",	'1',	'0',	'0',	'0',	'0',	'0',		'0',	'0'),
		  ('1',		x"01",	x"02",	'1',	'0',	'0',	'0',	'0',	'0',		'0',	'0'),
		  ('0',		x"01",	x"02",	'1',	'0',	'0',	'0',	'0',	'0',		'0',	'0'),
		  ('1',		x"01",	x"02",	'1',	'0',	'0',	'0',	'0',	'0',		'0',	'0'),
		  ('0',		x"01",	x"02",	'1',	'0',	'0',	'0',	'0',	'0',		'0',	'0'),
		  ('1',		x"01",	x"02",	'1',	'0',	'0',	'0',	'0',	'0',		'0',	'0'),
		  ('0',		x"01",	x"02",	'1',	'0',	'0',	'0',	'0',	'0',		'0',	'0'),
		  ('1',		x"01",	x"02",	'1',	'0',	'0',	'0',	'0',	'0',		'0',	'0'),
		  ('0',		x"01",	x"02",	'1',	'0',	'0',	'0',	'0',	'0',		'0',	'0'),
		  ('1',		x"01",	x"02",	'1',	'0',	'0',	'0',	'0',	'0',		'0',	'0'),
		  ('0',		x"01",	x"02",	'1',	'0',	'0',	'0',	'0',	'0',		'0',	'0'),
		  ('1',		x"01",	x"02",	'1',	'0',	'0',	'0',	'0',	'0',		'0',	'0'),
		  ('0',		x"01",	x"02",	'1',	'0',	'0',	'0',	'0',	'0',		'0',	'0'),
		  ('1',		x"01",	x"02",	'1',	'0',	'0',	'0',	'0',	'0',		'0',	'0'),
		  ('0',		x"01",	x"02",	'1',	'0',	'0',	'0',	'0',	'0',		'0',	'0')
		);
begin
	
	uut: component gc_dv_422_to_444 port map (
		pclk		=> pclk_tb,
		Y			=> Y_tb,
		CbCr		=> CbCr_tb,
		is_Cr		=> is_Cr_tb,
		is_odd		=> is_odd_tb,
		H_sync		=> H_sync_tb,
		V_sync		=> V_sync_tb,
		C_sync		=> C_sync_tb,
		Blanking	=> Blanking_tb,
		dvalid		=> dvalid_tb,
		reset		=> reset_tb,
		Y_dly		=> Y_dly_tb,
		Cb_flt		=> Cb_flt_tb,
		Cr_flt		=> Cr_flt_tb,
		H_sync_dly	=> H_sync_dly_tb,
		V_sync_dly	=> V_sync_dly_tb,
		C_sync_dly	=> C_sync_dly_tb,
		dvalid_dly	=> dvalid_dly_tb
	);
	
	tb1 : process
		constant period: time := 20 ns;
	begin
		for i in test_vectors'range loop
			-- Feed in test data from ith test vector line
			pclk_tb <= test_vectors(i).pclk_tb;
			Y_tb <= test_vectors(i).Y_tb;
			CbCr_tb <= test_vectors(i).CbCr_tb;
			is_Cr_tb <= test_vectors(i).is_Cr_tb;
			is_odd_tb <= test_vectors(i).is_odd_tb;
			H_sync_tb <= test_vectors(i).H_sync_tb;
			V_sync_tb <= test_vectors(i).V_sync_tb;
			C_sync_tb <= test_vectors(i).C_sync_tb;
			Blanking_tb <= test_vectors(i).Blanking_tb;
			dvalid_tb <= test_vectors(i).dvalid_tb;
            reset_tb <= test_vectors(i).reset_tb;
			
			wait for period;
		end loop;
		
		wait;
	end process; 
end behav;
