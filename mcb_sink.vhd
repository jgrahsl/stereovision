library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity mcb_sink is
  generic (
    ID : integer range 0 to 63 := 0);
  port (
    pipe_in  : inout  pipe_t;
    pipe_out : inout pipe_t;
    stall_in : in std_logic;
    stall_out : out std_logic;
    p0_fifo : inout mcb_fifo_t;
    p1_fifo : inout mcb_fifo_t
    );
end mcb_sink;

architecture impl of mcb_sink is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal issue      : std_logic := '0';
  signal stall      : std_logic;  
  signal stage      : stage_t;
  signal stage_next : stage_t;
  signal src_valid : std_logic;
  
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

begin

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);
  
  avail <= src_valid and pipe_in.cfg(ID).enable and pipe_in.cfg(ID).p(0)(0) and not p0_fifo.stall and not p1_fifo.stall and not stall;
  
  p0_fifo.en  <= avail and not r.sel_is_high;
  p0_fifo.clk <= clk;
  
  p1_fifo.en  <= avail;
  p1_fifo.clk <= clk;

  p0_fifo.data(31 downto 16) <= pipe_in.stage.data_565;
  p1_fifo.data               <= pipe_in.stage.aux;

  issue <= (p0_fifo.stall or p1_fifo.stall) and pipe_in.cfg(ID).enable and pipe_in.cfg(ID).p(0)(0);
  
  process (pipe_in, r, rst, avail)
    variable v : reg_t;
  begin
    stage_next <= pipe_in.stage;
    v          := r;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------    
    if avail = '1' then
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
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_MCBSINK;
    end if;
    if rst = '1' then
      stage_next <= NULL_STAGE;
      init(v);
    end if;

    r_next <= v;
  end process;

  proc_clk : process(clk, rst, stall, pipe_in, stage_next, r_next)
  begin
    if rising_edge(clk) and (stall = '0' or rst = '1') then
      if (pipe_in.cfg(ID).enable = '1') then
        stage <= stage_next;
      else
        stage <= pipe_in.stage;
      end if;
      if r.sel_is_high = '1' then
        p0_fifo.data(15 downto 0) <= pipe_in.stage.data_565;
      end if;
      r <= r_next;
    end if;
  end process;
  

end impl;
