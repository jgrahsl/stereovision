library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity translate_win_gray8 is
  generic (
    ID       : integer range 0 to 63   := 0;
    WIDTH    : natural range 1 to 2048 := 2048;
    HEIGHT   : natural range 1 to 2048 := 2048;
    CUT_W    : natural range 0 to 2047 := 0;
    CUT_H    : natural range 0 to 2047 := 0;
    APPEND_W : natural range 0 to 2047 := 0;
    APPEND_H : natural range 0 to 2047 := 0);

  port (
    pipe_in     : in  pipe_t;
    pipe_out    : out pipe_t;
    stall_in    : in  std_logic;
    stall_out   : out std_logic;
    gray8_2d_in  : in  gray8_2d_t;
    gray8_2d_out : out gray8_2d_t
    );
end translate_win_gray8;

architecture impl of translate_win_gray8 is

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
  subtype counter_t is natural range 0 to 2047;
  type    reg_t is record
    cols    : natural range 0 to WIDTH*2;
    rows    : natural range 0 to HEIGHT*2;
  end record;

  signal r      : reg_t;
  signal r_next : reg_t;

  procedure init (variable v : inout reg_t) is
  begin
    v.cols  := 0;
    v.rows  := 0;
  end init;

  signal gray8_2d_next : gray8_2d_t;
begin

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);

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
    if v.rows > (HEIGHT-1) and v.rows <= (HEIGHT+APPEND_H-1) then
      issue             <= pipe_in.cfg(ID).enable;
      stage_next.data_1 <= (others => '0');
      stage_next.valid  <= '1';
      en                := '1';
    end if;

    if v.cols > (WIDTH-1) and v.cols <= (WIDTH+APPEND_W-1) then
      issue             <= pipe_in.cfg(ID).enable;
      stage_next.data_1 <= (others => '0');
      stage_next.valid  <= '1';
      en                := '1';
    end if;

    if v.rows < (CUT_H) then
      stage_next.valid <= '0';
    end if;

    if v.cols < (CUT_W) then
      stage_next.valid <= '0';
    end if;

-------------------------------------------------------------------------------      
--          if to_unsigned(v.val, 10) > unsigned(pipei_n.cfg(ID).p(1)) then
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
      if v.cols = (WIDTH+APPEND_W-1) then
        v.cols := 0;
        if v.rows = (HEIGHT+APPEND_H-1) then
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
      stage_next.identity <= IDENT_TRANSLATE_WIN;
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

  process (pipe_in)
  begin  -- process
      if (pipe_in.cfg(ID).enable = '1') then
        stage <= stage_next;
      else
        stage <= pipe_in.stage;
      end if;
      gray8_2d_out <= gray8_2d_next;

    null;
  end process;
  proc_clk : process(clk, rst, stall, pipe_in, stage_next, r_next)
  begin
    if rising_edge(clk) and (stall = '0' or rst = '1') then
      r <= r_next;
    end if;
  end process;
  gray8_2d_next <= gray8_2d_in;
  

end impl;
