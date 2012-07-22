----------------------------------------------------------------------------------
-- Company: Digilent Ro
-- Engineer: Elod Gyorgy
-- 
-- Create Date:    12:50:18 04/06/2011 
-- Design Name:      VmodCAM Reference Design 1
-- Module Name:      VmodCAM_Ref - Behavioral
-- Project Name:     
-- Target Devices: 
-- Tool versions: 
-- Description: The design shows off the video feed from two cameras located on
-- a VmodCAM add-on board connected to an Atlys. The video feeds are displayed on
-- a DVI-capable flat panel.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;


library digilent;
use digilent.Video.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.cam_pkg.all;


entity top is
  generic (
    C3_NUM_DQ_PINS        : integer := 16;
    C3_MEM_ADDR_WIDTH     : integer := 13;
    C3_MEM_BANKADDR_WIDTH : integer := 3;
    FPGALINK              : integer := 1

    );
  port (
    TMDS_TX_2_P   : out   std_logic;
    TMDS_TX_2_N   : out   std_logic;
    TMDS_TX_1_P   : out   std_logic;
    TMDS_TX_1_N   : out   std_logic;
    TMDS_TX_0_P   : out   std_logic;
    TMDS_TX_0_N   : out   std_logic;
    TMDS_TX_CLK_P : out   std_logic;
    TMDS_TX_CLK_N : out   std_logic;
    TMDS_TX_SCL   : inout std_logic;
    TMDS_TX_SDA   : inout std_logic;
    SW_I          : in    std_logic_vector(7 downto 0);
    LED_O         : out   std_logic_vector(7 downto 0);
    CLK_I         : in    std_logic;
    RESET_I       : in    std_logic;

    CAMX_VDDEN_O : out std_logic;  -- common power supply enable (can do power cycle)

    CAMB_SDA    : inout std_logic;
    CAMB_SCL    : inout std_logic;
    CAMB_D_I    : in    std_logic_vector (7 downto 0);
    CAMB_PCLK_I : inout std_logic;
    CAMB_MCLK_O : out   std_logic;
    CAMB_LV_I   : in    std_logic;
    CAMB_FV_I   : in    std_logic;
    CAMB_RST_O  : out   std_logic;      --Reset active LOW
    CAMB_PWDN_O : out   std_logic;      --Power-down active HIGH           

----------------------------------------------------------------------------------
-- DDR2 Interface
----------------------------------------------------------------------------------
    mcb3_dram_dq     : inout std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
    mcb3_dram_a      : out   std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
    mcb3_dram_ba     : out   std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
    mcb3_dram_ras_n  : out   std_logic;
    mcb3_dram_cas_n  : out   std_logic;
    mcb3_dram_we_n   : out   std_logic;
    mcb3_dram_odt    : out   std_logic;
    mcb3_dram_cke    : out   std_logic;
    mcb3_dram_dm     : out   std_logic;
    mcb3_dram_udqs   : inout std_logic;
    mcb3_dram_udqs_n : inout std_logic;
    mcb3_rzq         : inout std_logic;
    mcb3_zio         : inout std_logic;
    mcb3_dram_udm    : out   std_logic;
    mcb3_dram_dqs    : inout std_logic;
    mcb3_dram_dqs_n  : inout std_logic;
    mcb3_dram_ck     : out   std_logic;
    mcb3_dram_ck_n   : out   std_logic;

-------------------------------------------------------------------------------
-- FPGA Link
-------------------------------------------------------------------------------
    -- FX2 interface -----------------------------------------------------------------------------
    fx2Clk_int   : in    std_logic;      -- 48MHz clock from FX2
    fx2Addr_out : out   std_logic_vector(1 downto 0);  -- select FIFO: "10" for EP6OUT, "11" for EP8IN
    fx2Data_io  : inout std_logic_vector(7 downto 0);  -- 8-bit data to/from FX2

    -- When EP6OUT selected:
    fx2Read_out   : out std_logic;  -- asserted (active-low) when reading from FX2
    fx2OE_out     : out std_logic;  -- asserted (active-low) to tell FX2 to drive bus
    fx2GotData_in : in  std_logic;  -- asserted (active-high) when FX2 has data for us

    -- When EP8IN selected:
    fx2Write_out  : out std_logic;  -- asserted (active-low) when writing to FX2
    fx2GotRoom_in : in  std_logic;  -- asserted (active-high) when FX2 has room for more data from us
    fx2PktEnd_out : out std_logic  -- asserted (active-low) when a host read needs to be committed early

    );
end top;

