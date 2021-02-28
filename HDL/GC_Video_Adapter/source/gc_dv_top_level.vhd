-- file: gc_dv_top_level.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_top_level is
	port(
		vclk			: in	std_logic;
		vphase			: in	std_logic;
		vdata			: in	std_logic_vector(7 downto 0);
		Y_DAC			: out	std_logic_vector(7 downto 0) := x"10";
		Cb_DAC			: out	std_logic_vector(7 downto 0) := x"80";
		Cr_DAC			: out	std_logic_vector(7 downto 0) := x"80";
		clk_DAC			: out	std_logic := '0';
		nC_sync_DAC		: out	std_logic := '0';
		nBlanking_DAC	: out	std_logic := '0'
	);
	
end entity;

architecture behav of gc_dv_top_level is
	component gc_dv_decode is
		port(
			vclk		: in	std_logic;
			vphase		: in	std_logic;
			vdata		: in	std_logic_vector(7 downto 0);
			pclk		: out	std_logic;
			Y			: out	std_logic_vector(7 downto 0);
			CbCr		: out	std_logic_vector(7 downto 0);
			is_Cr		: out	std_logic;
			H_sync		: out	std_logic;
			V_sync		: out	std_logic;
			C_sync		: out	std_logic;
			Blanking	: out	std_logic;
			dvalid		: out	std_logic
		);
	end component;

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
	
	component gc_dv_video_DAC is
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
			dvalid		: in	std_logic,
			Y_DAC			: out	std_logic_vector(7 downto 0);
			Cb_DAC			: out	std_logic_vector(7 downto 0);
			Cr_DAC			: out	std_logic_vector(7 downto 0);
			clk_DAC			: out	std_logic;
			nC_sync_DAC		: out	std_logic;
			nBlanking_DAC	: out	std_logic
		);
	end component;
begin
	frame_decode: component gc_dv_decode port map (
		vclk			=> vclk_tb,
		vphase			=> vphase_tb,
		vdata			=> vdata_tb,
		pclk			=> pclk_tb,
		Y				=> Y_tb,
		CbCr			=> CbCr_tb,
		is_Cr			=> is_Cr_tb,
		H_sync			=> H_sync_tb,
		V_sync			=> V_sync_tb,
		C_sync			=> C_sync_tb,
		Blanking		=> Blanking_tb,
		dvalid			=> dvalid_tb
	);
	
	chroma_upsampling: component gc_dv_422_to_444 port map (
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
		Y_out			=> Y_out_tb,
		Cb_out			=> Cb_out_tb,
		Cr_out			=> Cr_out_tb,
		H_sync_out		=> H_sync_out_tb,
		V_sync_out		=> V_sync_out_tb,
		C_sync_out		=> C_sync_out_tb,
		Blanking_out	=> Blanking_out_tb,
		dvalid_out		=> dvalid_out_tb
	);
	
	color_space_converter: component gc_dv_YCbCr_to_RGB  port map (
		Y				=> ,
		Cb				=> ,
		Cr				=> ,
		H_sync			=> ,
		V_sync			=> ,
		C_sync			=> ,
		Blanking		=> ,
		dvalid			=> ,
		R_out			=> ,
		G_out			=> ,
		B_out			=> ,
		H_sync_out		=> ,
		V_sync_out		=> ,
		C_sync_out		=> ,
		Blanking_out	=> ,
		dvalid_out		=> 
	);

end behav;
