library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity translate is
  generic (
    ID     : integer range 0 to 63   := 0;
    WIDTH  : natural range 1 to 2048 := 2048;
    HEIGHT : natural range 1 to 2048 := 2048;
    CUT    : natural range 0 to 2047 := 0;
    APPEND : natural range 0 to 2047 := 0);
  port (
    pipe_in  : inout pipe_t;
    pipe_out : inout pipe_t);
end translate;

architecture impl of translate is

-------------------------------------------------------------------------------
-- Pipe
-------------------------------------------------------------------------------
  
  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;
  signal src_valid  : std_logic;
  signal issue      : std_logic;
  signal stall      : std_logic;

-------------------------------------------------------------------------------
-- Register
-------------------------------------------------------------------------------
  type state_t is (PRE_S, WAIT_S, EMIT_S);

  subtype counter_t is natural range 0 to 2047;
  type    reg_t is record
    cols      : natural range 0 to WIDTH*2;
    rows      : natural range 0 to HEIGHT*2;
    state     : state_t;
  end record;

  signal r      : reg_t;
  signal r_next : reg_t;

  procedure init (variable v : inout reg_t) is
  begin
    v.cols  := 0;
    v.rows  := 0;
    v.state := PRE_S;
  end init;
begin

  connect_pipe(clk, rst, pipe_in, pipe_out, stage, src_valid, issue, stall);

  process (pipe_in, r, src_valid, rst)
    variable v  : reg_t;
    variable en : std_logic;
  begin
    stage_next <= pipe_in.stage;
    v          := r;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------

    en                                := '0';
    issue                             <= '0';
    if v.rows > (HEIGHT-1) and v.rows <= (HEIGHT+APPEND-1) then
      issue             <= pipe_in.cfg(ID).enable;
      stage_next.data_1 <= (others => '0');
      stage_next.valid  <= '1';
      en                := '1';
    end if;

    if v.cols > (WIDTH-1) and v.cols <= (WIDTH+APPEND-1) then
      issue             <= pipe_in.cfg(ID).enable;
      stage_next.data_1 <= (others => '0');
      stage_next.valid  <= '1';
      en                := '1';
    end if;

    if v.rows < (CUT) then
      stage_next.valid <= '0';
    end if;

    if v.cols < (CUT) then
      stage_next.valid <= '0';
    end if;

-------------------------------------------------------------------------------      
--          if to_unsigned(v.val, 10) > unsigned(pipe_in.cfg(ID).p(1)) then
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------
    --if pipe_in.cfg(ID).p(0)(0) = '1' then
    --  if (v.rows = v.draw_start or v.rows = v.draw_end) and v.draw_area > 0 then
    --    stage_next.data_565 <= "0000011111100000";
    --    stage_next.data_1   <= (others => '1');
    --  end if;
    --end if;
-------------------------------------------------------------------------------
-- Counter
-------------------------------------------------------------------------------
    if src_valid = '1' or en = '1' then
      if v.cols = (WIDTH+APPEND-1) then
        v.cols := 0;
        if v.rows = (HEIGHT+APPEND-1) then
          v.rows := 0;
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
      stage_next.identity <= IDENT_TRANSLATE;
    end if;
    if rst = '1' then
      stage_next <= NULL_STAGE;
      init(v);
    end if;
-------------------------------------------------------------------------------
-- Next
-------------------------------------------------------------------------------    
    r_next <= v;
  end process;

  proc_clk : process(clk, stall, pipe_in, stage_next, r_next)
  begin
    if rising_edge(clk) and stall = '0' then
      if (pipe_in.cfg(ID).enable = '1') then
        stage <= stage_next;
      else
        stage <= pipe_in.stage;
      end if;
      r <= r_next;
    end if;
  end process;

end impl;
