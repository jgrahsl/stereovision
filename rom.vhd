library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity rom is
  generic (GRIDX_BITS : integer;
           GRIDY_BITS : integer;           
           VALUE_BITS : integer);
  port (
    clk  : in  std_logic;
    x    : in  std_logic_vector(GRIDX_BITS-1 downto 0);
    y    : in  std_logic_vector(GRIDY_BITS-1 downto 0);
    abcd : out abcd_t
    );
end rom;

architecture rtl of rom is

  type   q_array_t is array (0 to 3) of std_logic_vector(VALUE_BITS*2-1 downto 0);
  type   a_array_t is array (0 to 3) of std_logic_vector((GRIDX_BITS+GRIDY_BITS-1) downto 0);
  signal q : q_array_t;
  signal a : a_array_t;

begin

  roms : for i in 0 to 3 generate
    romdata_1 : entity work.romdata
      generic map (
        ADR_BITS  => GRIDX+GRIDY,
        DATA_BITS => VALUE_BITS*2)
      port map (
        clk => clk,
        a   => a(i),
        q   => q(i));    
  end generate roms;

  a(0)    <= y & x;
  abcd.ax <= q(0)(VALUE_BITS*2-1 downto VALUE_BITS);
  abcd.ay <= q(0)(VALUE_BITS-1 downto 0);

  a(1) <= y & (std_logic_vector(unsigned(x) + 1));
  abcd.bx <= q(1)(VALUE_BITS*2-1 downto VALUE_BITS);
  abcd.by <= q(1)(VALUE_BITS-1 downto 0);

  a(2) <= std_logic_vector(unsigned(y) + 1) & x;
  abcd.cx <= q(2)(VALUE_BITS*2-1 downto VALUE_BITS);
  abcd.cy <= q(2)(VALUE_BITS-1 downto 0);

  a(3) <= std_logic_vector(unsigned(y) + 1) & std_logic_vector(unsigned(x) + 1);
  abcd.dx <= q(3)(VALUE_BITS*2-1 downto VALUE_BITS);
  abcd.dy <= q(3)(VALUE_BITS-1 downto 0);

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



