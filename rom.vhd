library ieee;
use ieee.std_logic_1164.all;

entity rom is
  generic (GRID  : integer;
           PARAM : integer);            -- for compatibility
  port (
    clk : in  std_logic;
    x   : in  std_logic_vector(GRID-1 downto 0);
    y   : in  std_logic_vector(GRID-1 downto 0);
    q00 : out std_logic_vector(PARAM*2-1 downto 0);
    q01 : out std_logic_vector(PARAM*2-1 downto 0);
    q10 : out std_logic_vector(PARAM*2-1 downto 0);
    q11 : out std_logic_vector(PARAM*2-1 downto 0)
    );
end rom;

architecture rtl of rom is

  type q_array_t is array (0 to 3) of std_logic_vector(PARAM*2-1 downto 0);
  signal q : q_array_t;
  
begin

  roms: for i in 0 to 3 generate
  romdata_1: romdata
    generic map (
      ADR  => (GRID*2),
      DATA => PARAM*2)
    port map (
      clk => clk,
      adr => adr(i),
      q   => q(i));    
  end generate roms;

  adr(0) <= y & x;
  q00 <= q(0);
  
  adr(1) <= y & (UNSIGNED(x) + TO_UNSIGNED(1,GRID-1));
  q01 <= q(1);
  
  adr(2) <= (UNSIGNED(y) + TO_UNSIGNED(1,GRID-1)) & x;
  q10 <= q(2);
  
  adr(3) <= (UNSIGNED(y) + TO_UNSIGNED(1,GRID-1)) & (UNSIGNED(x) + TO_UNSIGNED(1,GRID-1));
  q11 <= q(3);  
  
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


  
