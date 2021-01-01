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

	-- Build incoming vdata buffer
	type vdata_buffer_type is array (0 to 3) of std_logic_vector(7 downto 0);
	signal vdata_buffer			: vdata_buffer_type;
	
	-- Register to hold the current vphase state
	signal vphase_store			: std_logic;
	signal vclk_count			: natural range 0 to 5 := 0; -- check this range!!!!
	signal valid_sample			: std_logic := 0;

begin

	-- vdata buffer logic
	vdata_buffer_process : process(vclk)
	begin
		if (rising_edge(vclk)) then
			if (reset = '0') then	-- Store new vdata sample and shift samples
				vdata_buffer(0) <= vdata_buffer(1);
				vdata_buffer(1) <= vdata_buffer(2);
				vdata_buffer(2) <= vdata_buffer(3);
				vdata_buffer(3) <= vdata;
				
				vclk_count <= vclk_count + 1;
			end if;	-- if (reset = '0')
		end if;	-- if rising_edge(vclk)
	end process;


	-- Logic to detect that a new color sample was received (by checking when vphase changes polarity)
	vphase_process: process(vclk)
		variable tbd	: std_logic := '1';
	begin
		if (rising_edge(vclk)) then
			if (reset = '1') then
				vclk_count <= 0;
				valid_sample <= '0';
			else
				vphase_store <= vphase;
				vclk_count <= vclk_count + 1;
			
				if (fill_count >= 2) then
					if (vphase /= vphase_store) then
						vclk_count <= 0;
						
						if (vclk_count = 2) then	-- progresive video (vdata: <Y0><CbCr0><Y1><CbCr1>...)
							valid_sample <= '1';
							Y_vdata <= get_sample(0);
							CbCr_vdata <= get_sample(1);
						elsif (vclk_count = 4) then	-- interlaced video (vdata: <Y0><Y0><CbCr0><CbCr0><Y1><Y1><CbCr1><CbCr1>...)
							valid_sample <= '1';
							Y_vdata <= get_sample(0);
							CbCr_vdata <= get_sample(2);
						end if;
					end if;	-- if (vphase /= vphase_store)
				end if;	-- if (fill_count >= 2)
			end if;	-- if (reset = '1')
		end if;	-- if (rising_edge(vclk))
	end process;


	-- Logic to process and get a color sample
	sample_process: process(valid_sample)
		variable tbd	: std_logic := 1;
	begin
		if (valid_sample = 1) then
			valid_sample <= 0;
			
			if (Y_vdata = x"00") then	-- blanking data
				Y_vdata <= x"10";
				CbCr_vdata <= x"80";
				H_sync <= '1';
				V_sync <= '1';
				C_sync <= '1';
				Blanking <= '1';
			else						-- video samples
				H_sync <= '1';
				V_sync <= '1';
				C_sync <= '1';
				Blanking <= '1';
			end if;
		end if;
	end process;

end behav;