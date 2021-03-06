-- file: gc_dv_video_DAC.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_video_DAC is
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
end entity;

architecture behav of gc_dv_video_DAC is
	-- Retain previous pclk.
	signal last_pclk			: std_logic := '0';
begin
	duplicate_chroma_samples : process(vclk)
	begin
		if (rising_edge(vclk)) then
			if (last_pclk /= pclk) then
				-- Delay pixel clock transitions
				last_pclk <= pclk;
				clk_DAC <= last_pclk;
			end if;

			if ((last_pclk = '0') and (pclk = '1')) then
				G_Y_DAC <= G_Y;
				B_Cb_DAC <= B_Cb;
				R_Cr_DAC <= R_Cr;
				nC_sync_DAC <= not C_sync;
				nBlanking_DAC <= not Blanking;
			end if; -- if ((last_pclk = '0') and (pclk = '1'))
		end if;	-- if (rising_edge(vclk))
	end process; -- duplicate_chroma_samples : process(pclk)
end behav;
