-- file: gc_dv_422_to_444_tb.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_422_to_444_tb is
end entity;

architecture behav of gc_dv_422_to_444_tb is
	component gc_dv_422_to_444 is
		port(
			vclk		: in	std_logic;
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
			pclk_out	: out	std_logic;
			Y_out		: out	std_logic_vector(7 downto 0);
			Cb_out		: out	std_logic_vector(7 downto 0);
			Cr_out		: out	std_logic_vector(7 downto 0);
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
	signal CbCr_tb			: std_logic_vector(7 downto 0);
	signal is_Cr_tb			: std_logic;
	signal is_odd_tb		: std_logic;
	signal H_sync_tb		: std_logic;
	signal V_sync_tb		: std_logic;
	signal C_sync_tb		: std_logic;
	signal Blanking_tb		: std_logic;
	signal dvalid_tb		: std_logic;
	signal pclk_out_tb		: std_logic;
	signal Y_out_tb			: std_logic_vector(7 downto 0);
	signal Cb_out_tb		: std_logic_vector(7 downto 0);
	signal Cr_out_tb		: std_logic_vector(7 downto 0);
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
		CbCr_tb			: std_logic_vector(7 downto 0);
		is_Cr_tb		: std_logic;
		is_odd_tb		: std_logic;
		H_sync_tb		: std_logic;
		V_sync_tb		: std_logic;
		C_sync_tb		: std_logic;
		Blanking_tb		: std_logic;
		dvalid_tb		: std_logic;
	end record;

	type test_vector_array is array (natural range <>) of test_vector;
	constant test_vectors : test_vector_array := (
		-- vclk	pclk,	Y,		CbCr,	is_Cr,	is_odd,	H_sync,	V_sync,	C_sync,	Blanking,	dvalid
		  ('0',	'0',	x"00",	x"00",	'1',	'0',	'1',	'0',	'0',	'0',		'1'), -- Test normal 4:2:2 to 4:4:4
		  ('1',	'0',	x"00",	x"00",	'1',	'0',	'1',	'0',	'0',	'0',		'1'),
		  ('0',	'1',	x"00",	x"00",	'1',	'0',	'1',	'0',	'0',	'0',		'1'), -- upsampling (with chroma duplication)
		  ('1',	'1',	x"00",	x"00",	'1',	'0',	'1',	'0',	'0',	'0',		'1'),
		  ('0',	'0',	x"01",	x"01",	'0',	'0',	'0',	'1',	'0',	'0',		'1'), -- and test luma and flags correct delay.
		  ('1',	'0',	x"01",	x"01",	'0',	'0',	'0',	'1',	'0',	'0',		'1'),
		  ('0',	'1',	x"01",	x"01",	'0',	'0',	'0',	'1',	'0',	'0',		'1'),
		  ('1',	'1',	x"01",	x"01",	'0',	'0',	'0',	'1',	'0',	'0',		'1'),
		  ('0',	'0',	x"02",	x"02",	'1',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('1',	'0',	x"02",	x"02",	'1',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('0',	'1',	x"02",	x"02",	'1',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('1',	'1',	x"02",	x"02",	'1',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('0',	'0',	x"04",	x"04",	'0',	'0',	'0',	'0',	'0',	'1',		'1'),
		  ('1',	'0',	x"04",	x"04",	'0',	'0',	'0',	'0',	'0',	'1',		'1'),
		  ('0',	'1',	x"04",	x"04",	'0',	'0',	'0',	'0',	'0',	'1',		'1'),
		  ('1',	'1',	x"04",	x"04",	'0',	'0',	'0',	'0',	'0',	'1',		'1'),
		  ('0',	'0',	x"08",	x"08",	'1',	'0',	'0',	'0',	'0',	'0',		'0'),
		  ('1',	'0',	x"08",	x"08",	'1',	'0',	'0',	'0',	'0',	'0',		'0'),
		  ('0',	'1',	x"08",	x"08",	'1',	'0',	'0',	'0',	'0',	'0',		'0'),
		  ('1',	'1',	x"08",	x"08",	'1',	'0',	'0',	'0',	'0',	'0',		'0'),
		  ('0',	'0',	x"10",	x"10",	'0',	'0',	'0',	'0',	'0',	'1',		'1'),
		  ('1',	'0',	x"10",	x"10",	'0',	'0',	'0',	'0',	'0',	'1',		'1'),
		  ('0',	'1',	x"10",	x"10",	'0',	'0',	'0',	'0',	'0',	'1',		'1'),
		  ('1',	'1',	x"10",	x"10",	'0',	'0',	'0',	'0',	'0',	'1',		'1'),
		  ('0',	'0',	x"20",	x"20",	'1',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('1',	'0',	x"20",	x"20",	'1',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('0',	'1',	x"20",	x"20",	'1',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('1',	'1',	x"20",	x"20",	'1',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('0',	'0',	x"40",	x"40",	'0',	'0',	'0',	'1',	'0',	'0',		'1'),
		  ('1',	'0',	x"40",	x"40",	'0',	'0',	'0',	'1',	'0',	'0',		'1'),
		  ('0',	'1',	x"40",	x"40",	'0',	'0',	'0',	'1',	'0',	'0',		'1'),
		  ('1',	'1',	x"40",	x"40",	'0',	'0',	'0',	'1',	'0',	'0',		'1'),
		  ('0',	'0',	x"80",	x"80",	'1',	'0',	'1',	'0',	'0',	'0',		'1'),
		  ('1',	'0',	x"80",	x"80",	'1',	'0',	'1',	'0',	'0',	'0',		'1'),
		  ('0',	'1',	x"80",	x"80",	'1',	'0',	'1',	'0',	'0',	'0',		'1'),
		  ('1',	'1',	x"80",	x"80",	'1',	'0',	'1',	'0',	'0',	'0',		'1'),
		  ('0',	'0',	x"81",	x"81",	'0',	'0',	'0',	'0',	'0',	'0',		'1'),
		  ('1',	'0',	x"81",	x"81",	'0',	'0',	'0',	'0',	'0',	'0',		'1'),
		  ('0',	'1',	x"81",	x"81",	'0',	'0',	'0',	'0',	'0',	'0',		'1'),
		  ('1',	'1',	x"81",	x"81",	'0',	'0',	'0',	'0',	'0',	'0',		'1'),
		  
		  ('0',	'0',	x"00",	x"00",	'0',	'0',	'1',	'0',	'0',	'0',		'1'), -- Test change from Cr first
		  ('1',	'0',	x"00",	x"00",	'0',	'0',	'1',	'0',	'0',	'0',		'1'),
		  ('0',	'1',	x"00",	x"00",	'0',	'0',	'1',	'0',	'0',	'0',		'1'), -- to Cb first.
		  ('1',	'1',	x"00",	x"00",	'0',	'0',	'1',	'0',	'0',	'0',		'1'),
		  ('0',	'0',	x"01",	x"01",	'1',	'0',	'0',	'1',	'0',	'0',		'1'),
		  ('1',	'0',	x"01",	x"01",	'1',	'0',	'0',	'1',	'0',	'0',		'1'),
		  ('0',	'1',	x"01",	x"01",	'1',	'0',	'0',	'1',	'0',	'0',		'1'),
		  ('1',	'1',	x"01",	x"01",	'1',	'0',	'0',	'1',	'0',	'0',		'1'),
		  
		  ('0',	'0',	x"02",	x"02",	'0',	'0',	'0',	'0',	'1',	'0',		'1'), -- Test incorrect sequence
		  ('1',	'0',	x"02",	x"02",	'0',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('0',	'1',	x"02",	x"02",	'0',	'0',	'0',	'0',	'1',	'0',		'1'), -- of chroma samples.
		  ('1',	'1',	x"02",	x"02",	'0',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('0',	'0',	x"10",	x"10",	'0',	'0',	'1',	'0',	'0',	'0',		'1'),
		  ('1',	'0',	x"10",	x"10",	'0',	'0',	'1',	'0',	'0',	'0',		'1'),
		  ('0',	'1',	x"10",	x"10",	'0',	'0',	'1',	'0',	'0',	'0',		'1'),
		  ('1',	'1',	x"10",	x"10",	'0',	'0',	'1',	'0',	'0',	'0',		'1'),
		  ('0',	'0',	x"20",	x"20",	'1',	'0',	'0',	'1',	'0',	'0',		'1'),
		  ('1',	'0',	x"20",	x"20",	'1',	'0',	'0',	'1',	'0',	'0',		'1'),
		  ('0',	'1',	x"20",	x"20",	'1',	'0',	'0',	'1',	'0',	'0',		'1'),
		  ('1',	'1',	x"20",	x"20",	'1',	'0',	'0',	'1',	'0',	'0',		'1'),
		  ('0',	'0',	x"40",	x"40",	'0',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('1',	'0',	x"40",	x"40",	'0',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('0',	'1',	x"40",	x"40",	'0',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('1',	'1',	x"40",	x"40",	'0',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('0',	'0',	x"80",	x"80",	'1',	'0',	'0',	'0',	'0',	'1',		'1'),
		  ('1',	'0',	x"80",	x"80",	'1',	'0',	'0',	'0',	'0',	'1',		'1'),
		  ('0',	'1',	x"80",	x"80",	'1',	'0',	'0',	'0',	'0',	'1',		'1'),
		  ('1',	'1',	x"80",	x"80",	'1',	'0',	'0',	'0',	'0',	'1',		'1'),
		  ('0',	'0',	x"00",	x"00",	'0',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('1',	'0',	x"00",	x"00",	'0',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('0',	'1',	x"00",	x"00",	'0',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('1',	'1',	x"00",	x"00",	'0',	'0',	'0',	'0',	'1',	'0',		'1'),
		  ('0',	'0',	x"00",	x"00",	'1',	'0',	'0',	'0',	'0',	'1',		'1'),
		  ('1',	'0',	x"00",	x"00",	'1',	'0',	'0',	'0',	'0',	'1',		'1'),
		  ('0',	'1',	x"00",	x"00",	'1',	'0',	'0',	'0',	'0',	'1',		'1'),
		  ('1',	'1',	x"00",	x"00",	'1',	'0',	'0',	'0',	'0',	'1',		'1')
		);
begin
	uut: component gc_dv_422_to_444 port map (
		vclk			=> vclk_tb,
		pclk			=> pclk_tb,
		Y				=> Y_tb,
		CbCr			=> CbCr_tb,
		is_Cr			=> is_Cr_tb,
		is_odd			=> is_odd_tb,
		H_sync			=> H_sync_tb,
		V_sync			=> V_sync_tb,
		C_sync			=> C_sync_tb,
		Blanking		=> Blanking_tb,
		dvalid			=> dvalid_tb,
		pclk_out		=> pclk_out_tb,
		Y_out			=> Y_out_tb,
		Cb_out			=> Cb_out_tb,
		Cr_out			=> Cr_out_tb,
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
			CbCr_tb <= test_vectors(i).CbCr_tb;
			is_Cr_tb <= test_vectors(i).is_Cr_tb;
			is_odd_tb <= test_vectors(i).is_odd_tb;
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
