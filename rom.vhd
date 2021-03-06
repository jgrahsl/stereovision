library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.cam_pkg.all;

entity rom is
  generic (LEFT           : natural range 0 to 1 := 0;
           GRIDX_BITS : integer;
           GRIDY_BITS : integer);
  port (
    clk  : in  std_logic;
    x    : in  std_logic_vector(GRIDX_BITS-1 downto 0);
    y    : in  std_logic_vector(GRIDY_BITS-1 downto 0);
    abcd : out abcd_t
    );
end rom;

architecture rtl of rom is

  type   q_array_t is array (0 to 3) of std_logic_vector((ABCD_BITS)-1 downto 0);
  type   a_array_t is array (0 to 3) of std_logic_vector((GRIDX_BITS+GRIDY_BITS-1) downto 0);
  signal q : q_array_t;
  signal a : a_array_t;

begin
  if_left : if LEFT = 1 generate
    roms : for i in 0 to 3 generate
      romdata_1 : entity work.romdata_l
        generic map (
          ADR_BITS  => GRIDX_BITS+GRIDY_BITS,
          DATA_BITS => ABCD_BITS)
        port map (
          clk => clk,
          a   => a(i),
          q   => q(i));    
    end generate roms;
  end generate if_left;

  if_right : if LEFT = 0 generate
    roms : for i in 0 to 3 generate
      romdata_1 : entity work.romdata_r
        generic map (
          ADR_BITS  => GRIDX_BITS+GRIDY_BITS,
          DATA_BITS => ABCD_BITS)
        port map (
          clk => clk,
          a   => a(i),
          q   => q(i));    
    end generate roms;
  end generate if_right;

  a(0)    <= y & x;
  abcd.ay <= signed(q(0)(ABCD_BITS-1 downto (ABCD_BITS/2)));
  abcd.ax <= signed(q(0)((ABCD_BITS/2)-1 downto 0));

  a(1)    <= y & (std_logic_vector(unsigned(x) + 1));
  abcd.by <= signed(q(1)(ABCD_BITS-1 downto (ABCD_BITS/2)));
  abcd.bx <= signed(q(1)((ABCD_BITS/2)-1 downto 0));

  a(2)    <= std_logic_vector(unsigned(y) + 1) & x;
  abcd.cy <= signed(q(2)(ABCD_BITS-1 downto (ABCD_BITS/2)));
  abcd.cx <= signed(q(2)((ABCD_BITS/2)-1 downto 0));

  a(3)    <= std_logic_vector(unsigned(y) + 1) & std_logic_vector(unsigned(x) + 1);
  abcd.dy <= signed(q(3)(ABCD_BITS-1 downto (ABCD_BITS/2)));
  abcd.dx <= signed(q(3)((ABCD_BITS/2)-1 downto 0));

end rtl;


--00

--00 00
--00 01
--00 10
--00 11

--01

--01 00
--01 01
--01 10
--01 11

--10

--10 00
--10 01
--10 10
--10 11

--11

--11 00
--11 01
--11 10
--11 11

--100



