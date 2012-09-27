library ieee;
use ieee.std_logic_1164.all;

entity romdata is
  generic (ADR  : integer;
           DATA : integer);             -- for compatibility
  port (
    clk : in  std_logic;
    adr : in  std_logic_vector(ADR-1 downto 0);
    q   : out std_logic_vector(DATA-1 downto 0));
end rom;

architecture rtl of rom is
  signal adr  : std_logic_vector(ADR-1 downto 0);
  signal data : std_logic_vector(DATA-1 downto 0);
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
      when "00000" => data <= "000100000000";  -- TODO: comment
      when "00010" => data <= "000100000000";  -- TODO: comment
      when "00100" => data <= "000011000000";  -- TODO: comment
      when "00110" => data <= "000100000000";  -- TODO: comment
      when others  => data <= "000000000000";
    end case;
  end process;

end rtl;
