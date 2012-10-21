library ieee;
use ieee.std_logic_1164.all;

entity romdata is
  generic (ADR_BITS  : integer;
           DATA_BITS : integer);             -- for compatibility
  port (
    clk : in  std_logic;
    a   : in  std_logic_vector(ADR_BITS-1 downto 0);
    q   : out std_logic_vector(DATA_BITS-1 downto 0));
end romdata;

architecture rtl of romdata is
  signal areg : std_logic_vector((GRIDX_BITS+GRIDY_BITS-1 downto 0);  -- GRIDX+GRIDY-1
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
      -- GRIDY+GRIDX --    REFY+REFX
      when "0000" => q <= "0011100111";  -- TODO: comment
      when "0001" => q <= "0011100111";  -- TODO: comment                     
      when "0010" => q <= "0011100111";  -- TODO: comment
      when "0011" => q <= "0011100111";  -- TODO: comment                     

      when "0100" => q <= "0011100111";  -- TODO: comment
      when "0101" => q <= "0111001110";  -- TODO: comment                     
      when "0110" => q <= "0111000000";  -- TODO: comment
      when "0111" => q <= "0011100111";  -- TODO: comment                     

      when "1000" => q <= "0111000111";  -- TODO: comment
      when "1001" => q <= "0000001110";  -- TODO: comment                     
      when "1010" => q <= "0000000000";  -- TODO: comment
      when "1011" => q <= "0111000111";  -- TODO: comment                     

      when "1100" => q <= "0011100111";  -- TODO: comment
      when "1101" => q <= "0011100111";  -- TODO: comment                     
      when "1110" => q <= "0011100111";  -- TODO: comment
      when "1111" => q <= "0011100111";  -- TODO: comment                     
                     
                     
      when others => q <= "0000000000";
    end case;
  end process;

end rtl;
