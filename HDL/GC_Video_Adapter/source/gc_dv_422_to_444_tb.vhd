-- file: gc_dv_422_to_444_tb.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_422_to_444_tb is
end entity;

architecture behav of gc_dv_422_to_444_tb is

	component gc_dv_422_to_444 is
		port(
			vclk	: in	std_logic;
			vphase	: in	std_logic;
			vdata	: in	std_logic_vector(7 downto 0);
			reset	: in	std_logic;
			pclk	: out	std_logic;
			Y		: out	std_logic_vector(7 downto 0);
			CbCr	: out	std_logic_vector(7 downto 0);
			is_Cr	: out	std_logic;
			H_sync	: out	std_logic;
			V_sync	: out	std_logic;
			C_sync	: out	std_logic;
			Blanking: out	std_logic;
			dvalid	: out	std_logic
		);
	end component;
	
	-- Test bench signals
	signal vclk_tb		: std_logic;
	signal vphase_tb	: std_logic;
	signal vdata_tb		: std_logic_vector(7 downto 0);
	signal reset_tb		: std_logic;
	signal pclk_tb		: std_logic;
	signal Y_tb			: std_logic_vector(7 downto 0);
	signal CbCr_tb		: std_logic_vector(7 downto 0);
	signal is_Cr_tb		: std_logic;
	signal H_sync_tb	: std_logic;
	signal V_sync_tb	: std_logic;
	signal C_sync_tb	: std_logic;
	signal Blanking_tb	: std_logic;
	signal dvalid_tb	: std_logic;
	
	-- Declare record type to build a test vector for this test bench
	type test_vector is record
			vclk_tb		: std_logic;
			vphase_tb	: std_logic;
			vdata_tb	: std_logic_vector(7 downto 0);
			reset_tb	: std_logic;
			pclk_tb		: std_logic;
			Y_tb		: std_logic_vector(7 downto 0);
			CbCr_tb		: std_logic_vector(7 downto 0);
			is_Cr_tb	: std_logic;
			H_sync_tb	: std_logic;
			V_sync_tb	: std_logic;
			C_sync_tb	: std_logic;
			Blanking_tb	: std_logic;
			dvalid_tb	: std_logic;
	end record;

	type test_vector_array is array (natural range <>) of test_vector;
	constant test_vectors : test_vector_array := (
		-- vclk, vphase, vdata, reset, pclk, Y,     CbCr,  is_Cr, H_sync, V_sync, C_sync, Blanking, dvalid
		  ('1',  '0',    x"00", '1',   '0',  x"00", x"00", '0',   '0',    '0',    '0',    '0',      '0'),	-- reset

		  ('1',  '1',    x"67", '0',   '1',  x"10", x"80", '1',   '1',    '1',    '0',    '1',      '1')
		);
begin
	
	uut: component gc_dv_422_to_444 port map (
		vclk		=> vclk_tb,
		vphase		=> vphase_tb,
		vdata		=> vdata_tb,
		reset		=> reset_tb,
		pclk		=> pclk_tb,
		Y			=> Y_tb,
		CbCr		=> CbCr_tb,
		is_Cr		=> is_Cr_tb,
		H_sync		=> H_sync_tb,
		V_sync		=> V_sync_tb,
		C_sync		=> C_sync_tb,
		Blanking	=> Blanking_tb,
		dvalid		=> dvalid_tb
	);
	
	tb1 : process
		constant period: time := 20 ns;
	begin
		for i in test_vectors'range loop
			-- Feed in test data from ith test vector line
			vclk_tb <= test_vectors(i).vclk_tb;
			vphase_tb <= test_vectors(i).vphase_tb;
			vdata_tb <= test_vectors(i).vdata_tb;
			reset_tb <= test_vectors(i).reset_tb;

			wait for period;
		end loop;
		
		wait;
	end process; 
end behav;
