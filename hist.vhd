library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity hist_x is
  generic (
    ID     : integer range 0 to 63   := 0;
    WIDTH  : natural range 1 to 2048 := 2048;
    HEIGHT : natural range 1 to 2048 := 2048
    );
  port (
    pipe_in  : in  pipe_t;
    pipe_out : out pipe_t;
    hist_row : out natural range 0 to 2047);
end hist_x;

architecture impl of hist_x is

-------------------------------------------------------------------------------
-- Pipe
-------------------------------------------------------------------------------
  
  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;

-------------------------------------------------------------------------------
-- Register
-------------------------------------------------------------------------------

  subtype counter_t is natural range 0 to 2047;
  type    reg_t is record
    cols : natural range 0 to WIDTH;
    val  : counter_t;
    cur  : counter_t;
  end record;

  signal r      : reg_t;
  signal r_next : reg_t;

  procedure init (variable v : inout reg_t) is
  begin
    v.cols := 0;
    v.cur  := 0;
    v.val  := 0;
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
    v          := r;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------
    if pipe_in.stage.valid = '1' then
      if pipe_in.stage.data_1 = "1" then
        v.cur := v.cur + 1;
      end if;

      if v.cols = 0 then
        v.val := v.cur;
        v.cur := 0;
      end if;
    end if;
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------
    if v.cols < v.val then
      stage_next.data_1   <= (others => '1');
      stage_next.data_8   <= (others => '1');
      stage_next.data_565 <= (others => '1');
      stage_next.data_888 <= (others => '1');
    else
      stage_next.data_1   <= (others => '0');
      stage_next.data_8   <= (others => '0');
      stage_next.data_565 <= (others => '0');
      stage_next.data_888 <= (others => '0');
    end if;
-------------------------------------------------------------------------------
-- Counter
-------------------------------------------------------------------------------
    if pipe_in.stage.valid = '1' then
      if v.cols = (WIDTH-1) then
        v.cols := 0;
      else
        v.cols := v.cols + 1;
      end if;
    end if;
-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if rst = '1' then
      init(v);
    end if;
-------------------------------------------------------------------------------
-- Next
-------------------------------------------------------------------------------    
    r_next <= v;
  end process;

  hist_row <= r.cur;

  proc_clk : process(pipe_in)
  begin
    if rising_edge(clk) then
      if (pipe_in.cfg(ID).enable = '1') then
        stage <= stage_next;
      else
        stage <= pipe_in.stage;
      end if;
      r <= r_next;
    end if;
  end process;

end impl;
