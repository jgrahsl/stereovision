library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity cfg_sync is
  port (
    clk  : in  std_logic;
    din  : in  cfg_set_t;
    dout : out cfg_set_t);
end cfg_sync;

architecture myrtl of cfg_sync is
  signal cfg_0 : cfg_set_t;
  signal cfg_1 : cfg_set_t;
  signal cfg_2 : cfg_set_t;

begin  -- myrtl

  process (clk)
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      cfg_2 <= cfg_1;
      cfg_1 <= cfg_0;
      cfg_0 <= din;
    end if;
  end process;
  dout <= cfg_2;

end myrtl;
