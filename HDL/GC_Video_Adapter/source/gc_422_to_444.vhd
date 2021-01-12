-- file: gc_422_to_444.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_422_to_444 is
   generic(
		fcoefs		: integer_vector := (1, 1)
   );
	port(
		pclk		: in	std_logic;
		Y_in		: in	std_logic_vector(7 downto 0);
		CbCr_in		: in	std_logic_vector(7 downto 0);
		is_Cr_in	: in	std_logic;
		H_sync_in	: in	std_logic;
		V_sync_in	: in	std_logic;
		C_sync_in	: in	std_logic;
		Blanking_in	: in	std_logic;
		dvalid_in	: in	std_logic;
		reset		: in	std_logic;
		Y_out		: out	std_logic_vector(7 downto 0);
		Cb_out		: out	std_logic_vector(7 downto 0);
		Cr_out		: out	std_logic_vector(7 downto 0);
		H_sync_out	: out	std_logic;
		V_sync_out	: out	std_logic;
		C_sync_out	: out	std_logic;
		dvalid_out	: out	std_logic
	);
	
end entity;

architecture behav of gc_422_to_444 is
begin
	process : process(pclk)
	begin
		if (reset = '1') then
			-- Reset something
		elsif (rising_edge(pclk)) then
			if (dvalid_in = '1') then
			
			end if;
		end if;	-- if (reset = '1')
	end process;
end behav;
