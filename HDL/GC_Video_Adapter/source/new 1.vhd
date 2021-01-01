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

	-- Build incoming vdata circular buffer
	constant VDATA_BUFFER_DEPTH	: natural := 6;
	type vdata_buffer_type is array (0 to VDATA_BUFFER_DEPTH - 1) of std_logic_vector(7 downto 0);
	signal vdata_buffer			: vdata_buffer_type;
	
	subtype index_type is natural range vdata_buffer_type'range;
	signal head					: index_type := 0;
	signal tail					: index_type := 0;

	signal full					: std_logic;
	signal fill_count			: natural range VDATA_BUFFER_DEPTH - 1 downto 0;

	-- Head and Tail increment and wrap
	procedure incr_index(signal index : inout index_type) is
	begin
		if index = index_type'high then
			index <= index_type'low;
		else
			index <= index + 1;
		end if;
	end procedure;
	
	-- Register to hold the current vphase state
	signal vphase_store			: std_logic;
	signal vclk_count			: natural range 0 to 5 := 0; -- check this range!!!!
	signal vphase_event			: std_logic := 0;

begin

	-- vdata circular buffer logic
	-- Update de sample counter
	if head < tail then
		fill_count <= head - tail + VDATA_BUFFER_DEPTH;
	else
		fill_count <= head - tail;
	end if;
	
	-- Set the full flag
	full <= '1' when fill_count >= VDATA_BUFFER_DEPTH - 1 else '0';
	
	-- Main circular buffer logic
	vdata_buffer_process : process(vclk)
	begin
		if rising_edge(vclk) then
			if reset = '1' then	-- Reset buffer
				head <= 0;
				tail <= 0;
			else				-- Update head and tail counters and store new vdata sample
				incr_index(head);
				vdata_buffer(head) <= vdata;
				
				if full = '1' then
					incr_index(tail);
				end if;
			end if;
		end if;
	end process;


	-- Logic to detect that a new color sample was received (by checking when vphase changes polarity)
	vphase_process: process(vclk)
		variable is_first	: std_logic := 1;
	begin
		if (rising_edge(vclk)) then
			if reset = '1' then
				vclk_count <= 0;
				is_first := 1;
			else
				vphase_store <= vphase;
				vclk_count <= vclk_count + 1;
			
				if (is_first = '1') then
					is_first <= '0';
				else
					if (vphase /= vphase_store) then
						vphase_event <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;


	-- Logic to process and get a color sample
	sample_process: process(vphase_event)
		variable tbd	: std_logic := 1;
	begin
		if (vphase_event = 1) then
			vphase_event <= 0;
			vclk_count <= 0;
			
			if (vclk_count = 2) then
				--Y <= get_index();
				--CbCr <= get_index();
			elsif (vclk_count = 4) then
				--Y <= get_index();
				--CbCr <= get_index();
			end if;
				
		end if;
	end process;

end behav;
