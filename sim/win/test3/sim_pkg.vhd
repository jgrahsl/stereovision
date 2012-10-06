library ieee;
use ieee.std_logic_1164.all;

package sim_pkg is
  constant WIDTH  : natural range 0 to 2048 := 16;
  constant HEIGHT : natural range 0 to 2048 := 16;
  constant SKIP   : natural range 0 to 15   := 0;
  constant KERNEL : natural range 0 to 15   := 5;
  constant OFFSET : natural range 0 to 24   := 4*5+4;
end sim_pkg;

package body sim_pkg is
end sim_pkg;
