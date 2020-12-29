-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;

entity gc_dav_decode is

	port(
		vclk			: in	std_logic;
		vphase			: in	std_logic;
		vdata_in		: in	std_logic_vector(7 downto 0);
		reset			: in	std_logic;
		Y_vdata_out		: out	std_logic_vector(7 downto 0);
		CbCr_vdata_out	: out	std_logic_vector(7 downto 0)
	);
	
end entity;

architecture rtl of gc_dav_decode is

	-- Build an enumerated type for the state machine
	type state_type is (st0, st1, st2, st3, st4, st5);
	
	-- Register to hold the previous and current states
	signal previous_state	: state_type;
	signal new_state		: state_type;
	
	-- Register to hold the current vphase state
	signal vphase_store		: std_logic;
	
	-- Register to store the current video data
	signal Y_vdata_store	: std_logic_vector(7 downto 0);
	signal CbCr_vdata_store	: std_logic_vector(7 downto 0);
	
	-- Register to hold the current video frequency
	--signal is_30kHz_video	: std_logic;

begin
	-- Logic to advance to the next state
	sync_proc: process (vclk, reset)
	begin
		if reset = '1' then
			previous_state <= st0;
		elsif (rising_edge(vclk)) then
			previous_state <= new_state;
		end if;
	end process;
	
	-- Output depends solely on the state
	comb_proc: process (previous_state, vphase)
	begin
		vphase_store <= vphase;
		case previous_state is
			when st0 =>		-- Reset state. Not in synch with incoming data.
				new_state <= st1;
			when st1 =>		-- Detect first pair of color data. Synch with incoming data.
				if vphase /= vphase_store then	-- New color data. Get Y.
					Y_vdata_store <= vdata_in;
					new_state <= st2;
				end if;
			when st2 =>		-- Get CbCr (if 15kHz video, it is still Y and will be overwritten in st3 with CrCb).
				CbCr_vdata_store <= vdata_in;
				new_state <= s3;
			when st3 =>		-- Get new Y and set video output if 30kHz video, or get CrCb if 15kHz video.
				if vphase /= vphase_store then
					Y_vdata_out <= Y_vdata_store;
					CbCr_vdata_out <= CbCr_vdata_store;
					Y_vdata_store <= vdata_in;
					new_state <= st2;
				else
					CbCr_vdata_store <= vdata_in;
					new_state <= st4;
				end if;
			when st4 =>		-- 15kHz video. Still same CbCr.
				new_state <= st5;
			when st5 =>		-- Get new Y and set video output if 15kHz video, else synch fault detected and go back to st0.
				if vphase /= vphase_store then
					Y_vdata_out <= Y_vdata_store;
					CbCr_vdata_out <= CbCr_vdata_store;
					Y_vdata_store <= vdata_in;
					new_state <= st2;
				else
					new_state <= st0;
				end if;
		end case;
	end process;
	
end rtl;
