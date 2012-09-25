library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity null_filter is
  generic (
    ID : integer range 0 to 63 := 0);
  port (
    pipe_in   : inout pipe_t;
    pipe_out  : inout pipe_t;
    stall_in  : in    std_logic;
    stall_out : out   std_logic
    );
end null_filter;

architecture impl of null_filter is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;
  signal src_valid  : std_logic;
  signal issue      : std_logic;
  signal stall      : std_logic;

  type    reg_t is record
    cols : natural range 0 to WIDTH;
    rows : natural range 0 to HEIGHT;
  end record;

  signal r      : reg_t;
  signal r_next : reg_t;

  procedure init (variable v : inout reg_t) is
  begin
    v.cols := 0;
    v.rows := 0;
  end init;

begin
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);

  process(pipe_in, r, rst, src_valid)
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
    if 
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
      stage_next.identity <= IDENT_NULL;
    end if;
    if rst = '1' then
      stage_next <= NULL_STAGE;
      init(v);
    end if;
  end process;

  proc_clk : process(clk, rst, stall, pipe_in, stage_next, r_next)  
  begin
    if rising_edge(clk) and (stall = '0' or rst = '1') then
      if pipe_in.cfg(ID).enable = '1' then
        stage <= stage_next;
      else
        stage <= pipe_in.stage;
      end if;
      r <= r_next;
    end if;
  end process;

end impl;
