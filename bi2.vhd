library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity bi2 is
  generic (
    ID     : integer range 0 to 63   := 0;
    WIDTH  : natural range 0 to 2048 := 2048;
    HEIGHT : natural range 0 to 2048 := 2048);
  port (
    pipe_in   : in  pipe_t;
    pipe_out  : out pipe_t;
    stall_in  : in  std_logic;
    stall_out : out std_logic;
    abcd      : in abcd_t
    );
end bi2;

architecture impl of bi2 is

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

  signal r      : reg_t;
  signal r_next : reg_t;

  procedure init (variable v : inout reg_t) is
  begin
    v.cols := 0;
    v.rows := 0;
  end init;

  signal x : unsigned(15 downto 0);
  signal y : unsigned(15 downto 0);
  signal ox : signed((ABCD_BITS/2)+SUBGRID_BITS-1 downto 0);
  signal oy : signed((ABCD_BITS/2)+SUBGRID_BITS-1 downto 0);  
begin
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);

  x <= unsigned(to_unsigned(r.cols, x'length));
  y <= unsigned(to_unsigned(r.rows, y'length));
  
  bilinear_1: entity work.bilinear
    generic map (
      REF_BITS  => ABCD_BITS/2,
      FRAC_BITS => SUBGRID_BITS)
    port map (
      a  => abcd.ax,
      b  => abcd.bx,
      c  => abcd.cx,
      d  => abcd.dx,
      rx => x(SUBGRID_BITS-1 downto 0),
      ry => y(SUBGRID_BITS-1 downto 0),
      o  => ox);

  bilinear_2: entity work.bilinear
    generic map (
      REF_BITS  => ABCD_BITS/2,
      FRAC_BITS => SUBGRID_BITS)
    port map (
      a  => abcd.ay,
      b  => abcd.by,
      c  => abcd.cy,
      d  => abcd.dy,
      rx => x(SUBGRID_BITS-1 downto 0),
      ry => y(SUBGRID_BITS-1 downto 0),
      o  => oy);
  
  
  process(pipe_in, r, rst, src_valid)
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
    r_next <= v;
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
