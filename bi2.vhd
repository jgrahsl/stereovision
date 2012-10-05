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
    pipe_in     : in  pipe_t;
    pipe_out    : out pipe_t;
    stall_in    : in  std_logic;
    stall_out   : out std_logic;
    abcd        : in  abcd_t;
    gray8_2d_in : in  gray8_2d_t;
    abcd2     : out abcd2_t
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
    cols : natural range 0 to WIDTH-1;
    rows : natural range 0 to HEIGHT-1;
    disx : unsigned(5 downto 0);
    disy : unsigned(5 downto 0);
  end record;

  signal r      : reg_t;
  signal r_next : reg_t;

  procedure init (variable v : inout reg_t) is
  begin
    v.cols := 0;
    v.rows := 0;
    v.disx := (others => '0');
    v.disy := (others => '0');    
  end init;

  signal x  : unsigned(15 downto 0);
  signal y  : unsigned(15 downto 0);
  signal ox : signed((ABCD_BITS/2)+SUBGRID_BITS-1 downto 0);
  signal oy : signed((ABCD_BITS/2)+SUBGRID_BITS-1 downto 0);

  signal x_pixel : unsigned((ABCD_BITS/2)-1 downto 0);
  signal y_pixel : unsigned((ABCD_BITS/2)-1 downto 0);  
  signal x_frac : unsigned(SUBGRID_BITS-1 downto 0);
  signal y_frac : unsigned(SUBGRID_BITS-1 downto 0);

  signal abcd2_next : abcd2_t;
begin 
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);

  x <= unsigned(to_unsigned(r.cols, x'length));
 y <= unsigned(to_unsigned(r.rows, y'length));

  bilinear_1 : entity work.bilinear
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

  bilinear_2 : entity work.bilinear
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

  x_pixel <= unsigned(std_logic_vector(ox(ox'high downto ox'high-(ABCD_BITS/2)+1)));
  y_pixel <= unsigned(std_logic_vector(oy(oy'high downto oy'high-(ABCD_BITS/2)+1)));
  x_frac <= unsigned(std_logic_vector(ox(SUBGRID_BITS-1 downto 0)));
  y_frac <= unsigned(std_logic_vector(oy(SUBGRID_BITS-1 downto 0)));
   
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
    abcd2_next.a <= "0" & gray8_2d_in(to_integer(y_pixel*5 + x_pixel));
    if to_integer(y_pixel*5 + x_pixel+1) < 25 then
      abcd2_next.b <= "0" & gray8_2d_in(to_integer(y_pixel*5 + x_pixel+1));
    else
      abcd2_next.b <= (others => '0');
    end if;
    if to_integer((y_pixel+1)*5 + x_pixel) < 25 then    
      abcd2_next.c <= "0" & gray8_2d_in(to_integer((y_pixel+1)*5 + x_pixel));
    else
      abcd2_next.c <= (others => '0');
    end if;
    if to_integer((y_pixel+1)*5 + x_pixel+1) < 25 then
      abcd2_next.d <= "0" & gray8_2d_in(to_integer((y_pixel+1)*5 + x_pixel+1));
    else
      abcd2_next.d <= (others => '0');      
    end if;
    abcd2_next.x_frac <= x_frac;
    abcd2_next.y_frac <= y_frac;    
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
      stage_next.identity <= IDENT_BI2;
    end if;
    if rst = '1' then
      stage_next <= NULL_STAGE;
      init(v);
    end if;
    r_next <= v;
  end process;

  proc_clk : process(clk, rst, stall, pipe_in, stage_next, r_next, gray8_2d_in)
  begin
    if rising_edge(clk) and (stall = '0' or rst = '1') then
      if pipe_in.cfg(ID).enable = '1' then
        stage <= stage_next;
      else
        stage <= pipe_in.stage;
      end if;
      r <= r_next;
      abcd2 <= abcd2_next;
    end if;
  end process;
end impl;
