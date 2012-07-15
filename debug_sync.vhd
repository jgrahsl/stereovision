library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity debug_sync is
  port (
    clk       : in  std_logic;
    din : in fbctl_debug_t;
    dout : out fbctl_debug_t);

end debug_sync;

architecture myrtl of debug_sync is
  signal fbctl_debug_0   : fbctl_debug_t;
  signal fbctl_debug_1   : fbctl_debug_t;
  signal fbctl_debug_2   : fbctl_debug_t;

begin  -- myrtl

  process (clk)
  begin  -- process
    if clk'event and clk = '1' then  -- rising clock edge
      fbctl_debug_2 <= fbctl_debug_1;
      fbctl_debug_1 <= fbctl_debug_0;
      fbctl_debug_0 <= din;
    end if;
  end process;
  dout <= fbctl_debug_2;

end myrtl;
