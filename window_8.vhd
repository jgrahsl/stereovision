library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity window_8 is
  generic (
    ID       : integer range 0 to 63   := 0;
    NUM_COLS : natural range 0 to 5    := 5;
    WIDTH    : natural range 1 to 2048 := 2048;
    HEIGHT   : natural range 1 to 2048 := 2048
    );
  port (
    pipe_in     : in  pipe_t;
    pipe_out    : out pipe_t;
    stall_in    : in  std_logic;
    stall_out   : out std_logic;
    gray8_1d_in  : in  gray8_1d_t;
    gray8_2d_out : out gray8_2d_t
    );
end window_8;

architecture impl of window_8 is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;
  signal src_valid  : std_logic;
  signal issue      : std_logic;
  signal stall      : std_logic;

  type reg_t is record
    cols : natural range 0 to WIDTH;
    rows : natural range 0 to HEIGHT;
  end record;
  signal r                   :       reg_t;
  signal rin                 :       reg_t;
  signal q                   :       gray8_2d_t;
  signal next_q              :       gray8_2d_t;
  procedure init (variable v : inout reg_t) is
  begin
    v.cols := 0;
    v.rows := 0;
  end init;
  
begin
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);

  process(pipe_in, stage, r, q, src_valid, rst, gray8_1d_in)
    variable v : reg_t;
  begin  -- process
    stage_next <= pipe_in.stage;

    v      := r;
    next_q <= q;
-------------------------------------------------------------------------------
-- Counters
-------------------------------------------------------------------------------
    if src_valid = '1' then
      for i in 0 to (NUM_COLS-2) loop
        next_q(i+1) <= q(i);
      end loop;  -- i

      if r.cols = (WIDTH-1) then
        v.cols := 0;
--        next_q <= (others => (others => (others => '0')));
      else
        v.cols := v.cols + 1;
      end if;

      next_q(0) <= gray8_1d_in;
    end if;
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------
    gray8_2d_out <= q;
-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_WINDOW_8;
    end if;
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

  proc_clk : process(clk, rst, stall, stage_next, pipe_in)
  begin
    if rising_edge(clk) and (stall = '0' or rst = '1') then
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
