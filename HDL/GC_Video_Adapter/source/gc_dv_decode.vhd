-- file: gc_dv_decode.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_decode is
	port(
		vclk	: in	std_logic;
		vphase	: in	std_logic;
		vdata	: in	std_logic_vector(7 downto 0);
		pclk	: out	std_logic := '0';
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
	signal last_vphase			: std_logic := '0';
	signal vsample_count		: natural range 0 to 5 := 0;
	
	-- Retain last video mode (<Y0><Y0>... or <Y0>...) for valid data detection
	signal last_vmode			: std_logic := '0'; -- Default '0' is <Y0><Y0>...

begin
	-- vdata logic
	vdata_process : process(vclk)
		variable valid_sample	: std_logic := '0';
		variable Y_sample		: std_logic_vector(7 downto 0);
		variable CbCr_sample	: std_logic_vector(7 downto 0);

	begin
		if (rising_edge(vclk)) then
			-- 
			if (((vsample_count = 4) and (last_vmode = '0')) or ((vsample_count = 2) and (last_vmode = '1'))) then
				pclk <= '0';
			end if;
			-- 
			if (((vsample_count = 2) and (last_vmode = '0')) or ((vsample_count = 1) and (last_vmode = '1'))) then
				pclk <= '1';
			end if;
			
			-- Store new vdata sample and shift samples
			vdata_buffer <= vdata & vdata_buffer(0 to 2);
			
			-- Increment number of vdata samples taken on vclk
			if (vsample_count < 4) then
				vsample_count <= vsample_count + 1;
			end if;
			
			-- Set defaults for the case that no valid samples is processed.
			if ((vsample_count = 4) or ((vsample_count = 2) and (last_vmode = '1'))) then
				Y <= x"10";
				CbCr <= x"80";
				is_Cr <= '0';
				is_odd <= '0';
				H_sync <= '0';
				V_sync <= '0';
				C_sync <= '0';
				Blanking <= '0';
				dvalid <= '0';
			end if;
			
			-- Update previous vphase state for comparison
			last_vphase <= vphase;
			
			-- Process new video sample using vphase as trigger
			if (vphase /= last_vphase) then
				vsample_count <= 1; -- Set sample counter to 1 (current sample) after vphase change
			
				-- Get Y and CbCr sample depending on the vdata stream format
				if (vsample_count = 2) then		-- vdata: <Y0><CbCr0><Y1><CbCr1>...
					last_vmode <= '1';
					valid_sample := '1';
					Y_sample := vdata_buffer(1);
					CbCr_sample := vdata_buffer(0);
				elsif (vsample_count = 4) then	-- vdata: <Y0><Y0><CbCr0><CbCr0><Y1><Y1><CbCr1><CbCr1>...
					last_vmode <= '0';
					valid_sample := '1';
					Y_sample := vdata_buffer(3);
					CbCr_sample := vdata_buffer(1);
				end if;	-- if (vsample_count = 2)
			end if;	-- if (vphase /= last_vphase)
			
			-- If new sample exists, set output interface video values and flags
			if (valid_sample = '1') then
				valid_sample := '0';
				dvalid <= '1';
				
				if (Y_sample = x"00") then	-- blanking data
					Y <= x"10";
					CbCr <= x"80";
					H_sync <= not CbCr_sample(4);	-- Active low.
					V_sync <= not CbCr_sample(5);	-- Active low.
					is_odd <= not CbCr_sample(6);	-- Active low.
					C_sync <= not CbCr_sample(7);	-- Active low.
					Blanking <= '1';
					is_Cr <= '0';
				else						-- video sample
					Y <= Y_sample;
					CbCr <= CbCr_sample;
					H_sync <= '0';
					V_sync <= '0';
					is_odd <= '0';
					C_sync <= '0';
					Blanking <= '0';
					
					if (vphase = '1') then
						is_Cr <= '1';
					else
						is_Cr <= '0';
					end if;	-- if (vphase = '1')
				end if;	-- if (Y_sample = x"00")
			end if;	-- if (valid_sample = '1')
		end if;	-- if (rising_edge(vclk))
	end process;
end behav;
