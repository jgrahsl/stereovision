library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity nullfilter is


  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    vin       : in  stream_t;
    vin_data  : in  bit_window2d_t;
    vout      : out stream_t;
    vout_data : out bit_t
    );
end nullfilter;

architecture impl of nullfilter is

type nullfilter_t is record
  data  : bit_t;
  vin   : stream_t;
end record;

signal r : nullfilter_t;
signal r2 : nullfilter_t;
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
   r_next.data <= vin_data(0)(0);
  end process;

  proc_clk : process(clk, rst)
  begin
    if rst = '1' then
      r.vin.valid <= '0';
      r.vin.init <= '0';
    else 
		if rising_edge(clk) then
			r <= r_next;
         r2 <= r;
		end if;
    end if;
  end process;

end impl;
