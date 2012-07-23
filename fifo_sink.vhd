library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity fifo_sink is
  generic (
    ID : integer range 0 to 63 := 0;
    WIDTH  : natural range 1 to 2048 := 2048;
    HEIGHT : natural range 1 to 2048 := 2048
    );
  port (
    pipe_in  : in  pipe_t;
    pipe_out : out pipe_t;

    fifo : inout pixel_fifo_t
    );
end fifo_sink;

architecture impl of fifo_sink is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;

  type reg_t is record
    cols    : natural range 0 to WIDTH-1;
    rows    : natural range 0 to HEIGHT-1;
    old     : std_logic;
    enabled : std_logic;
  end record;
  signal r                   :       reg_t;
  signal r_next              :       reg_t;
  procedure init (variable v : inout reg_t) is
  begin
    v.cols    := 0;
    v.rows    := 0;
    v.old     := '0';
    v.enabled := '0';
  end init;
  signal col_bits : std_logic_vector(9 downto 0);
begin
  
  clk <= pipe_in.ctrl.clk;
  rst <= pipe_in.ctrl.rst;

  pipe_out.ctrl  <= pipe_in.ctrl;
  pipe_out.cfg   <= pipe_in.cfg;
  pipe_out.stage <= stage;

  col_bits <=  std_logic_vector(to_unsigned(r.cols,10));
  
  fifo.en   <= pipe_in.stage.valid and r.enabled and not col_bits(0) and not col_bits(1) and not col_bits(2) and not col_bits(3) and not col_bits(4) and not col_bits(5) and not col_bits(6);
  fifo.clk  <= clk;
  fifo.data <= pipe_in.stage.data_565;

  process (pipe_in)
    variable v : reg_t;
  begin
    stage_next <= pipe_in.stage;
    v := r;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Counter
-------------------------------------------------------------------------------
    if pipe_in.stage.valid = '1' then
      if v.cols = (WIDTH-1) then
        v.cols := 0;
        if v.rows = (HEIGHT-1) then
          v.rows    := 0;
          v.enabled := '0';
          if v.old /= pipe_in.cfg(ID).p(0)(0) then
            v.old     := pipe_in.cfg(ID).p(0)(0);
            v.enabled := '1';
          end if;
        else
          v.rows := v.rows + 1;
        end if;
      else
        v.cols := v.cols + 1;
      end if;
    end if;
-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if rst = '1' then
      stage_next <= NULL_STAGE;
      init(v);
    end if;
    r_next <= v;
  end process;

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
