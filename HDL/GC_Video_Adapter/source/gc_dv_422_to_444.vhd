-- file: gc_dv_422_to_444.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_422_to_444 is
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
		pclk_out	: out	std_logic := '0';
		Y_out		: out	std_logic_vector(7 downto 0) := x"10";
		Cb_out		: out	std_logic_vector(7 downto 0) := x"80";
		Cr_out		: out	std_logic_vector(7 downto 0) := x"80";
		H_sync_out	: out	std_logic := '0';
		V_sync_out	: out	std_logic := '0';
		C_sync_out	: out	std_logic := '0';
		Blanking_out: out	std_logic := '0';
		dvalid_out	: out	std_logic := '0'
	);
end entity;

architecture behav of gc_dv_422_to_444 is
	-- Chroma samples
	signal Cb_sample		: std_logic_vector(7 downto 0) := x"80";
	signal Cr_sample		: std_logic_vector(7 downto 0) := x"80";
	
	-- Chroma flags
	signal Cb_loaded		: std_logic := '0';
	signal Cr_loaded		: std_logic := '0';
	
	-- Pipes for luma samples and flags
	constant delay_plen		: natural := 2;
	type sample_array_type is array (natural range <>) of std_logic_vector(7 downto 0);
	signal Y_pipe			: sample_array_type(0 to delay_plen - 1) := (others => x"10");
	type flag_array_type is array (natural range <>) of std_logic;
	signal pclk_pipe		: flag_array_type(0 to delay_plen*2) := (others => '0');
	signal H_sync_pipe		: flag_array_type(0 to delay_plen - 1) := (others => '0');
	signal V_sync_pipe		: flag_array_type(0 to delay_plen - 1) := (others => '0');
	signal C_sync_pipe		: flag_array_type(0 to delay_plen - 1) := (others => '0');
	signal Blanking_pipe	: flag_array_type(0 to delay_plen - 1) := (others => '0');
	signal dvalid_pipe		: flag_array_type(0 to delay_plen - 1) := (others => '0');
	
	-- Retain previous pclk.
	signal last_pclk			: std_logic := '1';
	
begin
	duplicate_chroma_samples : process(vclk)
	begin
		if (rising_edge(vclk)) then
			-- Store copy of pclk
			last_pclk <= pclk;
			
			if (last_pclk /= pclk) then
				-- Delay pixel clock transitions
				pclk_pipe <= pclk & pclk_pipe(0 to delay_plen*2 - 1);
				pclk_out <= pclk_pipe(delay_plen*2);
			end if;

			if ((last_pclk = '0') and (pclk = '1')) then
				-- Delay Y sample values and flags
				Y_pipe <= Y & Y_pipe(0 to delay_plen - 2);
				H_sync_pipe <= H_sync & H_sync_pipe(0 to delay_plen - 2);
				V_sync_pipe <= V_sync & V_sync_pipe(0 to delay_plen - 2);
				C_sync_pipe <= C_sync & C_sync_pipe(0 to delay_plen - 2);
				Blanking_pipe <= Blanking & Blanking_pipe(0 to delay_plen - 2);
				dvalid_pipe <= dvalid & dvalid_pipe(0 to delay_plen - 2);
	
				-- Copy delayed samples to output
				Y_out <= Y_pipe(delay_plen - 1);
				H_sync_out <= H_sync_pipe(delay_plen - 1);
				V_sync_out <= V_sync_pipe(delay_plen - 1);
				C_sync_out <= C_sync_pipe(delay_plen - 1);
				Blanking_out <= Blanking_pipe(delay_plen - 1);
				dvalid_out <= dvalid_pipe(delay_plen - 1);
				
				-- When both Cr and Cb samples are stored, shift them to output.
				if ((Cr_loaded = '1') and (Cb_loaded = '1')) then
					Cr_out <= Cr_sample;
					Cb_out <= Cb_sample;
					Cr_loaded <= '0';
					Cb_loaded <= '0';
				end if; -- if ((Cr_loaded = '1') and (Cb_loaded = '1'))
				
				-- Separate Cb and Cr sample values.
				if (is_Cr = '1') then
					Cr_sample <= CbCr;
					Cr_loaded <= '1';
				else
					Cb_sample <= CbCr;
					Cb_loaded <= '1';
				end if; -- if (is_Cr = '1')
				
				-- If incoming data is in blanking state, set defaults
				if (Blanking = '1') then
					Cr_sample <= x"80";
					Cb_sample <= x"80";
					Cr_loaded <= '1';
					Cb_loaded <= '1';
				end if; -- if (Blanking = '1')
			end if; -- if ((last_pclk = '0') and (pclk = '1'))
		end if;	-- if (rising_edge(vclk))
	end process; -- duplicate_chroma_samples : process(pclk)
end behav;
