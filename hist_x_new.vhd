library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity hist_x is
  generic (
    ID     : integer range 0 to 63   := 0;
    WIDTH  : natural range 1 to 2048 := 2048;
    HEIGHT : natural range 1 to 2048 := 2048
    );
  port (
    pipe_in  : inout  pipe_t;
    pipe_out : inout pipe_t;
    hist_row : out natural range 0 to 2047);
end hist_x;

architecture impl of hist_x is

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
    cols : natural range 0 to WIDTH;
    rows : natural range 0 to HEIGHT;
    val  : counter_t;
    cur  : counter_t;

    draw_start : natural range 0 to (HEIGHT-1);
    draw_end   : natural range 0 to (HEIGHT-1);
    draw_area  : natural range 0 to (WIDTH*HEIGHT);
    maxarea    : natural range 0 to (WIDTH*HEIGHT);
    maxstart   : natural range 0 to (WIDTH-1);
    maxend     : natural range 0 to (WIDTH-1);
    area       : natural range 0 to (WIDTH*HEIGHT);
    start      : natural range 0 to (WIDTH-1);
  end record;

  signal r      : reg_t;
  signal r_next : reg_t;

  procedure init (variable v : inout reg_t) is
  begin
    v.cols := 0;
    v.rows := 0;
    v.cur  := 0;
    v.val  := 0;

    v.draw_area  := 0;
    v.draw_start := 0;
    v.draw_end   := 0;
    v.maxarea    := 0;
    v.maxstart   := 0;
    v.maxend     := 0;
    v.area       := 0;
    v.start      := 0;
  end init;
  
begin
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stage, src_valid, issue, stall);

  process (pipe_in, r, src_valid, rst)
    variable v : reg_t;
  begin
    stage_next <= pipe_in.stage;
    v          := r;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------
    if src_valid = '1' then
      if pipe_in.stage.data_1 = "1" then
        v.cur := v.cur + 1;
      end if;

      if v.cols = 0 then
        v.val := v.cur;
        v.cur := 0;
      end if;

-------------------------------------------------------------------------------      
      if v.cols = 0 then
        if v.rows = 0 then
          v.draw_start := v.maxstart;
          v.draw_end   := v.maxend;
          v.draw_area  := v.maxarea;
          v.maxstart   := 0;
          v.maxend     := 0;
          v.maxarea    := 0;
        end if;
        if v.area > 0 then
          -- area is open
          
          if to_unsigned(v.val, 10) < unsigned(pipe_in.cfg(ID).p(1)) then
            -- if lower than threshold
            
            if v.area > v.maxarea then
              --current area bigger
              v.maxstart := v.start;
              v.maxend   := v.rows-1;
              v.maxarea  := v.area;
            else
              v.area := 0;
            end if;
          else
            -- over threshold
            v.area := v.area + v.val;
          end if;

        else
          if to_unsigned(v.val, 10) > unsigned(pipe_in.cfg(ID).p(1)) then
            v.area  := v.val;
            v.start := v.rows;
          end if;
        end if;
      end if;
-------------------------------------------------------------------------------
      
    end if;
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------

    if pipe_in.cfg(ID).p(0)(1) = '1' then    
      if v.cols < v.val then
        stage_next.data_1 <= (others => '1');
      else
        stage_next.data_1 <= (others => '0');
      end if;
    end if;

    if pipe_in.cfg(ID).p(0)(0) = '1' then
      if (v.rows = v.draw_start or v.rows = v.draw_end) and v.draw_area > 0 then
        stage_next.data_565 <= "0000011111100000";
        stage_next.data_1   <= (others => '1');
      end if;
    end if;
-------------------------------------------------------------------------------
-- Counter
-------------------------------------------------------------------------------
    if src_valid = '1' then
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
-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_HISTX;
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

  hist_row <= r.cur;

  proc_clk : process(clk, stall, pipe_in, stage_next)
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
