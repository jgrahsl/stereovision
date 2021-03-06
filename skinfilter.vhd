library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity skinfilter is
  generic (
    ID : integer range 0 to 63 := 0);
  port (
    pipe_in  : inout pipe_t;
    pipe_out : inout pipe_t;
    stall_in   : in  std_logic;
    stall_out  : out std_logic);
end skinfilter;

architecture impl of skinfilter is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;
  signal src_valid  : std_logic;
  signal issue      : std_logic;
  signal stall      : std_logic;

begin
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);

  process (pipe_in, src_valid, rst)
    variable colr : std_logic_vector(15 downto 0);
    variable colg : std_logic_vector(15 downto 0);
    variable colb : std_logic_vector(15 downto 0);

    variable Y  : signed(31 downto 0);
    variable Cb : signed(31 downto 0);
    variable Cr : signed(31 downto 0);

    constant COEFF_Y_R  : signed(23 downto 0) := to_signed(19595, 24);
    constant COEFF_Y_G  : signed(23 downto 0) := to_signed(38470, 24);
    constant COEFF_Y_B  : signed(23 downto 0) := to_signed(7471, 24);
    constant COEFF_CB_R : signed(23 downto 0) := to_signed(-11058, 24);
    constant COEFF_CB_G : signed(23 downto 0) := to_signed(21710, 24);
    constant COEFF_CB_B : signed(23 downto 0) := to_signed(32768, 24);
    constant COEFF_CR_R : signed(23 downto 0) := to_signed(32768, 24);
    constant COEFF_CR_G : signed(23 downto 0) := to_signed(27439, 24);
    constant COEFF_CR_B : signed(23 downto 0) := to_signed(5329, 24);

    constant COEFF_Y_LOW   : signed(31 downto 0) := to_signed(5000000, 32);
    constant COEFF_Y_HIGH  : signed(31 downto 0) := to_signed(12000000, 32);
    constant COEFF_CB_LOW  : signed(31 downto 0) := to_signed(-2516582, 32);
    constant COEFF_CB_HIGH : signed(31 downto 0) := to_signed(838861, 32);
    constant COEFF_CR_LOW  : signed(31 downto 0) := to_signed(838861, 32);
    constant COEFF_CR_HIGH : signed(31 downto 0) := to_signed(3355443, 32);
  begin
    stage_next <= pipe_in.stage;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------
    colr       := "00000000" & pipe_in.stage.data_888(23 downto 16);
    colg       := "00000000" & pipe_in.stage.data_888(15 downto 8);
    colb       := "00000000" & pipe_in.stage.data_888(7 downto 0);

    Y                            := resize(COEFF_Y_R * signed(colr) + COEFF_Y_G * signed(colg) + COEFF_Y_B * signed(colb), 32);
    Cb                           := resize(COEFF_CB_R * signed(colr) - COEFF_CB_G * signed(colg) + COEFF_CB_B * signed(colb), 32);
    Cr                           := resize(COEFF_CR_R * signed(colr) - COEFF_CR_G * signed(colg) - COEFF_CR_B * signed(colb), 32);
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------    
    if (Y >= COEFF_Y_LOW) and (Y <= COEFF_Y_HIGH)
      and (Cb >= COEFF_CB_LOW) and (Cb <= COEFF_CB_HIGH)
      and (Cr >= COEFF_CR_LOW) and (Cr <= COEFF_CR_HIGH) then

      stage_next.data_1 <= (others => '1');
--      stage_next.data_8   <= (others => '1');
--      stage_next.data_565 <= (others => '1');
--      stage_next.data_888 <= (others => '1');
    else
      stage_next.data_1 <= (others => '0');
--      stage_next.data_8   <= (others => '0');
--      stage_next.data_565 <= (others => '0');
--      stage_next.data_888 <= (others => '0');
    end if;
-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------    
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_SKIN;
    end if;
    if rst = '1' then
      stage_next <= NULL_STAGE;
    end if;
  end process;

  proc_clk : process(pipe_in, clk, rst, stall, stage_next)
  begin
    if rising_edge(clk) and (stall = '0' or rst = '1') then
      if (pipe_in.cfg(ID).enable = '1') then
        stage <= stage_next;
      else
        stage <= pipe_in.stage;
      end if;
    end if;
  end process;

end impl;
