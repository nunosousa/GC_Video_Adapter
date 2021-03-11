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

--    -- State machine transitions - vdata: <Y0><Y0><CbCr0><CbCr0><Y1><Y1><CbCr1><CbCr1>...
--    state_update_slow: process(vclk)
--    begin
--        if (rising_edge(vclk)) then
--            -- State machine transitions
--            case state_slow is
--                when s0 =>  -- Reset state - Y sample
--                    pclk_slow <= '0';
--                    Y_slow <= vdata;
--                    state_slow <= s2;
--                when s1 =>  -- Y sample
--                    pclk_slow <= '0';
--                    Y_slow <= vdata;
--                    if (false) then
--                        state_slow <= s2; -- Slow mode detected.
--                        if (Y_slow = x"00") then	-- blanking data
--                            Y <= x"10";
--                            CbCr <= x"80";
--                            H_sync <= not CbCr_slow(4);	-- Active low.
--                            V_sync <= not CbCr_slow(5);	-- Active low.
--                            is_odd <= not CbCr_slow(6);	-- Active low.
--                            C_sync <= not CbCr_slow(7);	-- Active low.
--                            Blanking <= '1';
--                            is_Cr <= '0';
--                        else						-- video sample
--                            Y <= Y_slow;
--                            CbCr <= CbCr_slow;
--                            H_sync <= '0';
--                            V_sync <= '0';
--                            is_odd <= '0';
--                            C_sync <= '0';
--                            Blanking <= '0';
--                        
--                            if (previous_vphase = '1') then
--                                is_Cr <= '1';
--                            else
--                                is_Cr <= '0';
--                            end if;	-- if (vphase = '1')
--                        end if;	-- if (Y_sample = x"00")
--                    else
--                        state_slow <= s0; -- Reset - a vphase change chould have happened.
--                    end if;
--                when s2 =>  -- Still Y sample
--                    pclk_slow <= '0';
--                    if (previous_vphase /= vphase) then
--                        state_slow <= s0; -- Reset - wrong timing for vphase change.
--                    else
--                        state_slow <= s3;
--                    end if;
--                when s3 =>  -- CbCr sample
--                    pclk_slow <= '1';
--                    CbCr_slow <= vdata;
--                    if (previous_vphase /= vphase) then
--                        state_slow <= s0; -- Reset - Fast mode detected.
--                    else
--                        state_slow <= s4;
--                    end if;
--                when s4 =>  -- Still CbCr sample
--                    pclk_slow <= '1';
--                    if (previous_vphase /= vphase) then
--                        state_slow <= s0; -- Reset - wrong timing for vphase change.
--                    else
--                        state_slow <= s1;
--                    end if;
--                when others => state_slow <= s0;
--            end case;
--        end if; -- if (rising_edge(vclk))
--    end process;

    -- State machine transitions - vdata: <Y0><CbCr0><Y1><CbCr1>...
    state_update_fast: process(vclk)
    begin
        if (rising_edge(vclk)) then
            -- State machine transitions
            case state_fast is
                when s0 =>  -- Reset state - Y sample
                    pclk_fast <= '0';
                    Y_fast <= vdata;
                    dvalid_fast <= '0';
                    dvalid <= '1';
                    state_fast <= s2;
                when s1 =>  -- Y sample
                    pclk_fast <= '0';
                    Y_fast <= vdata;
                    if (previous_vphase /= vphase) then
                        dvalid_fast <= '1';
                        dvalid <= '1';
                        if (Y_fast = x"00") then	-- blanking data
                            Y <= x"10";
                            CbCr <= x"80";
                            H_sync <= not CbCr_fast(4);	-- Active low.
                            V_sync <= not CbCr_fast(5);	-- Active low.
                            is_odd <= not CbCr_fast(6);	-- Active low.
                            C_sync <= not CbCr_fast(7);	-- Active low.
                            Blanking <= '1';
                            is_Cr <= '0';
                        else						-- video sample
                            Y <= Y_fast;
                            CbCr <= CbCr_fast;
                            H_sync <= '0';
                            V_sync <= '0';
                            is_odd <= '0';
                            C_sync <= '0';
                            Blanking <= '0';
                            if (previous_vphase = '1') then is_Cr <= '1'; else is_Cr <= '0'; end if;
                        end if;	-- if (Y_sample = x"00")
                        state_fast <= s2; -- Fast mode detected.
                    else
                        state_fast <= s0; -- Reset - a vphase change chould have happened.
                    end if;
                when s2 =>  -- CbCr sample
                    if (dvalid_fast = '1') then pclk_fast <= '1'; else pclk_fast <= '0'; end if;
                    CbCr_fast <= vdata;
                    if (previous_vphase /= vphase) then
                        state_fast <= s0; -- Reset - wrong timing for vphase change.
                    else
                        state_fast <= s1;
                    end if;
                when others => state_fast <= s0;
            end case;
        end if; -- if (rising_edge(vclk))
    end process;
end behav;
