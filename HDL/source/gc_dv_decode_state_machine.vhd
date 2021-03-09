-- file: gc_dv_decode.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_decode is
	port(
		vclk	: in	std_logic;
		vphase	: in	std_logic;
		vdata	: in	std_logic_vector(7 downto 0);
		pclk	: out	std_logic;
		Y		: out	std_logic_vector(7 downto 0);
		CbCr	: out	std_logic_vector(7 downto 0);
		is_Cr	: out	std_logic;
		is_odd	: out	std_logic;
		H_sync	: out	std_logic;
		V_sync	: out	std_logic;
		C_sync	: out	std_logic;
		Blanking: out	std_logic;
		dvalid	: out	std_logic
	);
end entity;

architecture behav of gc_dv_decode is
    -- State machine state definition
    type state_typ is (s0, s1, s2, s3, s4);
    signal state                : state_typ := s0;
    
    -- Sample stores
	signal previous_vphase		: std_logic;
    signal Y_sample				: std_logic_vector(7 downto 0);
    signal Y_slow				: std_logic_vector(7 downto 0);
    signal Y_fast				: std_logic_vector(7 downto 0);
    signal CbCr_sample			: std_logic_vector(7 downto 0);
    signal CbCr_slow			: std_logic_vector(7 downto 0);
    signal CbCr_fast			: std_logic_vector(7 downto 0);
    signal sample_vphase        : std_logic;
    signal sample_ready         : std_logic := '0';
begin
    -- State machine transitions
    state_update: process(vclk)
    begin
        if (rising_edge(vclk)) then
            -- Store previous vphase state
            previous_vphase <= vphase;
            -- State machine transitions
            case state is
                when s0 =>  -- Reset state - Y video sample on a new cycle.
                    Y_slow <= vdata;
                    Y_fast <= vdata;
                    state <= s2;
                when s1 =>  -- Y video sample on a new cycle.
                    Y_slow <= vdata;
                    if (previous_vphase /= vphase) then
                        state <= s2; -- Slow mode detected.
                        Y_sample <= Y_slow;
                        CbCr_sample <= CbCr_slow;
                        sample_vphase <= previous_vphase;
                        sample_ready <= '1';
                    else
                        state <= s0; -- Reset - a vphase change chould have happened.
                    end if;
                when s2 =>  -- Still Y sample in slow mode, or CbCr sample in fast mode.
                    CbCr_fast <= vdata;
                    if (previous_vphase /= vphase) then
                        state <= s0; -- Reset - wrong timing for vphase change.
                    else
                        state <= s3;
                    end if;
                when s3 =>  -- CbCr sample in slow mode.
                    Y_fast <= vdata;
                    CbCr_slow <= vdata;
                    if (previous_vphase /= vphase) then
                        state <= s2; -- Fast mode detected.
                        Y_sample <= Y_fast;
                        CbCr_sample <= CbCr_fast;
                        sample_vphase <= previous_vphase;
                        sample_ready <= '1';
                    else
                        state <= s4;
                    end if;
                when s4 =>  -- Still CbCr sample in slow mode.
                    if (previous_vphase /= vphase) then
                        state <= s0; -- Reset - wrong timing for vphase change.
                    else
                        state <= s1;
                    end if;
                when others => state <= s0;
            end case;
        end if; -- if (rising_edge(vclk))
    end process;

    -- state machine outputs
    state_outputs: process(sample_ready)
    begin
        if (sample_ready) then
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
                
                if (last_vphase = '1') then
                    is_Cr <= '1';
                else
                    is_Cr <= '0';
                end if;	-- if (vphase = '1')
            end if;	-- if (Y_sample = x"00")
        end if;
    end process;
end behav;
