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
		Y_dly		: out	std_logic_vector(7 downto 0);
		Cb_flt		: out	std_logic_vector(7 downto 0);
		Cr_flt		: out	std_logic_vector(7 downto 0);
		H_sync_dly	: out	std_logic;
		V_sync_dly	: out	std_logic;
		C_sync_dly	: out	std_logic;
		dvalid_dly	: out	std_logic
	);

end entity;

architecture behav of gc_dv_422_to_444 is
	-- FIR filter constants
	type fcoefs_type is array (natural range <>) of signed(7 downto 0);
	constant fcoefs		: fcoefs_type := (1, 1); -- Enter here the filter coefficients
	constant fcoef_taps	: integer := fcoefs'range;
	constant Y_plen		: integer := 4*fcoefs'range;
	constant CbCr_plen	: integer := 2*fcoefs'range;
	constant latency	: integer;
	
	-- Pipes for video samples
	signal Y_pipe		: is array(0 to Y_plen - 1) of unsigned(7 downto 0) := (others => x"10");
	signal Cb_pipe		: is array(0 to CbCr_plen - 1) of unsigned(7 downto 0) := (others => x"80");
	signal Cr_pipe		: is array(0 to CbCr_plen - 1) of unsigned(7 downto 0) := (others => x"80");
	
	-- Chroma samples ordering flags
	signal sample_ready	: std_logic := '0';
	variable Cb_loaded	: std_logic := '0';
	variable Cr_loaded	: std_logic := '0';

begin
	feed_sample_pipes : process(pclk)
	begin
		if ((reset = '1') or (dvalid = '0')) then
			-- Reset pipes.
			Y_pipe <= (others => x"10");
			Cb_pipe <= (others => x"80");
			Cr_pipe <= (others => x"80");
			sample_ready <= '0';
			Cb_loaded := '0';
			Cr_loaded := '0';
			
		elsif (rising_edge(pclk)) then
			-- Delay Y sample values
			Y_pipe <= Y & Y_pipe(0 to Y_plen - 2);
			
			-- Delay and separate Cb and Cr sample values.
			if (is_Cr = '1') then
				Cr_pipe <= CbCr & Cr_pipe(0 to CbCr_plen - 2);
				Cr_loaded := '1';
			else
				Cb_pipe <= CbCr & Cb_pipe(0 to CbCr_plen - 2);
				Cb_loaded := '1';
			end if; -- if (is_Cr = '1')
			
			-- When both Cr and Cb samples are stored, flag them as ready.
			if ((Cr_loaded = '1') and (Cb_loaded = '1')) then
				sample_ready <= '1';
				Cb_loaded := '0';
				Cr_loaded := '0';
			else
				sample_ready <= '0';
			end if; -- if ((Cr_loaded = '1') and (Cb_loaded = '1'))
			
			-- Detect wrong chroma sample order.
			if (is_odd = '1') then	-- If frame is odd, then first chroma sample is Cr
				if ((Cr_loaded = '0') and (Cb_loaded = '1')) then
					-- Wrong sequence - reset pipes.
					Y_pipe <= (others => x"10");
					Cb_pipe <= (others => x"80");
					Cr_pipe <= (others => x"80");
				end if; -- if ((Cr_loaded = '0') and (Cb_loaded = '1'))
			else					-- If frame is even, then first chroma sample is Cb
				if ((Cr_loaded = '1') and (Cb_loaded = '0')) then
					-- Wrong sequence - reset pipes.
					Y_pipe <= (others => x"10");
					Cb_pipe <= (others => x"80");
					Cr_pipe <= (others => x"80");
				end if; -- if ((Cr_loaded = '1') and (Cb_loaded = '0'))
			end if; -- if (is_odd = '1')
		end if;	-- if ((reset = '1') or (dvalid = '0'))
	end process; -- feed_sample_pipes : process(pclk)

	-- 
	feed_sample_pipes : process(pclk)
		variable filter_sum	: signed();
	begin
		if ((reset = '1') or (dvalid = '0')) then
			-- 
			
		elsif (rising_edge(pclk)) then
			-- 
			filter_sum := (others => '0');
			for i in 0 to (fcoef_taps - 1) loop
				filter_sum := filter_sum + filter_products(i);
			end loop;
			
			--
			for i in 0 to (fcoef_taps - 1) loop
				Cb_filter_products(i) <= Cb_pipe(i) * fcoefs(fcoef_taps - i - 1);
				Cb_filter_products(CbCr_plen - i - 1) <= Cb_pipe(i) * fcoefs(i);
			end loop;
			
			--
			if (filter_sum > x"FF") then
				filter_sum = x"FF";
			elsif  (filter_sum < 0) then
				filter_sum = 0;
			end if;
			
		end if;	-- if ((reset = '1') or (dvalid = '0'))
	end process; -- feed_sample_pipes : process(pclk)
end behav;
