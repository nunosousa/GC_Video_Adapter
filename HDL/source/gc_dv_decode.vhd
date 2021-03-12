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
    type state_typ is (reset_get_Y, get_Y, get_Y_x2, get_CbCr, get_CbCr_x2);
    signal state_slow           : state_typ := reset_get_Y;
    signal state_fast           : state_typ := reset_get_Y;
    
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
                when reset_get_Y =>
                    Y_slow <= vdata;
                    CbCr_slow <= x"00";
                    dvalid_slow <= '0';
                    state_slow <= get_Y_x2;
                when get_Y =>
                    Y_slow <= vdata;
                    CbCr_slow <= x"00";
                    if (previous_vphase /= vphase) then
                        dvalid_slow <= '1';
                        -- out Y_slow
                        -- out CbCr_slow
                        state_slow <= get_Y_x2; -- Slow mode detected.
                    else
                        state_slow <= reset_get_Y; -- Reset - a vphase change chould have happened.
                    end if;
                when get_Y_x2 =>
                    Y_slow <= vdata;
                    CbCr_slow <= x"00";
                    if (previous_vphase /= vphase) then
                        state_slow <= reset_get_Y; -- Reset - wrong timing for vphase change.
                    else
                        state_slow <= get_CbCr;
                    end if;
                when get_CbCr =>
                    Y_slow <= Y_slow;
                    CbCr_slow <= vdata;
                    if (previous_vphase /= vphase) then
                        state_slow <= reset_get_Y; -- Reset - Fast mode detected.
                    else
                        state_slow <= get_CbCr_x2;
                    end if;
                when get_CbCr_x2 =>
                    Y_slow <= Y_slow;
                    CbCr_slow <= vdata;
                    if (previous_vphase /= vphase) then
                        state_slow <= reset_get_Y; -- Reset - wrong timing for vphase change.
                    else
                        state_slow <= get_Y;
                    end if;
                when others => state_slow <= reset_get_Y;
            end case;
        end if; -- if (rising_edge(vclk))
    end process;

    -- State machine transitions - vdata: <Y0><CbCr0><Y1><CbCr1>...
    state_update_fast: process(vclk)
    begin
        if (rising_edge(vclk)) then
            -- State machine transitions
            case state_fast is
                when reset_get_Y =>
                    Y_fast <= vdata;
                    CbCr_fast <= x"00";
                    dvalid_fast <= '0';
                    state_fast <= get_CbCr;
                when get_Y =>
                    Y_fast <= vdata;
                    CbCr_fast <= x"00";
                    if (previous_vphase /= vphase) then
                        dvalid_fast <= '1';
                        -- out Y_fast
                        -- out CbCr_fast
                        state_fast <= get_CbCr; -- Fast mode detected.
                    else
                        state_fast <= reset_get_Y; -- Reset - a vphase change chould have happened.
                    end if;
                when get_CbCr =>
                    Y_fast <= Y_fast;
                    CbCr_fast <= vdata;
                    if (previous_vphase /= vphase) then
                        state_fast <= reset_get_Y; -- Reset - wrong timing for vphase change.
                    else
                        state_fast <= get_Y;
                    end if;
                when others => state_fast <= reset_get_Y;
            end case; --case state_fast is
        end if; -- if (rising_edge(vclk))
    end process;

    -- Select output source from state machines
    source_select: process(vclk)
    begin
        if (rising_edge(vclk)) then
            -- Select source
            if (dvalid_slow = '1') then
            elsif (dvalid_fast = '1') then
            else
            end if;


        end if; -- if (rising_edge(vclk))
    end process;
end behav;
