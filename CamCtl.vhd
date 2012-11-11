library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.math_real.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

library digilent;
use digilent.TWIUtils.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity CamCtl is
  port (
----------------------------------------------------------------------------------
-- Camera Controller signals
----------------------------------------------------------------------------------         
    D_O     : out std_logic_vector (15 downto 0);
    PCLK_O  : out std_logic;
    DV_O    : out std_logic;
    RST_I   : in  std_logic;
    CLK     : in  std_logic;            --24 MHz
    CLK_180 : in  std_logic;
----------------------------------------------------------------------------------
-- Camera signals
----------------------------------------------------------------------------------          
    D_I     : in  std_logic_vector (7 downto 0);
    PCLK_I  : in  std_logic;
    MCLK_O  : out std_logic;
    LV_I    : in  std_logic;
    RST_O   : out std_logic;            --Reset active LOW
    PWDN_O  : out std_logic;            --Power-down active HIGH
    VDDEN_O : out std_logic;             --Power supply enable
    I2C_EN : out std_logic
    );
end CamCtl;

architecture Behavioral of CamCtl is
  attribute syn_black_box : boolean;
  attribute fsm_encoding  : string;


  attribute BUFFER_TYPE           : string;
  attribute BUFFER_TYPE of PCLK_I : signal is "BUFG";

  constant CLOCKFREQ : natural := 24;   --MHz

  constant TWI_MT9D112                 : std_logic_vector(7 downto 1) := "0111100";
  constant RST_T1_CYCLES               : natural                      := 30;  -- see MT9D112 datasheet
  constant RST_T4_CYCLES               : natural                      := 7000;  -- see MT9D112 datasheet
  constant IRD                         : std_logic                    := '1';  -- init read
  constant IWR                         : std_logic                    := '0';  -- init write
  constant VMODCAM_RST_RISETIME        : natural                      := 50;  --us
  constant VMODCAM_RST_RISETIME_CYCLES : natural                      :=
    natural(ceil(real(VMODCAM_RST_RISETIME*CLOCKFREQ)));
  constant VMODCAM_VDD_FALLTIME        : natural := 200;  --ms
  constant VMODCAM_VDD_FALLTIME_CYCLES : natural :=
    natural(ceil(real(VMODCAM_VDD_FALLTIME*1_000*CLOCKFREQ)));
  constant VMODCAM_VDD_RISETIME        : natural := 100;  --us
  constant VMODCAM_VDD_RISETIME_CYCLES : natural :=
    natural(ceil(real(VMODCAM_VDD_RISETIME*CLOCKFREQ)));
  
  constant CMD_DELAY        : natural := 1;  --ms
  constant CMD_DELAY_CYCLES : natural :=
    natural(ceil(real(CMD_DELAY*5000*CLOCKFREQ)));

  --modify this to reflect the number of configuration words
  constant INIT_VECTORS : natural := 43;
  constant DATA_WIDTH   : integer := 33;
  constant ADDR_WIDTH   : natural := natural(ceil(log(real(INIT_VECTORS), 2.0)));


  signal rstCnt : natural range 0 to RST_T1_CYCLES + RST_T4_CYCLES + 2*VMODCAM_RST_RISETIME_CYCLES +
    VMODCAM_VDD_FALLTIME_CYCLES + VMODCAM_VDD_RISETIME_CYCLES := 0;
  signal intRst, SRst : std_logic := '1';

  signal cam_data_sel : std_logic := '0';
  signal PClk_BUFG    : std_logic;
begin
  PWDN_O <= '0';                        --power up

  BUFG_inst : BUFG
    port map (
      O => PClk_BUFG,                   -- 1-bit Clock buffer output
      I => PCLK_I                       -- 1-bit Clock buffer input
      );
  PCLK_O <= PClk_BUFG;

----------------------------------------------------------------------------------
-- Local Reset
----------------------------------------------------------------------------------
  Inst_LocalRst : entity digilent.LocalRst port map(
    RST_I  => RST_I,
    CLK_I  => CLK,
    SRST_O => SRst
    );

----------------------------------------------------------------------------------
-- MT9D112 Reset logic
----------------------------------------------------------------------------------     
  RST_REG : process (CLK)
  begin
    if Rising_Edge(CLK) then
      if (SRst = '1') then
        RST_O  <= '0';                  -- reset MT9D112
        intRst <= '1';                  -- reset this controller
        i2c_en <= '0';
        rstCnt <= 0;
      else
        if (rstCnt = RST_T1_CYCLES + VMODCAM_RST_RISETIME_CYCLES) then
          VDDEN_O <= '0';               -- after reset, we do a power cycle too
        elsif (rstCnt = RST_T1_CYCLES + VMODCAM_RST_RISETIME_CYCLES + VMODCAM_VDD_FALLTIME_CYCLES) then
          VDDEN_O <= '1';               -- turn on power
        elsif (rstCnt = RST_T1_CYCLES + VMODCAM_RST_RISETIME_CYCLES + VMODCAM_VDD_FALLTIME_CYCLES +
               VMODCAM_VDD_RISETIME_CYCLES) then
          RST_O <= '1';                 -- we can release the MT9D112
        elsif (rstCnt = RST_T1_CYCLES + RST_T4_CYCLES + 2*VMODCAM_RST_RISETIME_CYCLES +
               VMODCAM_VDD_FALLTIME_CYCLES + VMODCAM_VDD_RISETIME_CYCLES) then
          intRst <= '0';                -- we can release this controller too
          i2c_en <= '1';          
        end if;
        
        if (rstCnt < RST_T1_CYCLES + RST_T4_CYCLES + 2*VMODCAM_RST_RISETIME_CYCLES +
            VMODCAM_VDD_FALLTIME_CYCLES + VMODCAM_VDD_RISETIME_CYCLES) then
          rstCnt <= rstCnt + 1;
        end if;
      end if;
    end if;
  end process;

  Inst_ODDR2_MCLK_FORWARD : ODDR2
    generic map(
      DDR_ALIGNMENT => "NONE",  -- Sets output alignment to "NONE", "C0", "C1" 
      INIT          => '0',  -- Sets initial state of the Q output to '0' or '1'
      SRTYPE        => "SYNC")  -- Specifies "SYNC" or "ASYNC" set/reset
    port map (
      Q  => MCLK_O,                     -- 1-bit output data
      C0 => CLK,                        -- 1-bit clock input
      C1 => CLK_180,                    -- 1-bit clock input
      CE => '1',                        -- 1-bit clock enable input
      D0 => '0',  -- 1-bit data input (associated with C0)
      D1 => '1',  -- 1-bit data input (associated with C1)
      R  => '0',  -- we don't forward clock to the camera until it's stable
      S  => '0'                         -- 1-bit set input
      ); 

  BYTESELMUX_PROC : process(PClk_BUFG, intRst)
  begin
    if (intRst = '1') then
      DV_O <= '0';
    elsif Rising_Edge(PClk_BUFG) then
      if (LV_I = '0') then
        cam_data_sel <= '0';
      else
        cam_data_sel <= not cam_data_sel;
      end if;

      if (cam_data_sel = '0') then
        D_O(15 downto 8) <= D_I;
        DV_O             <= '0';
      else
        D_O(7 downto 0) <= D_I;
        DV_O            <= '1';
      end if;
    end if;
  end process;


end Behavioral;

