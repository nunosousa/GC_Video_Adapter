-- file: gc_dv_YCbCr_to_RGB.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_YCbCr_to_RGB is
	port(
		Y			: in	std_logic_vector(7 downto 0);
		Cb			: in	std_logic_vector(7 downto 0);
		Cr			: in	std_logic_vector(7 downto 0);
		H_sync		: in	std_logic;
		V_sync		: in	std_logic;
		C_sync		: in	std_logic;
		Blanking	: in	std_logic;
		dvalid		: in	std_logic,
		R_out		: out	std_logic_vector(7 downto 0);
		G_out		: out	std_logic_vector(7 downto 0);
		B_out		: out	std_logic_vector(7 downto 0);
		H_sync_out	: out	std_logic;
		V_sync_out	: out	std_logic;
		C_sync_out	: out	std_logic;
		Blanking_out: out	std_logic;
		dvalid_out	: out	std_logic
	);
end entity;

architecture behav of gc_dv_YCbCr_to_RGB is
	
begin
	process : process(pclk)
	begin
		if (rising_edge(pclk)) then
		
		end if;	-- if (rising_edge(pclk))
	end process;
end behav;
