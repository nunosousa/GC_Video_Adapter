-- file: gc_dv_YCbCr_to_RGB.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_YCbCr_to_RGB is
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
end entity;

architecture behav of gc_dv_YCbCr_to_RGB is
	
begin
	process : process(vclk)
	begin
		if (rising_edge(vclk)) then
			-- If RGB output is enabled, then perform conversion
			if (RGB_out_en = '1') then
				-- tbd
			else -- Output YCbCr samples
				pclk_out <= pclk;
				G_Y_out <= Y;
				B_Cb_out <= Cb;
				R_Cr_out <= Cr;
				H_sync_out <= H_sync;
				V_sync_out <= V_sync;
				C_sync_out <= C_sync;
				Blanking_out <= Blanking;
				dvalid_out <= dvalid;
			end if; -- if (RGB_out_en = '1')
		end if;	-- if (rising_edge(vclk))
	end process;
end behav;
