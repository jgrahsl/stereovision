library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity pipe_head is
  generic (
    ID : integer range 0 to 63 := 0);
  port (
    clk : in std_logic;
    rst : in std_logic;
    cfg : in cfg_set_t;
    pipe_tail : in pipe_t;
    pipe_out : out pipe_t);
end pipe_head;

architecture impl of pipe_head is

begin

  -- modified version of connect_ctrl
  pipe_out.ctrl.clk <= clk;
  pipe_out.ctrl.rst <= rst;
  pipe_out.ctrl.issue <= '0';
  pipe_out.ctrl.stall <= pipe_tail.ctrl.issue;
  
  pipe_out.cfg   <= cfg;
  pipe_out.stage <= NULL_STAGE;

end impl;
