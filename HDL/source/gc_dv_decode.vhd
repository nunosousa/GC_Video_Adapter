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
    signal state_slow           : state_typ := s0;
    signal state_fast           : state_typ := s0;
    
    -- Sample stores
	signal previous_vphase		: std_logic := '0';
    signal Y_slow				: std_logic_vector(7 downto 0);
    signal Y_fast				: std_logic_vector(7 downto 0);
    signal CbCr_slow			: std_logic_vector(7 downto 0);
    signal CbCr_fast			: std_logic_vector(7 downto 0);
    signal dvalid_slow          : std_logic := '0';
    signal dvalid_fast          : std_logic := '0';

    -- Pixel clock
    signal pclk_slow            : std_logic;
    signal pclk_fast            : std_logic;
begin
    -- State machine transitions - vdata: <Y0><CbCr0><Y1><CbCr1>...
    vphase_update: process(vclk)
    begin
        if (rising_edge(vclk)) then
            -- Store previous vphase state
            previous_vphase <= vphase;
        end if; -- if (rising_edge(vclk))
    end process;

    -- State machine transitions - vdata: <Y0><Y0><CbCr0><CbCr0><Y1><Y1><CbCr1><CbCr1>...
    state_update_slow: process(vclk)
    begin
        if (rising_edge(vclk)) then
            -- State machine transitions
            case state_slow is
                when s0 =>  -- Reset state - Y sample
                    Y_slow <= vdata;
                    CbCr_slow <= x"00";
                    dvalid_slow <= '0';
                    state_slow <= s2;
                when s1 =>  -- Y sample
                    Y_slow <= vdata;
                    CbCr_slow <= x"00";
                    if (previous_vphase /= vphase) then
                        dvalid_slow <= '1';
                        -- out Y_slow
                        -- out CbCr_slow
                        state_slow <= s2; -- Slow mode detected.
                    else
                        state_slow <= s0; -- Reset - a vphase change chould have happened.
                    end if;
                when s2 =>  -- Still Y sample
                    Y_slow <= vdata;
                    CbCr_slow <= x"00";
                    if (previous_vphase /= vphase) then
                        state_slow <= s0; -- Reset - wrong timing for vphase change.
                    else
                        state_slow <= s3;
                    end if;
                when s3 =>  -- CbCr sample
                    Y_slow <= Y_slow;
                    CbCr_slow <= vdata;
                    if (previous_vphase /= vphase) then
                        state_slow <= s0; -- Reset - Fast mode detected.
                    else
                        state_slow <= s4;
                    end if;
                when s4 =>  -- Still CbCr sample
                    Y_slow <= Y_slow;
                    CbCr_slow <= vdata;
                    if (previous_vphase /= vphase) then
                        state_slow <= s0; -- Reset - wrong timing for vphase change.
                    else
                        state_slow <= s1;
                    end if;
                when others => state_slow <= s0;
            end case;
        end if; -- if (rising_edge(vclk))
    end process;

    -- State machine transitions - vdata: <Y0><CbCr0><Y1><CbCr1>...
    state_update_fast: process(vclk)
    begin
        if (rising_edge(vclk)) then
            -- State machine transitions
            case state_fast is
                when s0 =>  -- Reset state - Y sample
                    Y_fast <= vdata;
                    CbCr_fast <= x"00";
                    dvalid_fast <= '0';
                    state_fast <= s2;
                when s1 =>  -- Y sample
                    Y_fast <= vdata;
                    CbCr_fast <= x"00";
                    if (previous_vphase /= vphase) then
                        dvalid_fast <= '1';
                        -- out Y_fast
                        -- out CbCr_fast
                        state_fast <= s2; -- Fast mode detected.
                    else
                        state_fast <= s0; -- Reset - a vphase change chould have happened.
                    end if;
                when s2 =>  -- CbCr sample
                    Y_fast <= Y_fast;
                    CbCr_fast <= vdata;
                    if (previous_vphase /= vphase) then
                        state_fast <= s0; -- Reset - wrong timing for vphase change.
                    else
                        state_fast <= s1;
                    end if;
                when others => state_fast <= s0;
            end case; --case state_fast is
        end if; -- if (rising_edge(vclk))
    end process;
end behav;
