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
	
	-- Build an enumerated type for the state machine
	type state_type is (st0, st1);
	
	-- Register to hold the previous and current states
	signal previous_state	: state_type;
	signal new_state		: state_type;

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


	-- Logic to advance to the next state and update pixel clock
	sync_proc: process (vclk, reset)
	begin
		if reset = '1' then
			previous_state <= st0;
		elsif (rising_edge(vclk)) then
			previous_state <= new_state;
		end if;
	end process;
	
	-- Logic to determine output values
	comb_proc: process (previous_state, vphase)
	begin
		vphase_store <= vphase;
		case previous_state is
			when st0 =>		-- Reset state. Not in synch with incoming data.
				new_state <= st1;
			when st1 =>		-- Detect first pair of color data. Synch with incoming data.
				if vphase /= vphase_store then	-- New color data. Get Y.
					Y_vdata_store <= vdata_in;
					if vdata_in /= x"00" then
						new_state <= st2;
					else
						new_state <= st6;
					end if;
				end if;
		end case;
	end process;

end behav;
