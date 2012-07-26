library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity window is
  generic (
    ID       : integer range 0 to 63   := 0;
    NUM_COLS : natural range 0 to 5    := 5;
    WIDTH    : natural range 1 to 2048 := 2048;
    HEIGHT   : natural range 1 to 2048 := 2048
    );
  port (
    pipe_in     : in  pipe_t;
    pipe_out    : out pipe_t;
    mono_1d_in  : in  mono_1d_t;
    mono_2d_out : out mono_2d_t
    );
end window;

architecture impl of window is

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
  signal q      : mono_2d_t;
  signal next_q : mono_2d_t;
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

  process(pipe_in)
    variable v : reg_t;
  begin  -- process
    stage_next <= pipe_in.stage;

    v      := r;
    next_q <= q;
-------------------------------------------------------------------------------
-- Counters
-------------------------------------------------------------------------------
    if pipe_in.stage.valid = '1' then
      for i in 0 to (NUM_COLS-2) loop
        next_q(i+1) <= q(i);
      end loop;  -- i

      if r.cols = (WIDTH-1) then
        v.cols := 0;
        next_q <= (others => (others => (others => '0')));
      else
        v.cols := v.cols + 1;
      end if;

      next_q(0) <= mono_1d_in;
    end if;
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------
    mono_2d_out <= q;

    if pipe_in.stage.data_1 = "1" then
      stage_next.data_1   <= (others => '1');
--      stage_next.data_8   <= (others => '1');
--      stage_next.data_565 <= (others => '1');
--      stage_next.data_888 <= (others => '1');
    else
      stage_next.data_1   <= (others => '0');
--      stage_next.data_8   <= (others => '0');
--      stage_next.data_565 <= (others => '0');
--      stage_next.data_888 <= (others => '0');
    end if;
-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if rst = '1' then
      init(v);
      next_q     <= (others => (others => (others => '0')));
      stage_next <= NULL_STAGE;
    end if;
-------------------------------------------------------------------------------
-- Next
-------------------------------------------------------------------------------    
    rin <= v;
  end process;

  proc_clk : process(pipe_in)
  begin
    if rising_edge(clk) then
      if (pipe_in.cfg(ID).enable = '1') then
        stage <= stage_next;
      else
        stage <= pipe_in.stage;
      end if;
      r <= rin;
      q <= next_q;
    end if;
  end process;

end impl;
