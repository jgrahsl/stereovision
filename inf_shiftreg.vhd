LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

ENTITY shiftreg IS
  generic (
    ADDR_BITS  : natural range 1 to 10;
    WIDTH_BITS : natural range 1 to 16);
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(ADDR_BITS-1 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(WIDTH_BITS-1 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(ADDR_BITS-1 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(WIDTH_BITS-1 DOWNTO 0)
  );
END shiftreg;



architecture myarch of shiftreg is
type RAM_TYPE is array (2**ADDR_BITS-1 downto 0) of std_logic_vector (WIDTH_BITS-1 downto 0);
signal RAM	: RAM_TYPE;

begin  -- myarch



	process (clka, wea,dina,addra,enb, addrb)
	begin
		if (clka'event and clka = '1') then
                  if enb = '1' then
					doutb <= RAM(to_integer(unsigned(addrb)));
				end if;

                  if (wea(0) = '1') then
					RAM(to_integer(unsigned(addra))) <= dina;
				end if;
		end if;
	end process;
end myarch;
