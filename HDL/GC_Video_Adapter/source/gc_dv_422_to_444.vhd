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
	-- FIR filter configuration
	constant fcoef_width	: integer := 12; -- Bit width of the filter coefficients including sign bit.
	constant data_width		: integer := 8;
	type fcoefs_type is array (natural range <>) of signed((fcoef_width - 1) downto 0);
	constant fcoefs			: fcoefs_type := (
												to_signed(-4, fcoef_width),
												to_signed(6, fcoef_width),
												to_signed(-12, fcoef_width),
												to_signed(20, fcoef_width),
												to_signed(-32, fcoef_width),
												to_signed(48, fcoef_width),
												to_signed(-70, fcoef_width),
												to_signed(104, fcoef_width),
												to_signed(-152, fcoef_width),
												to_signed(236, fcoef_width),
												to_signed(-420, fcoef_width),
												to_signed(1300, fcoef_width)); -- (index [n] to index [0])
	constant fcoef_taps		: integer := 12;
	constant fnorm_shift	: integer := 11; -- Bit shifts required to perform division by 2048.
	constant Y_plen			: integer := 4*fcoef_taps;
	constant CbCr_plen		: integer := 2*fcoef_taps;
	constant latency		: integer := 0;
	
	-- Pipes for video samples
	type sample_array_type is array (natural range <>) of unsigned((data_width - 1) downto 0);
	signal Y_pipe			: sample_array_type(0 to Y_plen - 1) := (others => x"10");
	signal Cb_pipe			: sample_array_type(0 to CbCr_plen - 1) := (others => x"80");
	signal Cr_pipe			: sample_array_type(0 to CbCr_plen - 1) := (others => x"80");
	
	-- Chroma samples ordering flags
	signal sample_ready		: std_logic := '0';
	
	-- Processed chroma samples
	signal Cb_processed		: unsigned(7 downto 0);
	signal Cr_processed		: unsigned(7 downto 0);

begin
	feed_sample_pipes : process(pclk)
		variable Cb_loaded		: std_logic := '0';
		variable Cr_loaded		: std_logic := '0';
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
			Y_pipe <= unsigned(Y) & Y_pipe(0 to Y_plen - 2);
			
			-- Delay and separate Cb and Cr sample values.
			if (is_Cr = '1') then
				Cr_pipe <= unsigned(CbCr) & Cr_pipe(0 to CbCr_plen - 2);
				Cr_loaded := '1';
			else
				Cb_pipe <= unsigned(CbCr) & Cb_pipe(0 to CbCr_plen - 2);
				Cb_loaded := '1';
			end if; -- if (is_Cr = '1')
			
			-- When both Cr and Cb samples are stored, flag them as ready.
			if ((Cr_loaded = '1') and (Cb_loaded = '1')) then
				sample_ready <= '1';
				Cb_loaded := '0';
				Cr_loaded := '0';
			end if; -- if ((Cr_loaded = '1') and (Cb_loaded = '1'))
			
			-- Detect wrong chroma sample order.
			if (is_odd = '1') then	-- If frame is odd, then first chroma sample is Cr
				if ((Cr_loaded = '0') and (Cb_loaded = '1')) then
					-- Wrong sequence - reset pipes.
					sample_ready <= '0';
					Cb_loaded := '0';
					Y_pipe <= (others => x"10");
					Cb_pipe <= (others => x"80");
					Cr_pipe <= (others => x"80");
				end if; -- if ((Cr_loaded = '0') and (Cb_loaded = '1'))
			else					-- If frame is even, then first chroma sample is Cb
				if ((Cr_loaded = '1') and (Cb_loaded = '0')) then
					-- Wrong sequence - reset pipes.
					sample_ready <= '0';
					Cr_loaded := '0';
					Y_pipe <= (others => x"10");
					Cb_pipe <= (others => x"80");
					Cr_pipe <= (others => x"80");
				end if; -- if ((Cr_loaded = '1') and (Cb_loaded = '0'))
			end if; -- if (is_odd = '1')
		end if;	-- if ((reset = '1') or (dvalid = '0'))
	end process; -- feed_sample_pipes : process(pclk)

	-- 
	fir_filter : process(pclk)
		variable Cb_filter_products	: signed(((fcoef_width + data_width + 1) - 1) downto 0);
		variable Cr_filter_products	: signed(((fcoef_width + data_width + 1) - 1) downto 0);
		variable Cb_filter_sum		: signed(((fcoef_width + data_width + 1 + fcoef_taps - 1) - 1) downto 0);
		variable Cr_filter_sum		: signed(((fcoef_width + data_width + 1 + fcoef_taps - 1) - 1) downto 0);
		variable Cb_norm_result		: signed(((fcoef_width + data_width + 1 + fcoef_taps - 1 - fnorm_shift) - 1) downto 0);
		variable Cr_norm_result		: signed(((fcoef_width + data_width + 1 + fcoef_taps - 1 - fnorm_shift) - 1) downto 0);
	begin
		if ((reset = '1') or (dvalid = '0')) then
			-- 
			
		elsif (rising_edge(pclk)) then
			if (sample_ready = '1') then
				sample_ready <= '0';
				
				-- Perform the filter coefficient multiplication and partial sum of symmetric terms
				for i in 0 to (fcoef_taps - 1) loop
					Cb_filter_products(i) := (Cb_pipe(i) + Cb_pipe(2*fcoef_taps - 1 - i)) * fcoefs(i);
					Cr_filter_products(i) := (Cr_pipe(i) + Cr_pipe(2*fcoef_taps - 1 - i)) * fcoefs(i);
				end loop;
				
				-- Sum all multiplication results
				Cb_filter_sum := (others => 0);
				Cr_filter_sum := (others => 0);
				for i in 0 to (fcoef_taps - 1) loop
					Cb_filter_sum := Cb_filter_sum + Cb_filter_products(i);
					Cr_filter_sum := Cr_filter_sum + Cr_filter_products(i);
				end loop;
				
				-- Perform normalizing division (using bit shifting)
				Cb_norm_result <= shift_right(Cb_filter_sum, fnorm_shift);
				Cr_norm_result <= shift_right(Cr_filter_sum, fnorm_shift);
				
				-- Truncate result
				if (Cb_norm_result > 255) then
					Cb_processed <= 255;
				elsif  (Cb_norm_result < 0) then
					Cb_processed <= 0;
				else
					Cb_processed <= unsigned(resize(Cb_norm_result, 8));
				end if;
				
				if (Cr_norm_result > 255) then
					Cr_processed <= 255;
				elsif  (Cr_norm_result < 0) then
					Cr_processed <= 0;
				else
					Cr_processed <= unsigned(resize(Cr_norm_result, 8));
				end if;
			end if; -- if (sample_ready = '0')
		end if;	-- if ((reset = '1') or (dvalid = '0'))
	end process; -- fir_filter : process(pclk)

	-- 
	generate_output_samples : process(pclk)
	begin
		if (rising_edge(pclk)) then
			Y_dly <= Y_pipe();
			if (tbd) then
				Cb_flt <= Cb_processed;
				Cr_flt <= Cr_processed;
			else
				Cb_flt <= Cb_pipe();
				Cr_flt <= Cr_pipe();
			end if;
		end if;
	end process; -- generate_output_samples : process(pclk)

end behav;
