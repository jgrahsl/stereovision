library ieee;
use ieee.std_logic_1164.all;

package sim_pkg is
  constant KERNEL : natural range 0 to 5    := 5;
  constant WIDTH  : natural range 0 to 2048 := 16;
  constant HEIGHT : natural range 0 to 2048 := 16;
  constant SKIP   : natural range 0 to 15   := 2;
  constant THRESH : natural range 0 to 15   := 10;
end sim_pkg;

package body sim_pkg is
end sim_pkg;
