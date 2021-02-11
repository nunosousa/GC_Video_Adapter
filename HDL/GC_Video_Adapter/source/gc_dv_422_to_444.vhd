-- file: gc_dv_422_to_444.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_422_to_444 is
	port(
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
		reset		: in	std_logic;
		Y_out		: out	std_logic_vector(7 downto 0);
		Cb_out		: out	std_logic_vector(7 downto 0);
		Cr_out		: out	std_logic_vector(7 downto 0);
		H_sync_out	: out	std_logic;
		V_sync_out	: out	std_logic;
		C_sync_out	: out	std_logic;
		Blanking_out: out	std_logic;
		dvalid_out	: out	std_logic
	);

end entity;

architecture behav of gc_dv_422_to_444 is
	-- Chroma samples
	signal Cb_sample		: std_logic_vector(7 downto 0) := x"80";
	signal Cr_sample		: std_logic_vector(7 downto 0) := x"80";
	
	-- Chroma flags
	signal Cb_loaded		: std_logic := '0';
	signal Cr_loaded		: std_logic := '0';
	
	-- Pipes for video samples and flags
	constant delay_plen		: natural := 2;
	type sample_array_type is array (natural range <>) of std_logic_vector(7 downto 0);
	signal Y_pipe			: sample_array_type(0 to delay_plen - 1) := (others => x"10");
	type flag_array_type is array (natural range <>) of std_logic;
	signal H_sync_pipe		: flag_array_type(0 to delay_plen - 1) := (others => '0');
	signal V_sync_pipe		: flag_array_type(0 to delay_plen - 1) := (others => '0');
	signal C_sync_pipe		: flag_array_type(0 to delay_plen - 1) := (others => '0');
	signal Blanking_pipe	: flag_array_type(0 to delay_plen - 1) := (others => '0');
	signal dvalid_pipe		: flag_array_type(0 to delay_plen - 1) := (others => '0');
	
begin
	duplicate_chroma_samples : process(pclk)
	begin
		if ((reset = '1') or (dvalid = '0')) then
			-- Reset pipes and flags
			Y_pipe <= (others => x"10");
			Cb_sample <= x"83";
			Cr_sample <= x"84";
			Y_out <= x"10";
			Cb_out <= x"80";
			Cr_out <= x"80";
			H_sync_out <= '0';
			V_sync_out <= '0';
			C_sync_out <= '0';
			Blanking_out <= '0';
			dvalid_out <= '0';
			Cb_loaded <= '0';
			Cr_loaded <= '0';
			
		elsif (rising_edge(pclk)) then
			-- Delay Y sample values and flags
			Y_pipe <= Y & Y_pipe(0 to delay_plen - 2);
			H_sync_pipe <= H_sync & H_sync_pipe(0 to delay_plen - 2);
			V_sync_pipe <= V_sync & V_sync_pipe(0 to delay_plen - 2);
			C_sync_pipe <= C_sync & C_sync_pipe(0 to delay_plen - 2);
			Blanking_pipe <= Blanking & Blanking_pipe(0 to delay_plen - 2);
			dvalid_pipe <= dvalid & dvalid_pipe(0 to delay_plen - 2);

			-- When both Cr and Cb samples are stored, shift them to output position.
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
			
			-- If blanking video, load both chroma samples with the same value
			if (Blanking = '1') then
				Cr_sample <= CbCr;
				Cb_sample <= CbCr;
				Cr_loaded <= '1';
				Cb_loaded <= '1';
			end if; -- if (Blanking = '1')
			
			---- Detect wrong chroma sample order.
			--if (is_odd = '1') then	-- If frame is odd, then first chroma sample is Cr
			--	if ((Cr_loaded = '0') and (Cb_loaded = '1')) then
			--		-- Wrong sequence - reset chroma pipe.
			--		Cb_loaded := '0';
			--	end if; -- if ((Cr_loaded = '0') and (Cb_loaded = '1'))
			--else					-- If frame is even, then first chroma sample is Cb
			--	if ((Cr_loaded = '1') and (Cb_loaded = '0')) then
			--		-- Wrong sequence - reset chroma pipe.
			--		Cr_loaded := '0';
			--	end if; -- if ((Cr_loaded = '1') and (Cb_loaded = '0'))
			--end if; -- if (is_odd = '1')

			-- Copy input samples to output, or in the absence of new chroma samples, replicate them
			Y_out <= Y_pipe(delay_plen - 1);
			H_sync_out <= H_sync_pipe(delay_plen - 1);
			V_sync_out <= V_sync_pipe(delay_plen - 1);
			C_sync_out <= C_sync_pipe(delay_plen - 1);
			Blanking_out <= Blanking_pipe(delay_plen - 1);
			dvalid_out <= dvalid_pipe(delay_plen - 1);
		end if;	-- if ((reset = '1') or (dvalid = '0'))
	end process; -- feed_sample_pipes : process(pclk)
end behav;
