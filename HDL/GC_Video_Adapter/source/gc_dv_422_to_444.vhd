-- file: gc_dv_422_to_444.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_422_to_444 is
   generic(
		fcoefs		: integer_vector := (1, 1) -- correct this to unsigned vector with n bits wide
   );
	port(
		pclk		: in	std_logic;
		Y			: in	std_logic_vector(7 downto 0);
		CbCr		: in	std_logic_vector(7 downto 0);
		is_Cr		: in	std_logic;
		is_odd		: in	std_logic;
		H_sync		: in	std_logic;
		V_sync		: in	std_logic;
		C_sync		: in	std_logic;
		Blanking	: in	std_logic;
		dvalid		: in	std_logic;
		reset		: in	std_logic;
		Y_dly		: out	std_logic_vector(7 downto 0);
		Cb_flt		: out	std_logic_vector(7 downto 0);
		Cr_flt		: out	std_logic_vector(7 downto 0);
		H_sync_dly	: out	std_logic;
		V_sync_dly	: out	std_logic;
		C_sync_dly	: out	std_logic;
		dvalid_dly	: out	std_logic
	);

end entity;

architecture behav of gc_dv_422_to_444 is
	constant Y_plen		: integer := 4*fcoefs'range;
	constant CbCr_plen	: integer := 2*fcoefs'range;
	
	signal Y_pipe		: is array(0 to Y_plen - 1) of unsigned(7 downto 0);
	signal Cb_pipe		: is array(0 to CbCr_plen - 1) of unsigned(7 downto 0);
	signal Cr_pipe		: is array(0 to CbCr_plen - 1) of unsigned(7 downto 0);

begin
	process : process(pclk)
	begin
		if (reset = '1') then
			-- Reset something
		elsif (rising_edge(pclk)) then
			if (dvalid_in = '1') then
			
				-- Delay sample values
				delay_Y : for i in 1 to Y_plen loop
					Y_pipe(i) <= Y_pipe(i - 1);
				end loop;
				Y_pipe(0) <= Y;
				
				delay_CbCr : for i in 1 to CbCr_plen loop
					if (is_Cr = '1') then
						Cr_pipe(i) <= Cr_pipe(i - 1);
					else
						Cb_pipe(i) <= Cb_pipe(i - 1);
					end if;
				end loop;
				
				if (is_Cr = '1') then
					Cr_pipe(0) <= CbCr;
				else
					Cb_pipe(0) <= CbCr;
				end if;
			
			
			
			
			end if;
		end if;	-- if (reset = '1')
	end process;
end behav;
