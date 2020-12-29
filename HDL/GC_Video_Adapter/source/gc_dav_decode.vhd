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
	type state_type is (s0, s1, s2, s3, s4, s5);
	
	-- Register to hold the current state
	signal state			: state_type;
	
	-- Register to hold the current vphase state
	variable vphase_store	: std_logic;
	
	-- Register to store the current video data
	variable Y_vdata_store		: std_logic_vector(7 downto 0);
	variable CbCr_vdata_store	: std_logic_vector(7 downto 0);
	
	-- Register to hold the current video frequency
	--signal is_30kHz_video	: std_logic;

begin
	-- Logic to advance to the next state
	process (vclk, reset)
	begin
		if reset = '1' then
			state <= s0;
		elsif (rising_edge(vclk)) then
			vphase_store <= vphase;
			
			case state is
				when s0 =>
					state <= s1;
				when s1 =>
					if vphase /= vphase_store then
						state <= s2;
					end if;
				when s2 =>
					state <= s3;
				when s3 =>
					if vphase /= vphase_store then
						state <= s2;
					else
						state <= s4;
					end if;
				when s4 =>
					state <= s5;
				when s5 =>
					if vphase /= vphase_store then
						state <= s2;
					else
						state <= s0;
					end if;
			end case;
		end if;
	end process;
	
	-- Output depends solely on the current state
	process (state)
	begin
	
		case state is
			when s0 =>
				-- nothing
			when s1 =>
				Y_vdata_store <= vdata_in;
			when s2 =>
				CbCr_vdata_store <= vdata_in;
			when s3 =>
				data_out <= "11";
			when s4 =>
				data_out <= "10";
			when s5 =>
				data_out <= "11";
		end case;
	end process;
	
end rtl;
