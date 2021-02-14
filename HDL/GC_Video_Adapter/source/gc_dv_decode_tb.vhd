-- file: gc_dv_decode_tb.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_decode_tb is
end entity;

architecture behav of gc_dv_decode_tb is

	component gc_dv_decode is
		port(
			vclk	: in	std_logic;
			vphase	: in	std_logic;
			vdata	: in	std_logic_vector(7 downto 0);
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
		-- vclk, vphase, vdata
		  ('0',  '0',    x"00"),	-- fast data, blanking data, raw flags low
		  ('1',  '0',    x"00"),
		  ('0',  '0',    x"00"),
		  ('1',  '0',    x"00"),
		  
		  ('0',  '1',    x"00"),	-- fast data, blanking data, raw flag bit 4 high
		  ('1',  '1',    x"00"),
		  ('0',  '1',    x"10"),
		  ('1',  '1',    x"10"),
		  
		  ('0',  '0',    x"00"),	-- fast data, blanking data, raw flag bit 5 high
		  ('1',  '0',    x"00"),
		  ('0',  '0',    x"20"),
		  ('1',  '0',    x"20"),
		  
		  ('0',  '1',    x"00"),	-- fast data, blanking data, raw flag bit 7 high
		  ('1',  '1',    x"00"),
		  ('0',  '1',    x"80"),
		  ('1',  '1',    x"80"),
		  
		  ('0',  '0',    x"00"),	-- fast data, color data
		  ('1',  '0',    x"00"),
		  ('0',  '0',    x"00"),
		  ('1',  '0',    x"00"),
		  
		  ('0',  '1',    x"15"),
		  ('1',  '1',    x"15"),
		  ('0',  '1',    x"70"),
		  ('1',  '1',    x"70"),
		  
		  ('0',  '0',    x"16"),
		  ('1',  '0',    x"16"),
		  ('0',  '0',    x"69"),
		  ('1',  '0',    x"69"),
		  
		  ('0',  '1',    x"17"),
		  ('1',  '1',    x"17"),
		  ('0',  '1',    x"68"),
		  ('1',  '1',    x"68"),
		  
		  ('0',  '0',    x"18"),
		  ('1',  '0',    x"18"),
		  ('0',  '0',    x"67"),
		  ('1',  '0',    x"67"),
		  
		  ('0',  '1',    x"19"),
		  ('1',  '1',    x"19"),
		  ('0',  '1',    x"66"),
		  ('1',  '1',    x"66"),
		  
		  ('0',  '1',    x"19"),
		  ('1',  '1',    x"19"),
		  ('0',  '1',    x"66"),
		  ('1',  '1',    x"66"),
		  
		  ('0',  '1',    x"19"),
		  ('1',  '1',    x"19"),
		  ('0',  '1',    x"66"),
		  ('1',  '1',    x"66"),
		  
		  ('0',  '1',    x"19"),
		  ('1',  '1',    x"19"),
		  ('0',  '1',    x"66"),
		  ('1',  '1',    x"66"),
		  
		  ('0',  '0',    x"20"),
		  ('1',  '0',    x"20"),
		  ('0',  '0',    x"66"),
		  ('1',  '0',    x"66"),
		  
		  ('0',  '1',    x"21"),
		  ('1',  '1',    x"21"),
		  ('0',  '1',    x"67"),
		  ('1',  '1',    x"67")
		);
begin
	
	uut: component gc_dv_decode port map (
		vclk		=> vclk_tb,
		vphase		=> vphase_tb,
		vdata		=> vdata_tb,
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

			wait for period;
		end loop;
		
		wait;
	end process;
end behav;
