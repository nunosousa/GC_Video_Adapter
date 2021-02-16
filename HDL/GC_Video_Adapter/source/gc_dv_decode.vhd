-- file: gc_dv_decode.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_decode is
	port(
		vclk	: in	std_logic;
		vphase	: in	std_logic;
		vdata	: in	std_logic_vector(7 downto 0);
		pclk	: out	std_logic := '1';
		Y		: out	std_logic_vector(7 downto 0) := x"10";
		CbCr	: out	std_logic_vector(7 downto 0) := x"80";
		is_Cr	: out	std_logic := '0';
		is_odd	: out	std_logic := '0';
		H_sync	: out	std_logic := '0';
		V_sync	: out	std_logic := '0';
		C_sync	: out	std_logic := '0';
		Blanking: out	std_logic := '0';
		dvalid	: out	std_logic := '0'
	);
end entity;

architecture behav of gc_dv_decode is
	-- vdata buffer
	type vdata_buffer_type is array(0 to 3) of std_logic_vector(7 downto 0);
	signal vdata_buffer			: vdata_buffer_type := (others => x"FF");
	
	-- vphase state signals
	signal vphase_store			: std_logic := '0';
	signal vsample_count		: natural range 0 to 5 := 0;
	
	-- Clock divider
	signal clk_divider			: unsigned(1 downto 0) := (others => '0');

begin
	-- vdata logic
	vdata_process : process(vclk)
		variable valid_sample	: std_logic := '0';
		variable Y_sample		: std_logic_vector(7 downto 0);
		variable CbCr_sample	: std_logic_vector(7 downto 0);
		variable clk_sel		: std_logic := '0';

	begin
		if (rising_edge(vclk)) then
			-- Set defaults in case no valid data is detected
			vsample_count <= 1; -- Set sample counter to 1 (current sample)
			dvalid <= '0';
			Y <= x"10";
			CbCr <= x"80";
			is_Cr <= '0';
			is_odd <= '0';
			H_sync <= '0';
			V_sync <= '0';
			C_sync <= '0';
			Blanking <= '0';
			clk_divider <= clk_divider + 1;	-- Increment pixel clock divider
			
			-- Store new vdata sample and shift samples
			vdata_buffer <= vdata & vdata_buffer(0 to 2);
			
			-- Increment number of vdata samples taken on vclk
			if (vsample_count < 4) then
				vsample_count <= vsample_count + 1;
			end if;
			
			-- Update previous vphase state for comparison
			vphase_store <= vphase;
			
			-- Process new video sample using vphase as trigger
			if (vphase /= vphase_store) then
				-- Get Y and CbCr sample depending on the vdata stream format
				if (vsample_count = 2) then		-- vdata: <Y0><CbCr0><Y1><CbCr1>...
					valid_sample := '1';
					Y_sample := vdata_buffer(1);
					CbCr_sample := vdata_buffer(0);
					clk_sel := '0';				-- Set pixel clock to div2 base 54 MHz clock
				elsif (vsample_count = 4) then	-- vdata: <Y0><Y0><CbCr0><CbCr0><Y1><Y1><CbCr1><CbCr1>...
					valid_sample := '1';
					Y_sample := vdata_buffer(3);
					CbCr_sample := vdata_buffer(1);
					clk_sel := '1';				-- Set pixel clock to div4 base 54 MHz clock
				end if;	-- if (vsample_count = 2)
			end if;	-- if (vphase /= vphase_store)
			
			-- If new sample exists, set output interface video values and flags
			if (valid_sample = '1') then
				valid_sample := '0';
				dvalid <= '1';
				clk_divider <= (others => '1');	-- Synchronize pixel clock with new sample change
				
				if (Y_sample = x"00") then	-- blanking data
					Y <= x"10";
					CbCr <= x"80";
					H_sync <= not CbCr_sample(4);
					V_sync <= not CbCr_sample(5);
					is_odd <= not CbCr_sample(6);
					C_sync <= not CbCr_sample(7);
					Blanking <= '1';
					is_Cr <= '0';
				else						-- video sample
					Y <= Y_sample;
					CbCr <= CbCr_sample;
					
					if (vphase = '1') then
						is_Cr <= '1';
					else
						is_Cr <= '0';
					end if;	-- if (vphase = '1')
				end if;	-- if (Y_sample = x"00")
			end if;	-- if (valid_sample = '1')
			
			-- Select pixel clock
			if (clk_sel = '0') then
				-- Pixel clock for vdata stream format: <Y0><CbCr0><Y1><CbCr1>...
				pclk <= clk_divider(0);
			else
				-- Pixel clock for vdata stream format: <Y0><Y0><CbCr0><CbCr0><Y1><Y1><CbCr1><CbCr1>...
				pclk <= clk_divider(1);
			end if;
		end if;	-- if (rising_edge(vclk))
	end process;
end behav;
