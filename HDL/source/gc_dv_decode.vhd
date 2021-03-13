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
    type state_slow_typ is (reset, get_vphase_sync, get_Y, get_Y_x2, get_CbCr, get_CbCr_x2);
    signal state_slow               : state_typ := reset;
    type state_fast_typ is (reset, get_vphase_sync, get_Y, get_CbCr);
    signal state_fast               : state_typ := reset;
    
    -- Sample stores
	signal previous_vphase          : std_logic;
	signal vphase_slow_validated    : std_logic;
	signal vphase_fast_validated    : std_logic;
    signal Y_slow                   : std_logic_vector(7 downto 0);
    signal Y_slow_validated         : std_logic_vector(7 downto 0);
    signal Y_fast                   : std_logic_vector(7 downto 0);
    signal Y_fast_validated         : std_logic_vector(7 downto 0);
    signal CbCr_slow                : std_logic_vector(7 downto 0);
    signal CbCr_slow_validated      : std_logic_vector(7 downto 0);
    signal CbCr_fast                : std_logic_vector(7 downto 0);
    signal CbCr_fast_validated      : std_logic_vector(7 downto 0);
    signal dvalid_slow              : std_logic := '0';
    signal dinvalid_slow            : std_logic := '0';
    signal dvalid_fast              : std_logic := '0';
    signal dinvalid_fast            : std_logic := '0';

    -- Pixel clock
    signal pclk_slow                : std_logic;
    signal pclk_fast                : std_logic;
