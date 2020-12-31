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
	constant VDATA_BUFFER_DEPTH	: natural := 5;
	type vdata_buffer_type is array (0 to VDATA_BUFFER_DEPTH - 1) of std_logic_vector(7 downto 0);
	signal vdata_buffer			: vdata_buffer_type;
	
	subtype index_type is natural range vdata_buffer_type'range;
	signal head					: index_type;
	signal tail					: index_type;

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
	
	signal vclk_count			: natural range 0 to 3 := 0; -- check this range
	signal vphase_event			: std_logic := 0;

begin

	-- vdata circular buffer logic
	-- Set the flags
	full <= '1' when fill_count >= VDATA_BUFFER_DEPTH - 1 else '0';
	
	-- Update de sample counter
	if head < tail then
		fill_count <= head - tail + VDATA_BUFFER_DEPTH;
	else
		fill_count <= head - tail;
	end if;

	vdata_buffer_process : process(vclk)
	begin
		if rising_edge(vclk) then
			-- head
			if reset = '1' then
				head <= 0;
			else
				incr_index(head);
			end if;
			
			-- tail
			if rst = '1' then
				tail <= 0;
			else
				if full = '1' then
					incr_index(tail);
				end if;
			end if;
			
			-- contents
			vdata_buffer(head) <= vdata;
		end if;
	end process;


	-- Detect video frequency and vphase changes (start of new color sample)
	vphase_process: process (vclk)
		variable vphase_store : std_logic;
		-- Build an enumerated type for the state machine
		type state_type is (st0, st1);
		-- Register to hold the previous and current states
		variable previous_state	: state_type;
		variable new_state		: state_type;
	
	begin
		if (rising_edge(vclk)) then
			vclk_count <= vclk_count + 1;
			vphase_store := vphase;
			
			if (vphase /= vphase_store) then
				vphase_event <= '1';
			end if;
		end if;
	end process;

end behav;
