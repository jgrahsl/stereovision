library ieee;
use ieee.std_logic_1164.all;

package sim_pkg is
  constant WIDTH  : natural range 0 to 2048 := 384;
  constant HEIGHT : natural range 0 to 2048 := 288;
  constant SKIP   : natural range 0 to 15   := 0;
  constant KERNEL : natural range 0 to 15   := 9;
  constant OFFSET : natural range 0 to 24   := 2*5+2;  
  constant MAX_DISPARITY : natural := 32;
  constant sim_file : string  := "sim.out";
  constant stim_file : string  := "stereo.dat";

end sim_pkg;

package body sim_pkg is
end sim_pkg;