begin
    -- Store previous vphase state
    vphase_update: process(vclk)
    begin
        if (rising_edge(vclk)) then
            previous_vphase <= vphase;
        end if; -- if (rising_edge(vclk))
    end process;

    -- State machine transitions - vdata format: <Y0><Y0><CbCr0><CbCr0><Y1><Y1><CbCr0><CbCr0>...
    state_update_slow: process(vclk)
    begin
        if (rising_edge(vclk)) then
            -- State machine transitions
            case state_slow is
                when reset =>
                    dvalid_slow <= '0';
                    dinvalid_slow <= '1';
                    Y_slow <= x"00";
                    CbCr_slow <= x"00";
                    state_slow <= get_vphase_sync;
                when get_vphase_sync =>
                    dvalid_slow <= '0';
                    dinvalid_slow <= '1';
                    if (previous_vphase /= vphase) then
                        Y_slow <= vdata;
                        CbCr_slow <= x"00";
                        state_slow <= get_Y_x2;
                    else
                        Y_slow <= x"00";
                        CbCr_slow <= x"00";
                        state_slow <= get_vphase_sync;
                    end if;
                when get_Y =>
                    if (previous_vphase /= vphase) then -- New slow mode samples detected. Set outputs.
                        dvalid_slow <= '1';
                        dinvalid_slow <= '0';
                        vphase_fast_validated <= previous_vphase;
                        Y_slow_validated <= Y_slow;
                        CbCr_slow_validated <= CbCr_slow;
                        Y_slow <= vdata;
                        CbCr_slow <= x"00";
                        state_slow <= get_Y_x2;
                    else -- Reset - a vphase change should have happened.
                        dvalid_slow <= '0';
                        dinvalid_slow <= '1';
                        Y_slow <= x"00";
                        CbCr_slow <= x"00";
                        state_slow <= get_vphase_sync;
                    end if;
                when get_Y_x2 =>
                    dvalid_slow <= '0';
                    dinvalid_slow <= '0';
                    if (previous_vphase = vphase) then
                        Y_slow <= vdata;
                        CbCr_slow <= x"00";
                        state_slow <= get_CbCr;
                    else -- Unexpected start of new cycle. Get Y sample.
                        Y_slow <= vdata;
                        CbCr_slow <= x"00";
                        state_slow <= get_Y_x2;
                    end if;
                when get_CbCr =>
                    dvalid_slow <= '0';
                    dinvalid_slow <= '0';
                    if (previous_vphase = vphase) then
                        Y_slow <= Y_slow;
                        CbCr_slow <= vdata;
                        state_slow <= get_CbCr_x2;
                    else -- Unexpected start of new cycle. Get Y sample.
                        Y_slow <= vdata;
                        CbCr_slow <= x"00";
                        state_slow <= get_Y_x2;
                    end if;
                when get_CbCr_x2 =>
                    dvalid_slow <= '0';
                    dinvalid_slow <= '0';
                    if (previous_vphase = vphase) then
                        Y_slow <= Y_slow;
                        CbCr_slow <= vdata;
                        state_slow <= get_Y;
                    else -- Unexpected start of new cycle. Get Y sample.
                        Y_slow <= vdata;
                        CbCr_slow <= x"00";
                        state_slow <= get_Y_x2;
                    end if;
                when others => state_slow <= reset_get_Y;
            end case;
        end if; -- if (rising_edge(vclk))
    end process;

    -- State machine transitions - vdata format: <Y0><CbCr0><Y1><CbCr0>...
    state_update_fast: process(vclk)
    begin
        if (rising_edge(vclk)) then
            -- State machine transitions
            case state_fast is
                when reset =>
                    dvalid_fast <= '0';
                    dinvalid_fast <= '1';
                    Y_fast <= x"00";
                    CbCr_fast <= x"00";
                    state_fast <= get_vphase_sync;
                when get_vphase_sync =>
                    dvalid_fast <= '0';
                    dinvalid_fast <= '1';
                    if (previous_vphase /= vphase) then
                        Y_fast <= vdata;
                        CbCr_fast <= x"00";
                        state_fast <= get_CbCr;
                    else
                        Y_fast <= x"00";
                        CbCr_fast <= x"00";
                        state_fast <= get_vphase_sync;
                    end if;
                when get_Y =>
                    if (previous_vphase /= vphase) then -- New fast mode samples detected. Set outputs.
                        dvalid_fast <= '1';
                        dinvalid_fast <= '0';
                        vphase_fast_validated <= previous_vphase;
                        Y_fast_validated <= Y_fast;
                        CbCr_fast_validated <= CbCr_fast;
                        Y_fast <= vdata;
                        CbCr_fast <= x"00";
                        state_fast <= get_CbCr;
                    else -- Reset - a vphase change should have happened.
                        dvalid_fast <= '0';
                        dinvalid_fast <= '1';
                        Y_fast <= x"00";
                        CbCr_fast <= x"00";
                        state_fast <= get_vphase_sync;
                    end if;
                when get_CbCr =>
                    dvalid_fast <= '0';
                    dinvalid_fast <= '0';
                    if (previous_vphase = vphase) then
                        Y_fast <= Y_fast;
                        CbCr_fast <= vdata;
                        state_fast <= get_Y;
                    else -- Unexpected start of new cycle. Get Y sample.
                        Y_fast <= vdata;
                        CbCr_fast <= x"00";
                        state_fast <= get_CbCr;
                    end if;
                when others => state_fast <= get_vphase_sync;
            end case; --case state_fast is
        end if; -- if (rising_edge(vclk))
    end process;

    -- Select output source from state machines
    source_select: process(vclk)
        variable valid_sample           : std_logic;
        variable vphase_sample          : std_logic;
        variable Y_sample               : std_logic_vector(7 downto 0);
        variable CbCr_sample            : std_logic_vector(7 downto 0);
    begin
        if (rising_edge(vclk)) then
            -- Select source
            if (dvalid_slow = '1') then
                valid_sample := '1';
                vphase_sample := vphase_slow_validated;
                Y_sample := Y_slow_validated;
                CbCr_sample := CbCr_slow_validated;
            elsif (dvalid_fast = '1') then
                valid_sample := '1';
                vphase_sample := vphase_fast_validated;
                Y_sample := Y_fast_validated;
                CbCr_sample := CbCr_fast_validated;
            else
                valid_sample := '0';
            end if;

			-- If new sample exists, set output interface video values and flags
			if (valid_sample = '1') then
				valid_sample := '0';
				dvalid <= '1';
				
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
					end if;	-- if (vphase_sample = '1')
				end if;	-- if (Y_sample = x"00")
			end if;	-- if (valid_sample = '1')
        end if; -- if (rising_edge(vclk))
    end process;

    -- Pixel clock generation
    pclk_generator: process(vclk)
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
