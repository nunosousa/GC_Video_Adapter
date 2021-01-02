-- file: gc_dv_decode.vhd

library ieee;
use ieee.std_logic_1164.all;

entity gc_dv_decode is

	port(
		vclk		: in	std_logic;
		vphase		: in	std_logic;
		vdata		: in	std_logic_vector(7 downto 0);
		reset		: in	std_logic;
		pclk		: out	std_logic;
		Y_vdata		: out	std_logic_vector(7 downto 0);
		CbCr_vdata	: out	std_logic_vector(7 downto 0);
		H_sync		: out	std_logic;
		V_sync		: out	std_logic;
		C_sync		: out	std_logic;
		Blanking	: out	std_logic
	);
	
end entity;

architecture behav of gc_dv_decode is

	-- vdata buffer
	type vdata_buffer_type is array (0 to 3) of std_logic_vector(7 downto 0);
	signal vdata_buffer			: vdata_buffer_type;
	
	-- vphase state signals
	signal vphase_store			: std_logic;
	signal vsample_count		: natural range 0 to 5 := 0; -- check this range!!!!

begin

	-- vdata logic
	vdata_process : process(vclk)
		variable valid_sample	: std_logic := '0';
		variable Y_sample		: std_logic_vector(7 downto 0);
		variable CbCr_sample	: std_logic_vector(7 downto 0);

	begin
		if (rising_edge(vclk)) then
			if (reset = '1') then	-- Reset sample counter
				vsample_count <= 0;
			else
				-- Store new vdata sample and shift samples
				vdata_buffer(0) <= vdata_buffer(1);
				vdata_buffer(1) <= vdata_buffer(2);
				vdata_buffer(2) <= vdata_buffer(3);
				vdata_buffer(3) <= vdata;
				
				vsample_count <= vsample_count + 1;
				vphase_store <= vphase;
				
				-- Process new video sample using vphase as trigger
				if (vphase /= vphase_store) then
					vsample_count <= 0;
					
					-- Get Y and CbCr sample depending on the stream format
					if (vsample_count = 2) then		-- vdata: <Y0><CbCr0><Y1><CbCr1>...
						valid_sample := '1';
						Y_sample := vdata_buffer(2);
						CbCr_sample := vdata_buffer(3);
					elsif (vsample_count = 4) then	-- vdata: <Y0><Y0><CbCr0><CbCr0><Y1><Y1><CbCr1><CbCr1>...
						valid_sample := '1';
						Y_sample := vdata_buffer(0);
						CbCr_sample := vdata_buffer(2);
					end if;	-- if (vsample_count = 2)
					
					-- If new sample exists, set output interface video values and flags
					if (valid_sample = '1') then
						valid_sample := '0';
						
						if (Y_sample = x"00") then	-- blanking data
							Y_vdata <= x"10";
							CbCr_vdata <= x"80";
							H_sync <= not CbCr_sample(4);
							V_sync <= not CbCr_sample(5);
							C_sync <= not CbCr_sample(7);
							Blanking <= '1';
						else						-- video sample
							Y_vdata <= Y_sample;
							CbCr_vdata <= CbCr_sample;
							H_sync <= '0';
							V_sync <= '0';
							C_sync <= '0';
							Blanking <= '0';
						end if;
					end if;	-- if (valid_sample = '1')
		
				end if;	-- if (vphase /= vphase_store)
			end if;	-- if (reset = '1')
		end if;	-- if rising_edge(vclk)
	end process;

end behav;