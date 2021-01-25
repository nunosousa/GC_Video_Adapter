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
	constant fcoef_width	: natural := 12; -- Bit width of the filter coefficients including sign bit.
	constant data_width		: natural := 8;
	type fcoefs_type is array (natural range <>) of signed((fcoef_width - 1) downto 0);
	constant fcoefs			: fcoefs_type := (	to_signed(-4, fcoef_width),		-- FIR coefficient at index +n/-n sample
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
												to_signed(1300, fcoef_width));	-- FIR coefficient at index +1/-1 sample
	constant fcoef_taps		: natural := 12;
	constant fnorm_shift	: natural := 11; -- Bit shifts required to perform division by 2048.
	
	-- Pipes for video samples
	type sample_array_type is array (natural range <>) of unsigned((data_width - 1) downto 0);
	constant CbCr_fplen		: natural := 2*fcoef_taps;
	signal Cb_fpipe			: sample_array_type(0 to CbCr_fplen - 1) := (others => x"80");
	signal Cr_fpipe			: sample_array_type(0 to CbCr_fplen - 1) := (others => x"80");
	constant latency		: natural := 2; -- FIR filter processing sample delay
	constant Y_plen			: natural := CbCr_fplen + latency;
	signal Y_pipe			: sample_array_type(0 to Y_plen - 1) := (others => x"10");
	signal Cb_outpipe		: sample_array_type(0 to latency - 1) := (others => x"80");
	signal Cr_outpipe		: sample_array_type(0 to latency - 1) := (others => x"80");
	
	-- Chroma samples ordering flags
	signal CbCr_raw_sample_ready	: std_logic := '0';
	signal CbCr_filt_sample_ready	: std_logic := '0';
	
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
			Cb_fpipe <= (others => x"80");
			Cr_fpipe <= (others => x"80");
			CbCr_raw_sample_ready <= '0';
			Cb_loaded := '0';
			Cr_loaded := '0';
			
		elsif (rising_edge(pclk)) then
			-- Delay Y sample values
			Y_pipe <= unsigned(Y) & Y_pipe(0 to Y_plen - 2);
			
			-- Delay and separate Cb and Cr sample values.
			if (is_Cr = '1') then
				Cr_fpipe <= unsigned(CbCr) & Cr_fpipe(0 to CbCr_fplen - 2);
				Cr_outpipe <= Cr_fpipe(fcoef_taps) & Cr_outpipe(0 to latency - 2);
				Cr_loaded := '1';
			else
				Cb_fpipe <= unsigned(CbCr) & Cb_fpipe(0 to CbCr_fplen - 2);
				Cb_outpipe <= Cr_fpipe(fcoef_taps) & Cb_outpipe(0 to latency - 2);
				Cb_loaded := '1';
			end if; -- if (is_Cr = '1')
			
			-- When both Cr and Cb samples are stored, flag them as ready.
			if ((Cr_loaded = '1') and (Cb_loaded = '1')) then
				CbCr_raw_sample_ready <= '1';
				Cb_loaded := '0';
				Cr_loaded := '0';
			end if; -- if ((Cr_loaded = '1') and (Cb_loaded = '1'))
			
			-- Detect wrong chroma sample order.
			if (is_odd = '1') then	-- If frame is odd, then first chroma sample is Cr
				if ((Cr_loaded = '0') and (Cb_loaded = '1')) then
					-- Wrong sequence - reset pipes.
					CbCr_raw_sample_ready <= '0';
					Cb_loaded := '0';
					Y_pipe <= (others => x"10");
					Cb_fpipe <= (others => x"80");
					Cr_fpipe <= (others => x"80");
				end if; -- if ((Cr_loaded = '0') and (Cb_loaded = '1'))
			else					-- If frame is even, then first chroma sample is Cb
				if ((Cr_loaded = '1') and (Cb_loaded = '0')) then
					-- Wrong sequence - reset pipes.
					CbCr_raw_sample_ready <= '0';
					Cr_loaded := '0';
					Y_pipe <= (others => x"10");
					Cb_fpipe <= (others => x"80");
					Cr_fpipe <= (others => x"80");
				end if; -- if ((Cr_loaded = '1') and (Cb_loaded = '0'))
			end if; -- if (is_odd = '1')
		end if;	-- if ((reset = '1') or (dvalid = '0'))
	end process; -- feed_sample_pipes : process(pclk)

	-- 
	fir_filter : process(pclk)
		constant partial_sum_width	: natural := data_width + 1;
		variable Cb_partial_sum		: signed((partial_sum_width - 1) downto 0);
		variable Cr_partial_sum		: signed((partial_sum_width - 1) downto 0);
		constant product_width		: natural := fcoef_width + partial_sum_width; -- Product size of filter coefficient with sample
		type product_array_type is array (natural range 0 to (fcoef_taps - 1)) of signed((product_width - 1) downto 0);
		variable Cb_filter_products	: product_array_type;
		variable Cr_filter_products	: product_array_type;
		constant sum_width			: natural := product_width + fcoef_taps - 1; -- Total sum size of sum of products
		variable Cb_filter_sum		: signed((sum_width - 1) downto 0);
		variable Cr_filter_sum		: signed((sum_width - 1) downto 0);
		constant norm_width			: natural := sum_width - fnorm_shift; -- Size of normalized sample (after division shift)
		variable Cb_norm_result		: signed((norm_width - 1) downto 0);
		variable Cr_norm_result		: signed((norm_width - 1) downto 0);
		
	begin
		if ((reset = '1') or (dvalid = '0')) then
			-- 
			
		elsif (rising_edge(pclk)) then
			if (CbCr_raw_sample_ready = '1') then
				CbCr_raw_sample_ready <= '0';
				
				-- Perform the filter coefficient multiplication and partial sum of symmetric terms
				for i in 0 to (fcoef_taps - 1) loop
					Cb_partial_sum := signed(resize(Cb_fpipe(i), partial_sum_width))
									+ signed(resize(Cb_fpipe(CbCr_fplen - 1 - i), partial_sum_width));
					Cb_filter_products(i) := Cb_partial_sum * fcoefs(i);
					Cr_partial_sum := signed(resize(Cr_fpipe(i), partial_sum_width))
									+ signed(resize(Cr_fpipe(CbCr_fplen - 1 - i), partial_sum_width));
					Cr_filter_products(i) := Cr_partial_sum * fcoefs(i);
				end loop;
				
				-- Sum all multiplication results
				Cb_filter_sum := to_signed(0, sum_width);
				Cr_filter_sum := to_signed(0, sum_width);
				for i in 0 to (fcoef_taps - 1) loop
					Cb_filter_sum := Cb_filter_sum + Cb_filter_products(i);
					Cr_filter_sum := Cr_filter_sum + Cr_filter_products(i);
				end loop;
				
				-- Perform normalizing division (using bit shifting)
				Cb_norm_result := shift_right(Cb_filter_sum, fnorm_shift);
				Cr_norm_result := shift_right(Cr_filter_sum, fnorm_shift);
				
				-- Limit and truncate result
				if (Cb_norm_result > to_signed(255, norm_width)) then
					Cb_processed <= x"FF";
				elsif  (Cb_norm_result < to_signed(0, norm_width)) then
					Cb_processed <= x"00";
				else
					Cb_processed <= unsigned(resize(Cb_norm_result, data_width));
				end if;
				
				if (Cr_norm_result > to_signed(255, norm_width)) then
					Cr_processed <= x"FF";
				elsif  (Cr_norm_result < to_signed(0, norm_width)) then
					Cr_processed <= x"00";
				else
					Cr_processed <= unsigned(resize(Cr_norm_result, data_width));
				end if;
				
				-- Flag new filtered chroma sample is ready
				CbCr_filt_sample_ready <= '1';
			end if; -- if (CbCr_raw_sample_ready = '0')
		end if;	-- if ((reset = '1') or (dvalid = '0'))
	end process; -- fir_filter : process(pclk)

	-- 
	generate_output_samples : process(pclk)
	begin
		if (rising_edge(pclk)) then
			if (CbCr_filt_sample_ready = '1') then
				Y_dly <= std_logic_vector(Y_pipe(Y_plen - 1));
				Cb_flt <= std_logic_vector(Cb_processed);
				Cr_flt <= std_logic_vector(Cr_processed);
			else
				Y_dly <= std_logic_vector(Y_pipe(Y_plen - 2));
				Cb_flt <= std_logic_vector(Cb_outpipe(latency - 1));
				Cr_flt <= std_logic_vector(Cb_outpipe(latency - 1));
			end if;
		end if;
	end process; -- generate_output_samples : process(pclk)
end behav;
