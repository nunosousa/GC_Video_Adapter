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
    signal state_slow               : state_typ := reset_get_Y;
    signal state_fast               : state_typ := reset_get_Y;
    
    -- Sample stores
	signal previous_vphase          : std_logic := '0';
	signal vphase_slow_validated    : std_logic := '0';
	signal vphase_fast_validated    : std_logic := '0';
    signal Y_slow                   : std_logic_vector(7 downto 0);
    signal Y_slow_validated         : std_logic_vector(7 downto 0);
    signal Y_fast                   : std_logic_vector(7 downto 0);
    signal Y_fast_validated         : std_logic_vector(7 downto 0);
    signal CbCr_slow                : std_logic_vector(7 downto 0);
    signal CbCr_slow_validated      : std_logic_vector(7 downto 0);
    signal CbCr_fast                : std_logic_vector(7 downto 0);
    signal CbCr_fast_validated      : std_logic_vector(7 downto 0);
    signal dvalid_slow              : std_logic := '0';
    signal dvalid_fast              : std_logic := '0';

    -- Pixel clock
    signal pclk_slow                : std_logic;
    signal pclk_fast                : std_logic;
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
                        -- Slow mode detected. Flag new samples as ready.
                        dvalid_slow <= '1';
                        vphase_slow_validated <= previous_vphase;
                        Y_slow_validated <= Y_slow;
                        CbCr_slow_validated <= CbCr_slow;
                        state_slow <= get_Y_x2;
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
                        -- Fast mode detected.. Flag new samples as ready.
                        dvalid_fast <= '1';
                        vphase_fast_validated <= previous_vphase;
                        Y_fast_validated <= Y_fast;
                        CbCr_fast_validated <= CbCr_fast;
                        state_fast <= get_CbCr;
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
        variable vphase_sample          : std_logic := '0';
        variable Y_sample               : std_logic_vector(7 downto 0);
        variable CbCr_sample            : std_logic_vector(7 downto 0);
    begin
        if (rising_edge(vclk)) then
            -- Select source
            if (dvalid_slow = '1') then
                dvalid_slow <= '0';
                vphase_sample := vphase_slow_validated;
                Y_sample := Y_slow_validated;
                CbCr_sample := CbCr_slow_validated;
            elsif (dvalid_fast = '1') then
                dvalid_fast <= '0';
                vphase_sample := vphase_fast_validated;
                Y_sample := Y_fast_validated;
                CbCr_sample := CbCr_fast_validated;
            else
                vphase_sample := '0';
                Y_sample := Y_fast_validated;
                CbCr_sample := CbCr_fast_validated;
            end if;

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
                
                if (vphase_sample = '1') then
                    is_Cr <= '1';
                else
                    is_Cr <= '0';
                end if;	-- if (vphase = '1')
            end if;	-- if (Y_sample = x"00")

        end if; -- if (rising_edge(vclk))
    end process;
end behav;
