-- file: gc_dv_top_level.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_top_level is
	port(
		vclk			: in	std_logic;
		vphase			: in	std_logic;
		vdata			: in	std_logic_vector(7 downto 0);
		RGB_out_en		: in	std_logic;
		G_Y_DAC			: out	std_logic_vector(7 downto 0) := x"10";
		B_Cb_DAC		: out	std_logic_vector(7 downto 0) := x"80";
		R_Cr_DAC		: out	std_logic_vector(7 downto 0) := x"80";
		clk_DAC			: out	std_logic := '0';
		nC_sync_DAC		: out	std_logic := '0';
		nBlanking_DAC	: out	std_logic := '0'
	);
end entity;

architecture behav of gc_dv_top_level is
	signal pclk_decode		: std_logic;
	signal Y_decode			: std_logic_vector(7 downto 0);
	signal CbCr_decode		: std_logic_vector(7 downto 0);
	signal is_Cr_decode		: std_logic;
	signal is_odd_decode	: std_logic;
	signal H_sync_decode	: std_logic;
	signal V_sync_decode	: std_logic;
	signal C_sync_decode	: std_logic;
	signal Blanking_decode	: std_logic;
	signal dvalid_decode	: std_logic;
	signal pclk_444			: std_logic;
	signal Y_444			: std_logic_vector(7 downto 0);
	signal Cb_444			: std_logic_vector(7 downto 0);
	signal Cr_444			: std_logic_vector(7 downto 0);
	signal H_sync_444		: std_logic;
	signal V_sync_444		: std_logic;
	signal C_sync_444		: std_logic;
	signal Blanking_444		: std_logic;
	signal dvalid_444		: std_logic;
	signal pclk_CConv		: std_logic;
	signal G_Y_CConv		: std_logic_vector(7 downto 0);
	signal B_Cb_CConv		: std_logic_vector(7 downto 0);
	signal R_Cr_CConv		: std_logic_vector(7 downto 0);
	signal H_sync_CConv		: std_logic;
	signal V_sync_CConv		: std_logic;
	signal C_sync_CConv		: std_logic;
	signal Blanking_CConv	: std_logic;
	signal dvalid_CConv		: std_logic;

	component gc_dv_decode is
		port(
			vclk		: in	std_logic;
			vphase		: in	std_logic;
			vdata		: in	std_logic_vector(7 downto 0);
			pclk		: out	std_logic;
			Y			: out	std_logic_vector(7 downto 0);
			CbCr		: out	std_logic_vector(7 downto 0);
			is_Cr		: out	std_logic;
			is_odd		: out	std_logic;
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
	
	component gc_dv_YCbCr_to_RGB is
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
	end component;

	component gc_dv_video_DAC is
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
	end component;
begin
	frame_decode: component gc_dv_decode port map (
		vclk			=> vclk,
		vphase			=> vphase,
		vdata			=> vdata,
		pclk			=> pclk_decode,
		Y				=> Y_decode,
		CbCr			=> CbCr_decode,
		is_Cr			=> is_Cr_decode,
		is_odd			=> is_odd_decode,
		H_sync			=> H_sync_decode,
		V_sync			=> V_sync_decode,
		C_sync			=> C_sync_decode,
		Blanking		=> Blanking_decode,
		dvalid			=> dvalid_decode
	);

	chroma_upsampling: component gc_dv_422_to_444 port map (
		vclk			=> vclk,
		pclk			=> pclk_decode,
		Y				=> Y_decode,
		CbCr			=> CbCr_decode,
		is_Cr			=> is_Cr_decode,
		is_odd			=> is_odd_decode,
		H_sync			=> H_sync_decode,
		V_sync			=> V_sync_decode,
		C_sync			=> C_sync_decode,
		Blanking		=> Blanking_decode,
		dvalid			=> dvalid_decode,
		pclk_out		=> pclk_444,
		Y_out			=> Y_444,
		Cb_out			=> Cb_444,
		Cr_out			=> Cr_444,
		H_sync_out		=> H_sync_444,
		V_sync_out		=> V_sync_444,
		C_sync_out		=> C_sync_444,
		Blanking_out	=> Blanking_444,
		dvalid_out		=> dvalid_444
	);

	color_space_converter: component gc_dv_YCbCr_to_RGB port map (
		vclk			=> vclk,
		pclk			=> pclk_444,
		Y				=> Y_444,
		Cb				=> Cb_444,
		Cr				=> Cr_444,
		H_sync			=> H_sync_444,
		V_sync			=> V_sync_444,
		C_sync			=> C_sync_444,
		Blanking		=> Blanking_444,
		dvalid			=> dvalid_444,
		RGB_out_en		=> RGB_out_en,
		pclk_out		=> pclk_CConv,
		G_Y_out			=> G_Y_CConv,
		B_Cb_out		=> B_Cb_CConv,
		R_Cr_out		=> R_Cr_CConv,
		H_sync_out		=> H_sync_CConv,
		V_sync_out		=> V_sync_CConv,
		C_sync_out		=> C_sync_CConv,
		Blanking_out	=> Blanking_CConv,
		dvalid_out		=> dvalid_CConv
	);

	output_video_samples_to_DAC: component gc_dv_video_DAC port map (
		vclk			=> vclk,
		pclk			=> pclk_CConv,
		G_Y				=> G_Y_CConv,
		B_Cb			=> B_Cb_CConv,
		R_Cr			=> R_Cr_CConv,
		H_sync			=> H_sync_CConv,
		V_sync			=> V_sync_CConv,
		C_sync			=> C_sync_CConv,
		Blanking		=> Blanking_CConv,
		dvalid			=> dvalid_CConv,
		G_Y_DAC			=> G_Y_DAC,
		B_Cb_DAC		=> B_Cb_DAC,
		R_Cr_DAC		=> R_Cr_DAC,
		clk_DAC			=> clk_DAC,
		nC_sync_DAC		=> nC_sync_DAC,
		nBlanking_DAC	=> nBlanking_DAC
	);

end behav;
