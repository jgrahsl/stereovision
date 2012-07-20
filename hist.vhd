library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity hist is
  generic (
    ID : integer range 0 to 63 := 0;
    WIDTH    : natural range 1 to 2048 := 2048;
    HEIGHT   : natural range 1 to 2048 := 2048
    );
  port (
    pipe_in  : in  pipe_t;
    pipe_out : out pipe_t);
end hist;

architecture impl of hist is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;

  type reg_t is record
    cols : natural range 0 to WIDTH;
    rows : natural range 0 to HEIGHT;
  end record;
  signal r   : reg_t;
  signal rin : reg_t;
  procedure init (variable v : inout reg_t) is
  begin
    v.cols := 0;
    v.rows := 0;
  end init;
  
begin
  
  clk <= pipe_in.ctrl.clk;
  rst <= pipe_in.ctrl.rst;

  pipe_out.ctrl  <= pipe_in.ctrl;
  pipe_out.cfg   <= pipe_in.cfg;
  pipe_out.stage <= stage;

  process (pipe_in)
    variable v : reg_t;
  begin
    stage_next <= pipe_in.stage;
    v      := r;

    rin         <= v;    
  end process;

  proc_clk : process(pipe_in)
  begin
    if rst = '1' then
      stage.valid <= '0';
      stage.init  <= '0';
    else
      if rising_edge(clk) then
        if (pipe_in.cfg(ID).enable = '1') then
          stage <= stage_next;
        else
          stage <= pipe_in.stage;
        end if;
      end if;
    end if;
  end process;

end impl;
