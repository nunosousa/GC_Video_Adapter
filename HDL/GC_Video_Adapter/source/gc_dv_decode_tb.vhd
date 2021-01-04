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
	signal vclk_tb		: in	std_logic;
	signal vphase_tb	: in	std_logic;
	signal vdata_tb		: in	std_logic_vector(7 downto 0);
	signal reset_tb		: in	std_logic;
	signal pclk_tb		: out	std_logic;
	signal Y_tb			: out	std_logic_vector(7 downto 0);
	signal CbCr_tb		: out	std_logic_vector(7 downto 0);
	signal is_Cr_tb		: out	std_logic;
	signal H_sync_tb	: out	std_logic;
	signal V_sync_tb	: out	std_logic;
	signal C_sync_tb	: out	std_logic;
	signal Blanking_tb	: out	std_logic;
	signal dvalid_tb	: out	std_logic;
	
	-- declare record type
	type test_vector is record
		a, b : std_logic;
		sum, carry : std_logic;
	end record; 

	type test_vector_array is array (natural range <>) of test_vector;
	constant test_vectors : test_vector_array := (
		-- a, b, sum , carry   -- positional method is used below
		('0', '0', '0', '0'), -- or (a => '0', b => '0', sum => '0', carry => '0')
		('0', '1', '1', '0'),
		('1', '0', '1', '0'),
		('1', '1', '0', '1'),
		('0', '1', '0', '1')  -- fail test
		);
	
begin
	
	uut: gc_dv_decode port map (
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
		dvalid		=> dvalid_tb );
	
	tb1 : process
		constant period: time := 20 ns;
	begin
		for i in test_vectors'range loop
			a <= test_vectors(i).a;  -- signal a = i^th-row-value of test_vector's a
			b <= test_vectors(i).b;

			wait for period;

			assert ( 
				(sum = test_vectors(i).sum) and 
				(carry = test_vectors(i).carry) 
				)

			-- image is used for string-representation of integer etc.
			report "test_vector " & integer'image(i) & " failed " & 
				" for input a = " & std_logic'image(a) & 
				" and b = " & std_logic'image(b)
				severity error;
		end loop;
		
		wait;
		
	end process; 
	
end behav;
