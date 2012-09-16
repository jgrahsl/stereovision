library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.numeric_std.all;

entity bit_ram is
generic
(
	ADDR_BITS : integer := 8;
	WIDTH_BITS : integer := 8
);
  port (
    clka  : IN  STD_LOGIC;
    wea   : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN  STD_LOGIC_VECTOR(ADDR_BITS-1 DOWNTO 0);
    dina  : IN  STD_LOGIC_VECTOR(WIDTH_BITS-1 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(WIDTH_BITS-1 DOWNTO 0));

end bit_ram;


architecture myarch of bit_ram is
type RAM_TYPE is array (2**ADDR_BITS-1 downto 0) of std_logic_vector (WIDTH_BITS-1 downto 0);
signal RAM	: RAM_TYPE;

begin  -- myarch



	process (clka, wea,dina,addra)
	begin
		if (clka'event and clka = '1') then
				if (wea(0) = '1') then
					RAM(to_integer(unsigned(addra))) <= dina;
					douta <= dina;
				else
					douta <= RAM(to_integer(unsigned(addra)));
				end if;
		end if;
	end process;
end myarch;
