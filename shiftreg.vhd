library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity shiftregister is
  
  generic (
    WIDTH : natural range 0 to 15;
    DEPTH : natural range 0 to 639);

  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    shiftin  : in  std_logic_vector(WIDTH-1 downto 0);
    shiftout : out std_logic_vector(WIDTH-1 downto 0);
    enable   : in  std_logic);

end shiftregister;

architecture rtl of shiftregister is
  signal a          : std_logic_vector(9 downto 0);
  signal i_shiftin  : std_logic_vector(15 downto 0) := (others => '0');
  signal i_shiftout : std_logic_vector(15 downto 0) := (others => '0');
begin  -- rtl

  process (clk)
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      if rst = '1' then                 -- synchronous reset (active high)
        a <= (others => '0');
      else
        if enable = '1' then
          a <= std_logic_vector(unsigned(a) + 1);
          if unsigned(a) = DEPTH-1 then
            a <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process;
  my_shiftreg : entity work.shiftreg
    generic map (
      ADDR_BITS  => 10,
      WIDTH_BITS => 1)
    port map (
      clka   => clk,                    -- [IN]
      wea(0) => enable,                 -- [IN]
      addra  => a,                      -- [IN]
      dina   => i_shiftin,              -- [IN]
      clkb   => clk,                    -- [IN]
      enb    => enable,                 -- [IN]
      addrb  => a,                      -- [IN]
      doutb  => i_shiftout);            -- [OUT]

  shiftout                    <= i_shiftout(WIDTH-1 downto 0);
  i_shiftin(WIDTH-1 downto 0) <= shiftin;
  
end rtl;

