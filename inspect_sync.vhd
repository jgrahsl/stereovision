library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity inspect_sync is
  port (
    clk  : in  std_logic;
    din  : in  inspect_t;
    dout : out inspect_t);
end inspect_sync;

architecture myrtl of inspect_sync is
  signal inspect_0 : inspect_t;
  signal inspect_1 : inspect_t;
  signal inspect_2 : inspect_t;

begin  -- myrtl

  process (clk)
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      inspect_2 <= inspect_1;
      inspect_1 <= inspect_0;
      inspect_0 <= din;
    end if;
  end process;
  dout <= inspect_2;

end myrtl;
