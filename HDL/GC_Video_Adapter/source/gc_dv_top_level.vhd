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
			RGB_out		: in	std_logic;
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
		pclk			=> ,
		Y				=> ,
		CbCr			=> ,
		is_Cr			=> ,
		is_odd			=> ,
		H_sync			=> ,
		V_sync			=> ,
		C_sync			=> ,
		Blanking		=> ,
		dvalid			=> 
	);
	
	chroma_upsampling: component gc_dv_422_to_444 port map (
		vclk			=> vclk,
		pclk			=> ,
		Y				=> ,
		CbCr			=> ,
		is_Cr			=> ,
		is_odd			=> ,
		H_sync			=> ,
		V_sync			=> ,
		C_sync			=> ,
		Blanking		=> ,
		dvalid			=> ,
		pclk_out		=> ,
		Y_out			=> ,
		Cb_out			=> ,
		Cr_out			=> ,
		H_sync_out		=> ,
		V_sync_out		=> ,
		C_sync_out		=> ,
		Blanking_out	=> ,
		dvalid_out		=> 
	);
	
	color_space_converter: component gc_dv_YCbCr_to_RGB port map (
		vclk			=> vclk,
		pclk			=> ,
		Y				=> ,
		Cb				=> ,
		Cr				=> ,
		H_sync			=> ,
		V_sync			=> ,
		C_sync			=> ,
		Blanking		=> ,
		dvalid			=> ,
		RGB_out_en		=> RGB_out_en,
		pclk_out		=> ,
		G_Y_out			=> ,
		B_Cb_out		=> ,
		R_Cr_out		=> ,
		H_sync_out		=> ,
		V_sync_out		=> ,
		C_sync_out		=> ,
		Blanking_out	=> ,
		dvalid_out		=> 
	);
	
	output_video_samples_to_DAC: component gc_dv_video_DAC port map (
		vclk			=> vclk,
		pclk			=> ,
		G_Y				=> ,
		B_Cb			=> ,
		R_Cr			=> ,
		H_sync			=> ,
		V_sync			=> ,
		C_sync			=> ,
		Blanking		=> ,
		dvalid			=> ,
		G_Y_DAC			=> G_Y_DAC,
		B_Cb_DAC		=> B_Cb_DAC,
		R_Cr_DAC		=> R_Cr_DAC,
		clk_DAC			=> clk_DAC,
		nC_sync_DAC		=> nC_sync_DAC,
		nBlanking_DAC	=> nBlanking_DAC
	);

end behav;
