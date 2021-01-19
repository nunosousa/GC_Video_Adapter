-- file: gc_dv_top_level.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gc_dv_top_level is
	port(

	);
	
end entity;

architecture behav of gc_dv_top_level is
	
begin
	process : process(pclk)
	begin
		if (reset = '1') then
			-- Reset something
		elsif (rising_edge(pclk)) then
			if (dvalid_in = '1') then
			
			end if;
		end if;	-- if (reset = '1')
	end process;
end behav;
