library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity motion is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    vin       : in  stream_t;
    vin_data  : in  std_logic_vector(7 downto 0);
    vout      : out stream_t;
    vout_data : out std_logic_vector(0 downto 0)
    );
end motion;

architecture impl of motion is

type nullfilter_t is record
  data  : std_logic_vector(0 downto 0);
  vin   : stream_t;
end record;

signal r : nullfilter_t;
signal r_next : nullfilter_t;

-------------------------------------------------------------------------------
-- Implementation
-------------------------------------------------------------------------------  
begin  -- impl

  vout <= r.vin;
  vout_data <= r.data;

  process (r, vin, vin_data)
  begin 
	r_next.vin <= vin;
   if unsigned(vin_data) < X"EC" then
     r_next.data <= "0";
   else
     r_next.data <= "1";       
   end if;

  end process;

  proc_clk : process(clk, rst)
  begin
    if rst = '1' then
      r.vin.valid <= '0';
      r.vin.init <= '0';
    else 
		if rising_edge(clk) then
			r <= r_next;
		end if;
    end if;
  end process;

end impl;
