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
    gray8_2d_out : out  gray8_2d_t;
    disx : out unsigned(5 downto 0);
    disy : out unsigned(5 downto 0)
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

  signal shifted_x : signed((ABCD_BITS/2)-1 downto 0);
  signal shifted_y : signed((ABCD_BITS/2)-1 downto 0);

  signal shifted_x2 : signed((ABCD_BITS/2)-1 downto 0);
  signal shifted_y2 : signed((ABCD_BITS/2)-1 downto 0);  

  signal ux : STD_LOGIC_VECTOR((ABCD_BITS/2)-1 downto 0);
  signal uy : STD_LOGIC_VECTOR((ABCD_BITS/2)-1 downto 0);  

  signal usx : unsigned((ABCD_BITS/2)-1 downto 0);
  signal usy : unsigned((ABCD_BITS/2)-1 downto 0);    

  signal ctx : STD_LOGIC_VECTOR((ABCD_BITS/2)-2 downto 0);    
  signal cty : STD_LOGIC_VECTOR((ABCD_BITS/2)-2 downto 0);    

  signal off : unsigned(7 downto 0);
  signal off2 : unsigned(7 downto 0);  
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

  shifted_x <= ox(ox'high downto ox'high-(ABCD_BITS/2)+1);
  shifted_y <= oy(oy'high downto oy'high-(ABCD_BITS/2)+1);

  shifted_x2 <= shifted_x + 2;
  shifted_y2 <= shifted_y + 2;  

  ux <= STD_LOGIC_VECTOR(shifted_x2);
  uy <= STD_LOGIC_VECTOR(shifted_y2);

  usx <= unsigned(ux);
  usy <= unsigned(uy);  

  off <= unsigned(pipe_in.cfg(ID).p(0)); --"0000" & usy;-- + usy*5;
  off2 <= unsigned(pipe_in.cfg(ID).p(1)); 

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
    --ctx := tx(tx'high-1 downto 0);
    --cty := ty(ty'high-1 downto 0);    
    --v.disx := unsigned(ctx);
    --v.disy := unsigned(cty);

    
    v.disx := off(5 downto 0);
    v.disy := off2(5 downto 0);
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

  disx <= r.disx;
  disy <= r.disy;
  proc_clk : process(clk, rst, stall, pipe_in, stage_next, r_next)
  begin
    if rising_edge(clk) and (stall = '0' or rst = '1') then
      if pipe_in.cfg(ID).enable = '1' then
        stage <= stage_next;
      else
        stage <= pipe_in.stage;
      end if;
      r <= r_next;
      gray8_2d_out <=  gray8_2d_in;
    end if;
  end process;

end impl;
