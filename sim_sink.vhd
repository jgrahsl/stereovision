library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity sim_sink is
  generic (
    ID : integer range 0 to 63 := 0);
  port (
    pipe_in   : in    pipe_t;
    pipe_out  : out   pipe_t;
    stall_in  : in    std_logic;
    stall_out : out   std_logic;
    p0_fifo   : inout sim_fifo_t);
end sim_sink;

architecture impl of sim_sink is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal issue      : std_logic := '0';
  signal stall      : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;
  signal src_valid  : std_logic;

  type reg_t is record
    temp : std_logic;
  end record;
  signal r                   :       reg_t;
  signal r_next              :       reg_t;
  procedure init (variable v : inout reg_t) is
  begin
    v.temp := '1';
  end init;

  signal avail : std_logic;
  signal cnt   : natural range 0 to 10 := 5;
begin

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);

  p0_fifo.clk <= clk;

  p0_fifo.en                                  <= src_valid and not rst;
  p0_fifo.data(0 downto 0)                    <= pipe_in.stage.data_1;
  p0_fifo.data((8+1)-1 downto (1))            <= pipe_in.stage.data_8;
  p0_fifo.data((16+8+1)-1 downto (8+1))       <= pipe_in.stage.data_565;
  p0_fifo.data((24+16+8+1)-1 downto (16+8+1)) <= pipe_in.stage.data_888;

  process (pipe_in, r, rst)  
    variable v : reg_t;
  begin
    stage_next <= pipe_in.stage;
    v          := r;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------    
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_SIMSINK;
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
    if rising_edge(clk) then
      issue <= '0';
      if cnt = 0 then
        issue <= '1';
      end if;
      if cnt < 1 then
        cnt <= cnt + 1;
      else
        cnt <= 0;
      end if;
    end if;
    issue <= '0';
  end process;

end impl;
