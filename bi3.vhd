library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity bi3 is
  generic (
    ID     : integer range 0 to 63   := 0;
    WIDTH  : natural range 0 to 2048 := 2048;
    HEIGHT : natural range 0 to 2048 := 2048);
  port (
    pipe_in     : in  pipe_t;
    pipe_out    : out pipe_t;
    stall_in    : in  std_logic;
    stall_out   : out std_logic;
    abcd2     : in abcd2_t
    );
end bi3;

architecture impl of bi3 is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;
  signal src_valid  : std_logic;
  signal issue      : std_logic;
  signal stall      : std_logic;

  type reg_t is record
    cols : natural range 0 to WIDTH-1;
    rows : natural range 0 to HEIGHT-1;
  end record;

  signal r      : reg_t;
  signal r_next : reg_t;

  procedure init (variable v : inout reg_t) is
  begin
    v.cols := 0;
    v.rows := 0;
  end init;

  signal o : signed(gray8_t'length+1+COMMA+SUBGRID_BITS-1 downto 0);
  signal x : gray8_t;
begin 
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);
  
  bilinear_1 : entity work.bilinear
    generic map (
      REF_BITS  => (gray8_t'length+1),
      FRAC_BITS => SUBGRID_BITS+COMMA)
    port map (
      a  => signed(abcd2.a),
      b  => signed(abcd2.b),
      c  => signed(abcd2.c),
      d  => signed(abcd2.d),
      rx => abcd2.x_frac,
      ry => abcd2.y_frac,
      o  => o);
  
  process(pipe_in, r, rst, src_valid,o)
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
    stage_next.data_8 <= std_logic_vector(o(o'high-1 downto o'high-(gray8_t'length)+1-1));
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
------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_BI3;
    end if;
    if rst = '1' then
      stage_next <= NULL_STAGE;
      init(v);
    end if;
    r_next <= v;
  end process;

  proc_clk : process(clk, rst, stall, pipe_in, stage_next, r_next,abcd2)
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
