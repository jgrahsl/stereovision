library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity fifo_sink is
  generic (
    ID     : integer range 0 to 63   := 0;
    WIDTH  : natural range 0 to 2048 := 2048;
    HEIGHT : natural range 0 to 2048 := 2048);    
  port (
    pipe_in   : in    pipe_t;
    pipe_out  : out   pipe_t;
    stall_in  : in    std_logic;
    stall_out : out   std_logic;
    p0_fifo   : inout pixel_fifo_t
    );
end fifo_sink;

architecture impl of fifo_sink is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal issue      : std_logic := '0';
  signal stall      : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;
  signal src_valid  : std_logic;

  type reg_t is record
    cols   : natural range 0 to WIDTH-1;
    rows   : natural range 0 to HEIGHT-1;
    dummy  : std_logic;
    enable : std_logic;
  end record;
  signal r      : reg_t;
  signal r_next : reg_t;

  procedure init (variable v : inout reg_t) is
  begin
    v.cols   := 0;
    v.rows   := 0;
    v.dummy  := '0';
    v.enable := '0';
  end init;

  signal avail : std_logic;

begin

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);

  avail <= src_valid and pipe_in.cfg(ID).enable and not p0_fifo.stall and not stall;

  p0_fifo.en                <= avail and r.enable;
  p0_fifo.clk               <= clk;
  p0_fifo.data(15 downto 0) <= pipe_in.stage.data_565;

  issue <= (p0_fifo.stall) and pipe_in.cfg(ID).enable and r.enable;

  process (pipe_in, p0_fifo, r, rst, src_valid, issue)
    variable v : reg_t;
  begin
    stage_next <= pipe_in.stage;
    v          := r;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------
    if issue = '1' then
      stage_next.valid <= '0';
    end if;
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Counter
-------------------------------------------------------------------------------
    if src_valid = '1' then
      if v.cols = (WIDTH-1) then
        v.cols := 0;
        if v.rows = (HEIGHT-1) then
          v.rows := 0;
          if pipe_in.cfg(ID).p(0)(0) = v.dummy then
            v.enable := '0';
          else
            v.dummy  := pipe_in.cfg(ID).p(0)(0);
            v.enable := '1';
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
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_FIFOSINK;
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
      r <= r_next;
    end if;
  end process;
  

end impl;