architecture Behavioral of top is
  signal SysClk, PClk, PClkX2, SysRst, SerClk, SerStb : std_logic;
  signal MSel                                         : std_logic_vector(1 downto 0);

  signal VtcHs, VtcVs, VtcVde, VtcRst : std_logic;
  signal VtcHCnt, VtcVCnt             : natural;

  signal CamClk, CamClk_180, CamBPClk, CamBDV, CamBVddEn : std_logic;
  signal CamBD                                           : std_logic_vector(15 downto 0);
  signal dummy_t, int_CAMB_PCLK_I                        : std_logic;

  attribute S                : string;
  attribute S of CAMB_PCLK_I : signal is "TRUE";
  attribute S of dummy_t     : signal is "TRUE";

  signal ddr2clk_2x, ddr2clk_2x_180, mcb_drp_clk, pll_ce_0, pll_ce_90, pll_lock, async_rst : std_logic;
  signal FbRdy, FbRdEn, FbRdRst, FbRdClk                                                   : std_logic;
  signal FbRdData                                                                          : std_logic_vector(16-1 downto 0);
  signal FbWrBRst, int_FVB                                                                 : std_logic;

  signal counter : natural range 0 to 2**23-1;
  signal rd      : std_logic;
  signal wr      : std_logic;
  signal wr_data : std_logic_vector(7 downto 0);
  signal rd_data : std_logic_vector(7 downto 0);
  signal LED_O_T : std_logic_vector(7 downto 0);

-------------------------------------------------------------------------------
-- FPGA Link
-------------------------------------------------------------------------------
  signal fx2Clk_buffered : std_logic;

  signal chanAddr : std_logic_vector(6 downto 0);  -- the selected channel (0-127)
  signal h2fData  : std_logic_vector(7 downto 0);  -- data lines used when the host writes to a channel
  signal h2fValid : std_logic;  -- '1' means "on the next clock rising edge, please accept the data on h2fData"
  signal h2fReady : std_logic;  -- channel logic can drive this low to say "I'm not ready for more data yet"
  signal f2hData  : std_logic_vector(7 downto 0);  -- data lines used when the host reads from a channel
  signal f2hValid : std_logic;  -- channel logic can drive this low to say "I don't have data ready for you"
  signal f2hReady : std_logic;  -- '1' means "on the next clock rising edge, put your next byte of data on f2hData"
  signal fx2Read  : std_logic;

------------------------------------------------------------------------------------------------
-- Registers implementing the channels
-------------------------------------------------------------------------------
  signal reg0, reg0_next : std_logic_vector(7 downto 0) := x"00";
  signal reg1, reg1_next : std_logic_vector(7 downto 0) := x"00";
  signal reg2, reg2_next : std_logic_vector(7 downto 0) := x"00";
  signal reg3, reg3_next : std_logic_vector(7 downto 0) := x"00";
-------------------------------------------------------------------------------
-- User
-------------------------------------------------------------------------------

  signal cfg : cfg_set_t;
  signal adr : integer range 0 to 63;
  signal fx2Clk_in : std_logic;
begin
----------------------------------------------------------------------------------
-- System Control Unit
-- This component provides a System Clock, a Synchronous Reset and other signals
-- needed for the 40:4 serialization:
-- - Serialization clock (5x System Clock)
-- - Serialization strobe
-- - 2x Pixel Clock
----------------------------------------------------------------------------------
  Inst_SysCon : entity work.SysCon port map(
    CLK_I          => CLK_I,
    CLK_O          => open,
    RSTN_I         => reg0(0),
    RSEL_O         => open,  --resolution selector synchronized with PClk
    CAMCLK_O       => CamClk,
    CAMCLK_180_O   => CamClk_180,
    PCLK_O         => PClk,
    PCLK_X2_O      => PClkX2,
    PCLK_X10_O     => SerClk,
    SERDESSTROBE_O => SerStb,

    DDR2CLK_2X_O     => DDR2Clk_2x,
    DDR2CLK_2X_180_O => DDR2Clk_2x_180,
    MCB_DRP_CLK_O    => mcb_drp_clk,
    PLL_CE_0_O       => pll_ce_0,
    PLL_CE_90_O      => pll_ce_90,
    PLL_LOCK         => pll_lock,
    ASYNC_RST        => async_rst
    );

----------------------------------------------------------------------------------
-- Video Timing Controller
-- Generates horizontal and vertical sync and video data enable signals.
----------------------------------------------------------------------------------
  Inst_VideoTimingCtl : entity digilent.VideoTimingCtl port map (
    PCLK_I => PClk,
    RSEL_I => R640_480P,                --this project supports only VGA
    RST_I  => VtcRst,
    VDE_O  => VtcVde,
    HS_O   => VtcHs,
    VS_O   => VtcVs,
    HCNT_O => VtcHCnt,
    VCNT_O => VtcVCnt
    );
  VtcRst <= async_rst or not FbRdy;
