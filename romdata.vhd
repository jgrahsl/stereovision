library ieee;
use ieee.std_logic_1164.all;

entity romdata is
  generic (ADR_BITS  : integer := 4;
           DATA_BITS : integer);             -- for compatibility
  port (
    clk : in  std_logic;
    a   : in  std_logic_vector(ADR_BITS-1 downto 0);
    q   : out std_logic_vector(DATA_BITS-1 downto 0));
end romdata;

architecture rtl of romdata is
  signal areg : std_logic_vector(3 downto 0);  -- GRIDX+GRIDY-1
begin

  process(clk)
  begin
    if rising_edge(clk) then
      areg <= a(areg'high downto areg'low);
    end if;
  end process;

  process(areg)
  begin
    case areg is
      -- GRIDX+GRIDY -- VALUE_BITS*2
      when "0000" => q <= "0001000000";  -- TODO: comment
      when "0010" => q <= "0001000000";  -- TODO: comment
      when "0100" => q <= "0000110000";  -- TODO: comment
      when "0110" => q <= "0001000000";  -- TODO: comment
      when others => q <= "0000000000";
    end case;
  end process;

end rtl;
