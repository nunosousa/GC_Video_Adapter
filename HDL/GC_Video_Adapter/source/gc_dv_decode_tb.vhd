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
	
begin
	
	u1: gc_dv_decode port map (
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
	
	
end behav;