----------------------------------------------------------------------------------
-- Frame Buffer
----------------------------------------------------------------------------------
  Inst_FBCtl : entity work.FBCtl
    generic map (
      DEBUG_EN   => 0,
      COLORDEPTH => 16
      )
    port map(
      RDY_O   => FbRdy,
      ENC     => FbRdEn,
      RSTC_I  => FbRdRst,
      DOC     => FbRdData,
      CLKC    => FbRdClk,
      RD_MODE => SW_I,
      ENCAM   => CamBDV,
      RSTCAM  => FbWrBRst,
      DCAM    => CamBD,
      CLKCAM  => CamBPClk,
      CLK24   => CAMCLK,

      ddr2clk_2x       => DDR2Clk_2x,
      ddr2clk_2x_180   => DDR2Clk_2x_180,
      pll_ce_0         => pll_ce_0,
      pll_ce_90        => pll_ce_90,
      pll_lock         => pll_lock,
      async_rst        => async_rst,
      mcb_drp_clk      => mcb_drp_clk,
      mcb3_dram_dq     => mcb3_dram_dq,
      mcb3_dram_a      => mcb3_dram_a,
      mcb3_dram_ba     => mcb3_dram_ba,
      mcb3_dram_ras_n  => mcb3_dram_ras_n,
      mcb3_dram_cas_n  => mcb3_dram_cas_n,
      mcb3_dram_we_n   => mcb3_dram_we_n,
      mcb3_dram_odt    => mcb3_dram_odt,
      mcb3_dram_cke    => mcb3_dram_cke,
      mcb3_dram_dm     => mcb3_dram_dm,
      mcb3_dram_udqs   => mcb3_dram_udqs,
      mcb3_dram_udqs_n => mcb3_dram_udqs_n,
      mcb3_rzq         => mcb3_rzq,
      mcb3_zio         => mcb3_zio,
      mcb3_dram_udm    => mcb3_dram_udm,
      mcb3_dram_dqs    => mcb3_dram_dqs,
      mcb3_dram_dqs_n  => mcb3_dram_dqs_n,
      mcb3_dram_ck     => mcb3_dram_ck,
      mcb3_dram_ck_n   => mcb3_dram_ck_n,

      cfg_unsync  => cfg,
      led_o => led_o
      );

  FbRdEn  <= VtcVde;
  FbRdRst <= async_rst;
  FbRdClk <= PClk;
  Inst_InputSync_FVB : entity digilent.InputSync port map(
    D_I   => CAMB_FV_I,
    D_O   => int_FVB,
    CLK_I => CamBPClk
    );

  FbWrBRst <= async_rst or not int_FVB;

----------------------------------------------------------------------------------
-- DVI Transmitter
----------------------------------------------------------------------------------
  Inst_DVITransmitter : entity digilent.DVITransmitter port map(
    RED_I         => FbRdData(15 downto 11) & "000",
    GREEN_I       => FbRdData(10 downto 5) & "00",
    BLUE_I        => FbRdData(4 downto 0) & "000",
    HS_I          => VtcHs,
    VS_I          => VtcVs,
    VDE_I         => VtcVde,
    PCLK_I        => PClk,
    PCLK_X2_I     => PClkX2,
    SERCLK_I      => SerClk,
    SERSTB_I      => SerStb,
    TMDS_TX_2_P   => TMDS_TX_2_P,
    TMDS_TX_2_N   => TMDS_TX_2_N,
    TMDS_TX_1_P   => TMDS_TX_1_P,
    TMDS_TX_1_N   => TMDS_TX_1_N,
    TMDS_TX_0_P   => TMDS_TX_0_P,
    TMDS_TX_0_N   => TMDS_TX_0_N,
    TMDS_TX_CLK_P => TMDS_TX_CLK_P,
    TMDS_TX_CLK_N => TMDS_TX_CLK_N
    );

----------------------------------------------------------------------------------
-- Camera B Controller
----------------------------------------------------------------------------------
  Inst_camctlB : entity work.camctl
    port map (
      D_O     => CamBD,
      PCLK_O  => CamBPClk,
      DV_O    => CamBDV,
      RST_I   => async_rst,
      CLK     => CamClk,
      CLK_180 => CamClk_180,
      SDA     => CAMB_SDA,
      SCL     => CAMB_SCL,
      D_I     => CAMB_D_I,
      PCLK_I  => int_CAMB_PCLK_I,
      MCLK_O  => CAMB_MCLK_O,
      LV_I    => CAMB_LV_I,
      FV_I    => CAMB_FV_I,
      RST_O   => CAMB_RST_O,
      PWDN_O  => CAMB_PWDN_O,
      VDDEN_O => CamBVddEn
      );
  CAMX_VDDEN_O <= CamBVddEn;

