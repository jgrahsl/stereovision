library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity mcb_sink is
  generic (
    ID : integer range 0 to 63 := 0);
  port (
    pipe_in  : in  pipe_t;
    pipe_out : out pipe_t;

    p0_fifo : inout mcb_fifo_t;
    p1_fifo : inout mcb_fifo_t
    );
end mcb_sink;

architecture impl of mcb_sink is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;

  type reg_t is record
    sel_is_high : std_logic;
  end record;
  signal r                   :       reg_t;
  signal r_next              :       reg_t;
  procedure init (variable v : inout reg_t) is
  begin
    v.sel_is_high := '1';
  end init;

  signal avail         : std_logic;
  signal selected_word : std_logic_vector(15 downto 0);
begin
  
  clk <= pipe_in.ctrl.clk;
  rst <= pipe_in.ctrl.rst;

  pipe_out.ctrl  <= pipe_in.ctrl;
  pipe_out.cfg   <= pipe_in.cfg;
  pipe_out.stage <= stage;

  p0_fifo.en  <= pipe_in.stage.valid and not r.sel_is_high;
  p0_fifo.clk <= clk;
  
  p1_fifo.en  <= pipe_in.stage.valid;
  p1_fifo.clk <= clk;

  p0_fifo.data(31 downto 16) <= pipe_in.stage.data_565;
  p1_fifo.data               <= pipe_in.stage.aux;
  
  process (pipe_in)
    variable v : reg_t;
  begin
    stage_next <= pipe_in.stage;
    v          := r;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------    
    if pipe_in.stage.valid = '1' then
      if v.sel_is_high = '1' then
        v.sel_is_high := '0';
      else
        v.sel_is_high := '1';
      end if;
    end if;
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------
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
--      if (pipe_in.cfg(ID).enable = '1') then
      stage <= stage_next;
--      else
--        stage <= pipe_in.stage;
--      end if;
      if r.sel_is_high = '1' then
        p0_fifo.data(15 downto 0) <= pipe_in.stage.data_565;
      end if;
      r <= r_next;
    end if;
  end process;

end impl;
