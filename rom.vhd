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

  signal areg : std_logic_vector(10 downto 0);
  signal data : std_logic_vector(11 downto 0);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      areg <= adr;
    end if;
  end process;

  q <= data;

  process(areg)
  begin
    case areg is
      when "0000" => data <= "000100000000";  -- TODO: comment
      when "0001" => data <= "000100000000";  -- TODO: comment
      when "0010" => data <= "000011000000";  -- TODO: comment
      when "0011" => data <= "000100000000";  -- TODO: comment

      when others => data <= "000000000000";
    end case;
  end process;

end rtl;
