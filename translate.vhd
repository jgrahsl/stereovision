library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity translate is
  generic (
    ID         : integer range 0 to 63   := 0;
    WIDTH      : natural range 1 to 2048 := 2048;
    HEIGHT     : natural range 1 to 2048 := 2048;
    PRE_COUNT  : natural range 0 to 2047 := 0;
    POST_COUNT : natural range 0 to 2047 := 0);
  port (
    pipe_in  : in  pipe_t;
    pipe_out : out pipe_t);
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
    cols      : natural range 0 to WIDTH;
    rows      : natural range 0 to HEIGHT;
    pixel     : natural range 0 to (WIDTH*HEIGHT*2);
    post      : natural range 0 to (WIDTH*HEIGHT*2);
    state     : state_t;
    pixel_rst : std_logic;
  end record;

  signal r      : reg_t;
  signal r_next : reg_t;

  procedure init (variable v : inout reg_t) is
  begin
    v.cols  := 0;
    v.rows  := 0;
    v.post  := 0;
    v.pixel := 0;
    v.state := PRE_S;
  end init;
  
begin
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stage, src_valid, issue, stall);

  process (pipe_in, r, src_valid, rst)
    variable v : reg_t;
  begin
    stage_next  <= pipe_in.stage;
    v           := r;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------
    v.pixel_rst := '0';
    case (v.state) is
      when PRE_S =>
        if v.pixel >= PRE_COUNT then
          v.state := WAIT_S;
        else
          stage_next.valid <= '0';
        end if;
      when WAIT_S =>
        if v.pixel >= (HEIGHT*WIDTH+PRE_COUNT) then
          v.state := EMIT_S;
          v.post  := 0;
        end if;
      when EMIT_S =>
        v.post := v.post + 1;
        if v.post >= (POST_COUNT) then
          v.pixel_rst := '1';
          v.state     := PRE_S;
        else
          stage_next.valid  <= '1';
          stage_next.data_1 <= (others => '1');
        end if;
      when others => null;
    end case;

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
    if src_valid = '1' then
      v.pixel := v.pixel + 1;
      if v.cols = (WIDTH-1) then
        v.cols := 0;
        if v.rows = (HEIGHT-1) then
          v.rows := 0;
        else
          v.rows := v.rows + 1;
        end if;
      else
        v.cols := v.cols + 1;
      end if;
    end if;

    if v.pixel_rst = '1' then
      v.pixel := 0;
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