----------------------------------------------------------------------------------
-- Workaround for IN_TERM bug AR#   40818
----------------------------------------------------------------------------------
  Inst_IOBUF_CAMB_PCLK : IOBUF
    generic map (
      DRIVE      => 12,
      IOSTANDARD => "DEFAULT",
      SLEW       => "SLOW")
    port map (
      O  => int_CAMB_PCLK_I,            -- Buffer output
      IO => CAMB_PCLK_I,  -- Buffer inout port (connect directly to top-level port)
      I  => '0',                        -- Buffer input
      T  => dummy_t       -- 3-state enable input, high=input, low=output 
      ); 
  dummy_t <= '1';

  rd <= '0';

  IBUFG_inst : IBUFG generic map (IOSTANDARD => "DEFAULT")port map (O => fx2Clk_in, I => fx2Clk_int);
--  fx2Clk_in <= fx2Clk_in;
-------------------------------------------------------------------------------
-- FPGA Link
-------------------------------------------------------------------------------

  --gen: for i in 0 to 7 generate
  --  led_o(i) <= cfg(i).enable; 
  --end generate gen;
--  led_o <= (others => '0');
            
  -- Infer registers
  process(fx2Clk_in)
  begin
    if (rising_edge(fx2Clk_in)) then
      if f2hReady = '1' then
        reg1 <= std_logic_vector(unsigned(reg1) + 1);
      end if;

      if h2fvalid = '1' then
        case chanAddr is
          when "0000000" =>
            reg0 <= h2fData;
          when "0000010" =>
            reg2 <= h2fData;
          when "0000011" =>
            reg3 <= h2fData;
          when "1100000" =>
            adr <= to_integer(unsigned(h2fData));
--            led_o <= h2fData;
          when "1100001" =>
            cfg(adr).enable <= h2fData(0);
          when "1110000" =>
            cfg(adr).p(0) <= h2fData;
          when "1110001" =>
            cfg(adr).p(1) <= h2fData;
          when "1110010" =>
            cfg(adr).p(2) <= h2fData;
          when "1110011" =>
            cfg(adr).p(3) <= h2fData;
          when "1110100" =>
            cfg(adr).p(4) <= h2fData;
          when "1110101" =>
            cfg(adr).p(5) <= h2fData;
          --when "1110110" =>
          --  cfg(adr).p(6) <= h2fData;
          --when "1110111" =>
          --  cfg(adr).p(7) <= h2fData;
          when others => null;
        end case;
      end if;
    end if;
  end process;

  with chanAddr select f2hdata <=
    reg0  when "0000000",
    X"AA" when "0000001",
    reg1  when "0001111",

    std_logic_vector(to_unsigned(adr,8))      when "1100000",
    "0000000" & cfg(adr).enable when "1100001",
    cfg(adr).p(0)               when "1110000",
    cfg(adr).p(1)               when "1110001",
    cfg(adr).p(2)               when "1110010",
    cfg(adr).p(3)               when "1110011",
    cfg(adr).p(4)               when "1110100",
    cfg(adr).p(5)               when "1110101",
    --cfg(adr).p(6)               when "1110110",
    --cfg(adr).p(7)               when "1110111",
    X"FF"                       when others;

  comm : if FPGALINK = 1 generate
    h2fReady <= '1';
    f2hValid <= '1';

    fx2Read_out    <= fx2Read;
    fx2OE_out      <= fx2Read;
    fx2Addr_out(1) <= '1';              -- Use EP6OUT/EP8IN, not EP2OUT/EP4IN.

    comm_fpga_fx2 : entity work.comm_fpga_fx2
      port map(
        -- FX2 interface
        fx2Clk_in      => fx2Clk_in,
        fx2FifoSel_out => fx2Addr_out(0),
        fx2Data_io     => fx2Data_io,
        fx2Read_out    => fx2Read,
        fx2GotData_in  => fx2GotData_in,
        fx2Write_out   => fx2Write_out,
        fx2GotRoom_in  => fx2GotRoom_in,
        fx2PktEnd_out  => fx2PktEnd_out,

        -- Channel read/write interface
        chanAddr_out => chanAddr,
        h2fData_out  => h2fData,
        h2fValid_out => h2fValid,
        h2fReady_in  => h2fReady,
        f2hData_in   => f2hData,
        f2hValid_in  => f2hValid,
        f2hReady_out => f2hReady
        );

  end generate comm;
  comm_else : if FPGALINK = 0 generate
    h2fReady <= '1';
    f2hValid <= '1';

    fx2Read_out   <= '0';
    fx2OE_out     <= '0';
    fx2Addr_out   <= (others => '0');
    fx2PktEnd_out <= '0';
    fx2Write_out  <= '0';
  end generate comm_else;

--  led_o <= h2fValid &  f2hReady & "000000";
--  led_o <= (others => '0');
end Behavioral;

