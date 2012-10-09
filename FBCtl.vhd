-- Company: Digilent Ro
-- Engineer: Elod Gyorgy
-- 
-- Create Date:    18:36:17 01/20/2011 
-- Design Name: 
-- Module Name:    FBCtl - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: FBCtl is a frame buffer controller using a DDR2 memory for
-- physical storage. The controller allocates two separate frame buffers each one
-- with a stream write FIFO interface for video sources and one stream read
-- only port for a video consumer. MSEL_I configures the read port to stream data
-- from either or both frame buffers.
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
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

library digilent;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.cam_pkg.all;

entity FBCtl is
  generic (
    DEBUG_EN              : integer := 0;
    COLORDEPTH            : integer := 16;
----------------------------------------------------------------------------------
-- Copied from <mig_component_name.vhd>/generic
----------------------------------------------------------------------------------
    C3_P0_MASK_SIZE       : integer := 4;
    C3_P0_DATA_PORT_SIZE  : integer := 32;
    C3_P1_MASK_SIZE       : integer := 4;
    C3_P1_DATA_PORT_SIZE  : integer := 32;
    C3_MEMCLK_PERIOD      : integer := 3000;
    C3_RST_ACT_LOW        : integer := 0;
    C3_INPUT_CLK_TYPE     : string  := "SINGLE_ENDED";
    C3_CALIB_SOFT_IP      : string  := "TRUE";
    C3_SIMULATION         : string  := "FALSE";
    C3_MEM_ADDR_ORDER     : string  := "ROW_BANK_COLUMN";
    C3_NUM_DQ_PINS        : integer := 16;
    C3_MEM_ADDR_WIDTH     : integer := 13;
    C3_MEM_BANKADDR_WIDTH : integer := 3
    );
  port (
------------------------------------------------------------------------------------
-- Frame Buffer
------------------------------------------------------------------------------------
    RDY_O            : out   std_logic;
------------------------------------------------------------------------------------
-- Title : Port C - read only
-- Description: Supports straightforward read functionality for whole frames on a
-- constant basis. Connect to Display Controller
------------------------------------------------------------------------------------
    ENC              : in    std_logic;  --port enable
    RSTC_I           : in    std_logic;  --asynchronous port reset
    DOC              : out   std_logic_vector (COLORDEPTH - 1 downto 0);  --data output
    CLKC             : in    std_logic;  --port clock
    RD_MODE          : in    std_logic_vector(7 downto 0);
------------------------------------------------------------------------------------
-- CAM A
------------------------------------------------------------------------------------
    encam_a          : in    std_logic;  --port enable
    rstcam_a         : in    std_logic;  --asynchronous port reset
    dcam_a           : in    std_logic_vector (colordepth - 1 downto 0);  --data output
    clkcam_a         : in    std_logic;  --port clock
------------------------------------------------------------------------------------
-- CAM B
------------------------------------------------------------------------------------
    encam_b          : in    std_logic;  --port enable
    rstcam_b         : in    std_logic;  --asynchronous port reset
    dcam_b           : in    std_logic_vector (colordepth - 1 downto 0);  --data output
    clkcam_b         : in    std_logic;  --port clock
-------------------------------------------------------------------------------    
    clk24            : in    std_logic;  --port clock
---------------------------------------------------------------------------------      
-- High-speed PLL clock interface/reset
----------------------------------------------------------------------------------  
    ddr2clk_2x       : in    std_logic;
    ddr2clk_2x_180   : in    std_logic;
    pll_ce_0         : in    std_logic;
    pll_ce_90        : in    std_logic;
    pll_lock         : in    std_logic;
    async_rst        : in    std_logic;
    mcb_drp_clk      : in    std_logic;
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
    cfg_unsync       : in    cfg_set_t;
    inspect          : out   inspect_t;
    LED_O            : out   std_logic_vector(7 downto 0);

    usb_fifo : inout pixel_fifo_t;

    stallo : out std_logic;
    d      : out d0_t
    );
end FBCtl;

architecture Behavioral of FBCtl is
----------------------------------------------------------------------------------
-- MIG-generated constants
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Copied from <mig_component_name.vhd>/constants
----------------------------------------------------------------------------------
  constant C3_ARB_NUM_TIME_SLOTS      : integer                 := 12;
  constant C3_ARB_TIME_SLOT_0         : bit_vector(11 downto 0) := o"3120";
  constant C3_ARB_TIME_SLOT_1         : bit_vector(11 downto 0) := o"3210";
  constant C3_ARB_TIME_SLOT_2         : bit_vector(11 downto 0) := o"2103";
  constant C3_ARB_TIME_SLOT_3         : bit_vector(11 downto 0) := o"1032";
  constant C3_ARB_TIME_SLOT_4         : bit_vector(11 downto 0) := o"0321";
  constant C3_ARB_TIME_SLOT_5         : bit_vector(11 downto 0) := o"3210";
  constant C3_ARB_TIME_SLOT_6         : bit_vector(11 downto 0) := o"2103";
  constant C3_ARB_TIME_SLOT_7         : bit_vector(11 downto 0) := o"1032";
  constant C3_ARB_TIME_SLOT_8         : bit_vector(11 downto 0) := o"0321";
  constant C3_ARB_TIME_SLOT_9         : bit_vector(11 downto 0) := o"3210";
  constant C3_ARB_TIME_SLOT_10        : bit_vector(11 downto 0) := o"2103";
  constant C3_ARB_TIME_SLOT_11        : bit_vector(11 downto 0) := o"1032";
  constant C3_MEM_TRAS                : integer                 := 42500;
  constant C3_MEM_TRCD                : integer                 := 12500;
  constant C3_MEM_TREFI               : integer                 := 7800000;
  constant C3_MEM_TRFC                : integer                 := 127500;
  constant C3_MEM_TRP                 : integer                 := 12500;
  constant C3_MEM_TWR                 : integer                 := 15000;
  constant C3_MEM_TRTP                : integer                 := 7500;
  constant C3_MEM_TWTR                : integer                 := 7500;
  constant C3_MEM_TYPE                : string                  := "DDR2";
  constant C3_MEM_DENSITY             : string                  := "1Gb";
  constant C3_MEM_BURST_LEN           : integer                 := 4;
  constant C3_MEM_CAS_LATENCY         : integer                 := 5;
  constant C3_MEM_NUM_COL_BITS        : integer                 := 10;
  constant C3_MEM_DDR1_2_ODS          : string                  := "FULL";
  constant C3_MEM_DDR2_RTT            : string                  := "50OHMS";
  constant C3_MEM_DDR2_DIFF_DQS_EN    : string                  := "YES";
  constant C3_MEM_DDR2_3_PA_SR        : string                  := "FULL";
  constant C3_MEM_DDR2_3_HIGH_TEMP_SR : string                  := "NORMAL";
  constant C3_MEM_DDR3_CAS_LATENCY    : integer                 := 6;
  constant C3_MEM_DDR3_ODS            : string                  := "DIV6";
  constant C3_MEM_DDR3_RTT            : string                  := "DIV2";
  constant C3_MEM_DDR3_CAS_WR_LATENCY : integer                 := 5;
  constant C3_MEM_DDR3_AUTO_SR        : string                  := "ENABLED";
  constant C3_MEM_DDR3_DYN_WRT_ODT    : string                  := "OFF";
  constant C3_MEM_MOBILE_PA_SR        : string                  := "FULL";
  constant C3_MEM_MDDR_ODS            : string                  := "FULL";
  constant C3_MC_CALIB_BYPASS         : string                  := "NO";
  constant C3_MC_CALIBRATION_MODE     : string                  := "CALIBRATION";
  constant C3_MC_CALIBRATION_DELAY    : string                  := "HALF";
  constant C3_SKIP_IN_TERM_CAL        : integer                 := 0;
  constant C3_SKIP_DYNAMIC_CAL        : integer                 := 0;
  constant C3_LDQSP_TAP_DELAY_VAL     : integer                 := 0;
  constant C3_LDQSN_TAP_DELAY_VAL     : integer                 := 0;
  constant C3_UDQSP_TAP_DELAY_VAL     : integer                 := 0;
  constant C3_UDQSN_TAP_DELAY_VAL     : integer                 := 0;
  constant C3_DQ0_TAP_DELAY_VAL       : integer                 := 0;
  constant C3_DQ1_TAP_DELAY_VAL       : integer                 := 0;
  constant C3_DQ2_TAP_DELAY_VAL       : integer                 := 0;
  constant C3_DQ3_TAP_DELAY_VAL       : integer                 := 0;
  constant C3_DQ4_TAP_DELAY_VAL       : integer                 := 0;
  constant C3_DQ5_TAP_DELAY_VAL       : integer                 := 0;
  constant C3_DQ6_TAP_DELAY_VAL       : integer                 := 0;
  constant C3_DQ7_TAP_DELAY_VAL       : integer                 := 0;
  constant C3_DQ8_TAP_DELAY_VAL       : integer                 := 0;
  constant C3_DQ9_TAP_DELAY_VAL       : integer                 := 0;
  constant C3_DQ10_TAP_DELAY_VAL      : integer                 := 0;
  constant C3_DQ11_TAP_DELAY_VAL      : integer                 := 0;
  constant C3_DQ12_TAP_DELAY_VAL      : integer                 := 0;
  constant C3_DQ13_TAP_DELAY_VAL      : integer                 := 0;
  constant C3_DQ14_TAP_DELAY_VAL      : integer                 := 0;
  constant C3_DQ15_TAP_DELAY_VAL      : integer                 := 0;


  component memc3_wrapper is
    generic (
      C_MEMCLK_PERIOD     : integer;
      C_CALIB_SOFT_IP     : string;
      C_SIMULATION        : string;
      C_P0_MASK_SIZE      : integer;
      C_P0_DATA_PORT_SIZE : integer;
      C_P1_MASK_SIZE      : integer;
      C_P1_DATA_PORT_SIZE : integer;

      C_ARB_NUM_TIME_SLOTS : integer;
      C_ARB_TIME_SLOT_0    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_1    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_2    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_3    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_4    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_5    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_6    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_7    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_8    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_9    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_10   : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_11   : bit_vector(11 downto 0);

      C_MEM_TRAS  : integer;
      C_MEM_TRCD  : integer;
      C_MEM_TREFI : integer;
      C_MEM_TRFC  : integer;
      C_MEM_TRP   : integer;
      C_MEM_TWR   : integer;
      C_MEM_TRTP  : integer;
      C_MEM_TWTR  : integer;

      C_MEM_ADDR_ORDER     : string;
      C_NUM_DQ_PINS        : integer;
      C_MEM_TYPE           : string;
      C_MEM_DENSITY        : string;
      C_MEM_BURST_LEN      : integer;
      C_MEM_CAS_LATENCY    : integer;
      C_MEM_ADDR_WIDTH     : integer;
      C_MEM_BANKADDR_WIDTH : integer;
      C_MEM_NUM_COL_BITS   : integer;

      C_MEM_DDR1_2_ODS          : string;
      C_MEM_DDR2_RTT            : string;
      C_MEM_DDR2_DIFF_DQS_EN    : string;
      C_MEM_DDR2_3_PA_SR        : string;
      C_MEM_DDR2_3_HIGH_TEMP_SR : string;

      C_MEM_DDR3_CAS_LATENCY    : integer;
      C_MEM_DDR3_ODS            : string;
      C_MEM_DDR3_RTT            : string;
      C_MEM_DDR3_CAS_WR_LATENCY : integer;
      C_MEM_DDR3_AUTO_SR        : string;
      C_MEM_DDR3_DYN_WRT_ODT    : string;
      C_MEM_MOBILE_PA_SR        : string;
      C_MEM_MDDR_ODS            : string;
      C_MC_CALIB_BYPASS         : string;
      C_MC_CALIBRATION_MODE     : string;
      C_MC_CALIBRATION_DELAY    : string;
      C_SKIP_IN_TERM_CAL        : integer;
      C_SKIP_DYNAMIC_CAL        : integer;
      C_LDQSP_TAP_DELAY_VAL     : integer;
      C_LDQSN_TAP_DELAY_VAL     : integer;
      C_UDQSP_TAP_DELAY_VAL     : integer;
      C_UDQSN_TAP_DELAY_VAL     : integer;
      C_DQ0_TAP_DELAY_VAL       : integer;
      C_DQ1_TAP_DELAY_VAL       : integer;
      C_DQ2_TAP_DELAY_VAL       : integer;
      C_DQ3_TAP_DELAY_VAL       : integer;
      C_DQ4_TAP_DELAY_VAL       : integer;
      C_DQ5_TAP_DELAY_VAL       : integer;
      C_DQ6_TAP_DELAY_VAL       : integer;
      C_DQ7_TAP_DELAY_VAL       : integer;
      C_DQ8_TAP_DELAY_VAL       : integer;
      C_DQ9_TAP_DELAY_VAL       : integer;
      C_DQ10_TAP_DELAY_VAL      : integer;
      C_DQ11_TAP_DELAY_VAL      : integer;
      C_DQ12_TAP_DELAY_VAL      : integer;
      C_DQ13_TAP_DELAY_VAL      : integer;
      C_DQ14_TAP_DELAY_VAL      : integer;
      C_DQ15_TAP_DELAY_VAL      : integer
      );
    port (

      -- high-speed PLL clock interface
      sysclk_2x     : in std_logic;
      sysclk_2x_180 : in std_logic;
      pll_ce_0      : in std_logic;
      pll_ce_90     : in std_logic;
      pll_lock      : in std_logic;
      async_rst     : in std_logic;

      --User Port0 Interface Signals

      p0_cmd_clk       : in  std_logic;
      p0_cmd_en        : in  std_logic;
      p0_cmd_instr     : in  std_logic_vector(2 downto 0);
      p0_cmd_bl        : in  std_logic_vector(5 downto 0);
      p0_cmd_byte_addr : in  std_logic_vector(29 downto 0);
      p0_cmd_empty     : out std_logic;
      p0_cmd_full      : out std_logic;

      -- Data Wr Port signals
      p0_wr_clk      : in  std_logic;
      p0_wr_en       : in  std_logic;
      p0_wr_mask     : in  std_logic_vector(C_P0_MASK_SIZE - 1 downto 0);
      p0_wr_data     : in  std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
      p0_wr_full     : out std_logic;
      p0_wr_empty    : out std_logic;
      p0_wr_count    : out std_logic_vector(6 downto 0);
      p0_wr_underrun : out std_logic;
      p0_wr_error    : out std_logic;

      --Data Rd Port signals
      p0_rd_clk      : in  std_logic;
      p0_rd_en       : in  std_logic;
      p0_rd_data     : out std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
      p0_rd_full     : out std_logic;
      p0_rd_empty    : out std_logic;
      p0_rd_count    : out std_logic_vector(6 downto 0);
      p0_rd_overflow : out std_logic;
      p0_rd_error    : out std_logic;

      --User Port1 Interface Signals

      p1_cmd_clk       : in  std_logic;
      p1_cmd_en        : in  std_logic;
      p1_cmd_instr     : in  std_logic_vector(2 downto 0);
      p1_cmd_bl        : in  std_logic_vector(5 downto 0);
      p1_cmd_byte_addr : in  std_logic_vector(29 downto 0);
      p1_cmd_empty     : out std_logic;
      p1_cmd_full      : out std_logic;

      -- Data Wr Port signals
      p1_wr_clk      : in  std_logic;
      p1_wr_en       : in  std_logic;
      p1_wr_mask     : in  std_logic_vector(C_P1_MASK_SIZE - 1 downto 0);
      p1_wr_data     : in  std_logic_vector(C_P1_DATA_PORT_SIZE - 1 downto 0);
      p1_wr_full     : out std_logic;
      p1_wr_empty    : out std_logic;
      p1_wr_count    : out std_logic_vector(6 downto 0);
      p1_wr_underrun : out std_logic;
      p1_wr_error    : out std_logic;

      --Data Rd Port signals
      p1_rd_clk      : in  std_logic;
      p1_rd_en       : in  std_logic;
      p1_rd_data     : out std_logic_vector(C_P1_DATA_PORT_SIZE - 1 downto 0);
      p1_rd_full     : out std_logic;
      p1_rd_empty    : out std_logic;
      p1_rd_count    : out std_logic_vector(6 downto 0);
      p1_rd_overflow : out std_logic;
      p1_rd_error    : out std_logic;

      --User Port2 Interface Signals

      p2_cmd_clk       : in  std_logic;
      p2_cmd_en        : in  std_logic;
      p2_cmd_instr     : in  std_logic_vector(2 downto 0);
      p2_cmd_bl        : in  std_logic_vector(5 downto 0);
      p2_cmd_byte_addr : in  std_logic_vector(29 downto 0);
      p2_cmd_empty     : out std_logic;
      p2_cmd_full      : out std_logic;

      --Data Wr Port signals
      p2_wr_clk      : in  std_logic;
      p2_wr_en       : in  std_logic;
      p2_wr_mask     : in  std_logic_vector(3 downto 0);
      p2_wr_data     : in  std_logic_vector(31 downto 0);
      p2_wr_full     : out std_logic;
      p2_wr_empty    : out std_logic;
      p2_wr_count    : out std_logic_vector(6 downto 0);
      p2_wr_underrun : out std_logic;
      p2_wr_error    : out std_logic;

      --User Port3 Interface Signals

      p3_cmd_clk       : in  std_logic;
      p3_cmd_en        : in  std_logic;
      p3_cmd_instr     : in  std_logic_vector(2 downto 0);
      p3_cmd_bl        : in  std_logic_vector(5 downto 0);
      p3_cmd_byte_addr : in  std_logic_vector(29 downto 0);
      p3_cmd_empty     : out std_logic;
      p3_cmd_full      : out std_logic;

      --Data Rd Port signals
      p3_rd_clk      : in  std_logic;
      p3_rd_en       : in  std_logic;
      p3_rd_data     : out std_logic_vector(31 downto 0);
      p3_rd_full     : out std_logic;
      p3_rd_empty    : out std_logic;
      p3_rd_count    : out std_logic_vector(6 downto 0);
      p3_rd_overflow : out std_logic;
      p3_rd_error    : out std_logic;

      -- memory interface signals
      mcb3_dram_ck    : out   std_logic;
      mcb3_dram_ck_n  : out   std_logic;
      mcb3_dram_a     : out   std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0);
      mcb3_dram_ba    : out   std_logic_vector(C_MEM_BANKADDR_WIDTH-1 downto 0);
      mcb3_dram_ras_n : out   std_logic;
      mcb3_dram_cas_n : out   std_logic;
      mcb3_dram_we_n  : out   std_logic;
      mcb3_dram_odt   : out   std_logic;
--      mcb3_dram_odt         : out std_logic;
      mcb3_dram_cke   : out   std_logic;
      mcb3_dram_dq    : inout std_logic_vector(C_NUM_DQ_PINS-1 downto 0);
      mcb3_dram_dqs   : inout std_logic;
      mcb3_dram_dqs_n : inout std_logic;


      mcb3_dram_udqs : inout std_logic;
      mcb3_dram_udm  : out   std_logic;

      mcb3_dram_udqs_n : inout std_logic;
      mcb3_dram_dm     : out   std_logic;

      mcb3_rzq : inout std_logic;
      mcb3_zio : inout std_logic;

      -- Calibration signals
      mcb_drp_clk       : in  std_logic;
      calib_done        : out std_logic;
      selfrefresh_enter : in  std_logic;
      selfrefresh_mode  : out std_logic
      );
  end component memc3_wrapper;


----------------------------------------------------------------------------------
-- MCB Commands
---------------------------------------------------------------------------------- 
  constant MCB_CMD_RD : std_logic_vector(2 downto 0) := "001";
  constant MCB_CMD_WR : std_logic_vector(2 downto 0) := "000";

  constant RD_BATCH            : natural := 16;
  constant WR_BATCH            : natural := 32;
  --memory address space reserved for a video memory (one for each camera)
  constant VMEM_SIZE           : natural := 2**23;
  type     stateRd_type is (stRdIdle, stRdCmd, stRdCmdWait, stRdErr);
  signal   stateRd, nstateRd   : stateRd_type;
  type     stateWr_type is (stWrIdle, stWrCmd, stWrCmdWait, stWrErr);
  signal   stateWrA, nstateWrA : stateWr_type;
  signal   stateWrB, nstateWrB : stateWr_type;
----------------------------------------------------------------------------------
-- Internal signals
----------------------------------------------------------------------------------  
  signal   calib_done          : std_logic;
  signal   p3_cmd_clk          : std_logic;
  signal   p3_cmd_en           : std_logic;
  signal   p3_cmd_instr        : std_logic_vector(2 downto 0);
  signal   p3_cmd_bl           : std_logic_vector(5 downto 0);
  signal   p3_cmd_byte_addr    : std_logic_vector(29 downto 0);
  signal   p3_cmd_empty        : std_logic;
  signal   p3_cmd_full         : std_logic;
  signal   p3_rd_clk           : std_logic;
  signal   p3_rd_en            : std_logic;
  signal   p3_rd_data          : std_logic_vector(31 downto 0);
  signal   p3_rd_full          : std_logic;
  signal   p3_rd_empty         : std_logic;
  signal   p3_rd_count         : std_logic_vector(6 downto 0);
  signal   p3_rd_overflow      : std_logic;
  signal   p3_rd_error         : std_logic;


  signal p2_cmd_clk       : std_logic;
  signal p2_cmd_en        : std_logic;
  signal p2_cmd_instr     : std_logic_vector(2 downto 0);
  signal p2_cmd_bl        : std_logic_vector(5 downto 0);
  signal p2_cmd_byte_addr : std_logic_vector(29 downto 0);
  signal p2_cmd_empty     : std_logic;
  signal p2_cmd_full      : std_logic;
  signal p2_wr_clk        : std_logic;
  signal p2_wr_en         : std_logic;
  signal p2_wr_data       : std_logic_vector(31 downto 0);
  signal p2_wr_mask       : std_logic_vector(3 downto 0);
  signal p2_wr_full       : std_logic;
  signal p2_wr_empty      : std_logic;
  signal p2_wr_count      : std_logic_vector(6 downto 0);
  signal p2_wr_underrun   : std_logic;
  signal p2_wr_error      : std_logic;


  signal p0_cmd_clk       : std_logic;
  signal p0_cmd_en        : std_logic;
  signal p0_cmd_instr     : std_logic_vector(2 downto 0);
  signal p0_cmd_bl        : std_logic_vector(5 downto 0);
  signal p0_cmd_byte_addr : std_logic_vector(29 downto 0);
  signal p0_cmd_empty     : std_logic;
  signal p0_cmd_full      : std_logic;

  -- Data Wr Port signals
  signal p0_wr_clk      : std_logic;
  signal p0_wr_en       : std_logic;
  signal p0_wr_mask     : std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
  signal p0_wr_data     : std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
  signal p0_wr_full     : std_logic;
  signal p0_wr_empty    : std_logic;
  signal p0_wr_count    : std_logic_vector(6 downto 0);
  signal p0_wr_underrun : std_logic;
  signal p0_wr_error    : std_logic;

  --Data Rd Port signals
  signal p0_rd_clk      : std_logic;
  signal p0_rd_en       : std_logic;
  signal p0_rd_data     : std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
  signal p0_rd_full     : std_logic;
  signal p0_rd_empty    : std_logic;
  signal p0_rd_count    : std_logic_vector(6 downto 0);
  signal p0_rd_overflow : std_logic;
  signal p0_rd_error    : std_logic;

  signal p1_cmd_clk       : std_logic;
  signal p1_cmd_en        : std_logic;
  signal p1_cmd_instr     : std_logic_vector(2 downto 0);
  signal p1_cmd_bl        : std_logic_vector(5 downto 0);
  signal p1_cmd_byte_addr : std_logic_vector(29 downto 0);
  signal p1_cmd_empty     : std_logic;
  signal p1_cmd_full      : std_logic;
  signal p1_rd_clk        : std_logic;
  signal p1_rd_en         : std_logic;
  signal p1_rd_data       : std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
  signal p1_rd_full       : std_logic;
  signal p1_rd_empty      : std_logic;
  signal p1_rd_count      : std_logic_vector(6 downto 0);
  signal p1_rd_overflow   : std_logic;
  signal p1_rd_error      : std_logic;
  signal p1_wr_clk        : std_logic;
  signal p1_wr_en         : std_logic;
  signal p1_wr_data       : std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
  signal p1_wr_mask       : std_logic_vector(C3_P1_MASK_SIZE - 1 downto 0);
  signal p1_wr_full       : std_logic;
  signal p1_wr_empty      : std_logic;
  signal p1_wr_count      : std_logic_vector(6 downto 0);
  signal p1_wr_underrun   : std_logic;
  signal p1_wr_error      : std_logic;

  -- CAMA
  signal pa_wr_cnt                  : natural range 0 to 2**6-1      := 0;
  signal pa_wr_addr                 : natural range 0 to VMEM_SIZE-1 := 0;
  signal pa_wr_data_sel, pa_int_rst : std_logic;
  signal SRstcam_A, SCalibDoneA     : std_logic;
  signal rstcam_a_int               : std_logic;

  -- CAMB
  signal pb_wr_cnt                  : natural range 0 to 2**6-1      := 0;
  signal pb_wr_addr                 : natural range 0 to VMEM_SIZE-1 := 0;
  signal pb_wr_data_sel, pb_int_rst : std_logic;
  signal SRstcam_B, SCalibDoneB     : std_logic;
  signal rstcam_b_int               : std_logic;

  -- VGA
  signal rd_data_sel              : std_logic;
  signal RstC, SRstC              : std_logic;

  -- ALG
  signal clkalg   : std_logic;
  signal rstalg   : std_logic;
  signal cfg      : cfg_set_t;
  signal pipe     : pipe_set_t;
  signal hist_row : natural range 0 to 2047;

  signal mono_1d : mono_1d_t;
  signal mono_2d : mono_2d_t;

  signal pra_fifo  : mcb_fifo_t;
  signal prb_fifo  : mcb_fifo_t;
  signal pw_fifo   : mcb_fifo_t;
  signal auxr_fifo : mcb_fifo_t;
  signal auxw_fifo : mcb_fifo_t;

  signal pra_clk   : std_logic;
  signal pra_rst   : std_logic;
  signal pra_in    : std_logic_vector(31 downto 0);
  signal pra_out   : std_logic_vector(31 downto 0);
  signal pra_rd    : std_logic;
  signal pra_wr    : std_logic;
  signal pra_empty : std_logic;
  signal pra_full  : std_logic;
  signal pra_count : std_logic_vector(6 downto 0) := (others => '0');

  signal prb_clk   : std_logic;
  signal prb_rst   : std_logic;
  signal prb_in    : std_logic_vector(31 downto 0);
  signal prb_out   : std_logic_vector(31 downto 0);
  signal prb_rd    : std_logic;
  signal prb_wr    : std_logic;
  signal prb_empty : std_logic;
  signal prb_full  : std_logic;
  signal prb_count : std_logic_vector(6 downto 0) := (others => '0');

  signal pw_clk   : std_logic;
  signal pw_rst   : std_logic;
  signal pw_in    : std_logic_vector(31 downto 0);
  signal pw_out   : std_logic_vector(31 downto 0);
  signal pw_rd    : std_logic;
  signal pw_wr    : std_logic;
  signal pw_empty : std_logic;
  signal pw_full  : std_logic;
  signal pw_count : std_logic_vector(6 downto 0) := (others => '0');

  signal auxr_clk   : std_logic;
  signal auxr_rst   : std_logic;
  signal auxr_in    : std_logic_vector(31 downto 0);
  signal auxr_out   : std_logic_vector(31 downto 0);
  signal auxr_rd    : std_logic;
  signal auxr_wr    : std_logic;
  signal auxr_empty : std_logic;
  signal auxr_full  : std_logic;
  signal auxr_count : std_logic_vector(7 downto 0) := (others => '0');

  signal auxw_clk   : std_logic;
  signal auxw_rst   : std_logic;
  signal auxw_in    : std_logic_vector(31 downto 0);
  signal auxw_out   : std_logic_vector(31 downto 0);
  signal auxw_rd    : std_logic;
  signal auxw_wr    : std_logic;
  signal auxw_empty : std_logic;
  signal auxw_full  : std_logic;
  signal auxw_count : std_logic_vector(7 downto 0) := (others => '0');
  
  type move_state_t is (
    move_reset,
    move_wait,

    move_r_pa,
    move_r_pa_inc,
    move_r_transfer_pa,
    move_r_transfer_pa_1,

    move_r_pb,
    move_r_pb_inc,
    move_r_transfer_pb,
    move_r_transfer_pb_1,

    move_r_aux,
    move_r_aux_inc,
    move_r_transfer_aux,
    move_r_transfer_aux_1,

    move_w_p,
    move_w_transfer_p,
    move_w_transfer_p_1,
    move_w_p_inc,

    move_w_aux,
    move_w_transfer_aux,
    move_w_transfer_aux_1,
    move_w_aux_inc);

  signal move_state  : move_state_t;
  signal move_nstate : move_state_t;

  signal my_pixel_a_rd_addr : natural range 0 to 2**24-1 := 0;
  signal my_pixel_b_rd_addr : natural range 0 to 2**24-1 := 0;
  signal my_aux_rd_addr     : natural range 0 to 2**24-1 := 0;

  signal my_pixel_wr_addr : natural range 0 to 2**24-1 := 0;
  signal my_aux_wr_addr   : natural range 0 to 2**24-1 := 0;

  signal reg0 : std_logic_vector(7 downto 0);
  signal reg1 : std_logic_vector(7 downto 0);
  signal reg2 : std_logic_vector(7 downto 0);
  signal reg3 : std_logic_vector(7 downto 0);

  signal stall : std_logic_vector(MAX_PIPE-1 downto 0);

  signal gray8_2d : gray8_2d_t;
  signal out_fifo : pixel_fifo_t;


  constant AUX_OFFSET  : natural := 2**24;
  constant CAMB_OFFSET : natural := 2**23;
  constant CAMA_OFFSET : natural := 2**22;
  constant DVI_OFFSET  : natural := 0;


  constant WIDTH  : natural := 320;
  constant HEIGHT : natural := 240;
  constant SIZE   : natural := WIDTH*HEIGHT*2;

  signal abcd       : abcd_t;
  signal abcd2      : abcd2_t;
  signal gray8_2d_1 : gray8_2d_t;
  signal gray8_2d_2 : gray8_2d_t;
  signal rgb565_2d  : rgb565_2d_t;
  signal mono_2d_l  : mono_2d_t;
  signal mono_2d_r  : mono_2d_t;

  signal done_b           : std_logic;
  signal camb_trigger     : std_logic;
  signal camb_trigger_old : std_logic;

  signal done_a           : std_logic;
  signal cama_trigger     : std_logic;
  signal cama_trigger_old : std_logic;

  signal sel : natural range 0 to 3;

  signal x : unsigned(9 downto 0);
  signal y : unsigned(9 downto 0);

  signal src_a : natural range 0 to 2400;
  signal src_b : natural range 0 to 2400;
  signal src_c : natural range 0 to 2400;
begin
----------------------------------------------------------------------------------
-- mcb instantiation
----------------------------------------------------------------------------------
  mcb_ddr2 : memc3_wrapper
    generic map (
      c_memclk_period           => c3_memclk_period,
      c_calib_soft_ip           => c3_calib_soft_ip,
      c_simulation              => c3_simulation,
      c_p0_mask_size            => c3_p0_mask_size,
      c_p0_data_port_size       => c3_p0_data_port_size,
      c_p1_mask_size            => c3_p1_mask_size,
      c_p1_data_port_size       => c3_p1_data_port_size,
      c_arb_num_time_slots      => c3_arb_num_time_slots,
      c_arb_time_slot_0         => c3_arb_time_slot_0,
      c_arb_time_slot_1         => c3_arb_time_slot_1,
      c_arb_time_slot_2         => c3_arb_time_slot_2,
      c_arb_time_slot_3         => c3_arb_time_slot_3,
      c_arb_time_slot_4         => c3_arb_time_slot_4,
      c_arb_time_slot_5         => c3_arb_time_slot_5,
      c_arb_time_slot_6         => c3_arb_time_slot_6,
      c_arb_time_slot_7         => c3_arb_time_slot_7,
      c_arb_time_slot_8         => c3_arb_time_slot_8,
      c_arb_time_slot_9         => c3_arb_time_slot_9,
      c_arb_time_slot_10        => c3_arb_time_slot_10,
      c_arb_time_slot_11        => c3_arb_time_slot_11,
      c_mem_tras                => c3_mem_tras,
      c_mem_trcd                => c3_mem_trcd,
      c_mem_trefi               => c3_mem_trefi,
      c_mem_trfc                => c3_mem_trfc,
      c_mem_trp                 => c3_mem_trp,
      c_mem_twr                 => c3_mem_twr,
      c_mem_trtp                => c3_mem_trtp,
      c_mem_twtr                => c3_mem_twtr,
      c_mem_addr_order          => c3_mem_addr_order,
      c_num_dq_pins             => c3_num_dq_pins,
      c_mem_type                => c3_mem_type,
      c_mem_density             => c3_mem_density,
      c_mem_burst_len           => c3_mem_burst_len,
      c_mem_cas_latency         => c3_mem_cas_latency,
      c_mem_addr_width          => c3_mem_addr_width,
      c_mem_bankaddr_width      => c3_mem_bankaddr_width,
      c_mem_num_col_bits        => c3_mem_num_col_bits,
      c_mem_ddr1_2_ods          => c3_mem_ddr1_2_ods,
      c_mem_ddr2_rtt            => c3_mem_ddr2_rtt,
      c_mem_ddr2_diff_dqs_en    => c3_mem_ddr2_diff_dqs_en,
      c_mem_ddr2_3_pa_sr        => c3_mem_ddr2_3_pa_sr,
      c_mem_ddr2_3_high_temp_sr => c3_mem_ddr2_3_high_temp_sr,
      c_mem_ddr3_cas_latency    => c3_mem_ddr3_cas_latency,
      c_mem_ddr3_ods            => c3_mem_ddr3_ods,
      c_mem_ddr3_rtt            => c3_mem_ddr3_rtt,
      c_mem_ddr3_cas_wr_latency => c3_mem_ddr3_cas_wr_latency,
      c_mem_ddr3_auto_sr        => c3_mem_ddr3_auto_sr,
      c_mem_ddr3_dyn_wrt_odt    => c3_mem_ddr3_dyn_wrt_odt,
      c_mem_mobile_pa_sr        => c3_mem_mobile_pa_sr,
      c_mem_mddr_ods            => c3_mem_mddr_ods,
      c_mc_calib_bypass         => c3_mc_calib_bypass,
      c_mc_calibration_mode     => c3_mc_calibration_mode,
      c_mc_calibration_delay    => c3_mc_calibration_delay,
      c_skip_in_term_cal        => c3_skip_in_term_cal,
      c_skip_dynamic_cal        => c3_skip_dynamic_cal,
      c_ldqsp_tap_delay_val     => c3_ldqsp_tap_delay_val,
      c_ldqsn_tap_delay_val     => c3_ldqsn_tap_delay_val,
      c_udqsp_tap_delay_val     => c3_udqsp_tap_delay_val,
      c_udqsn_tap_delay_val     => c3_udqsn_tap_delay_val,
      c_dq0_tap_delay_val       => c3_dq0_tap_delay_val,
      c_dq1_tap_delay_val       => c3_dq1_tap_delay_val,
      c_dq2_tap_delay_val       => c3_dq2_tap_delay_val,
      c_dq3_tap_delay_val       => c3_dq3_tap_delay_val,
      c_dq4_tap_delay_val       => c3_dq4_tap_delay_val,
      c_dq5_tap_delay_val       => c3_dq5_tap_delay_val,
      c_dq6_tap_delay_val       => c3_dq6_tap_delay_val,
      c_dq7_tap_delay_val       => c3_dq7_tap_delay_val,
      c_dq8_tap_delay_val       => c3_dq8_tap_delay_val,
      c_dq9_tap_delay_val       => c3_dq9_tap_delay_val,
      c_dq10_tap_delay_val      => c3_dq10_tap_delay_val,
      c_dq11_tap_delay_val      => c3_dq11_tap_delay_val,
      c_dq12_tap_delay_val      => c3_dq12_tap_delay_val,
      c_dq13_tap_delay_val      => c3_dq13_tap_delay_val,
      c_dq14_tap_delay_val      => c3_dq14_tap_delay_val,
      c_dq15_tap_delay_val      => c3_dq15_tap_delay_val
      )
    port map
    (
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

      calib_done    => calib_done,
      async_rst     => async_rst,
      sysclk_2x     => ddr2clk_2x,
      sysclk_2x_180 => ddr2clk_2x_180,
      pll_ce_0      => pll_ce_0,
      pll_ce_90     => pll_ce_90,
      pll_lock      => pll_lock,
      mcb_drp_clk   => mcb_drp_clk,

      p0_cmd_clk       => p0_cmd_clk,
      p0_cmd_en        => p0_cmd_en,
      p0_cmd_instr     => p0_cmd_instr,
      p0_cmd_bl        => p0_cmd_bl,
      p0_cmd_byte_addr => p0_cmd_byte_addr,
      p0_cmd_empty     => p0_cmd_empty,
      p0_cmd_full      => p0_cmd_full,
      p0_wr_clk        => p0_wr_clk,
      p0_wr_en         => p0_wr_en,
      p0_wr_mask       => p0_wr_mask,
      p0_wr_data       => p0_wr_data,
      p0_wr_full       => p0_wr_full,
      p0_wr_empty      => p0_wr_empty,
      p0_wr_count      => p0_wr_count,
      p0_wr_underrun   => p0_wr_underrun,
      p0_wr_error      => p0_wr_error,
      p0_rd_clk        => p0_rd_clk,
      p0_rd_en         => p0_rd_en,
      p0_rd_data       => p0_rd_data,
      p0_rd_full       => p0_rd_full,
      p0_rd_empty      => p0_rd_empty,
      p0_rd_count      => p0_rd_count,
      p0_rd_overflow   => p0_rd_overflow,
      p0_rd_error      => p0_rd_error,


      p1_cmd_clk       => p1_cmd_clk,
      p1_cmd_en        => p1_cmd_en,
      p1_cmd_instr     => p1_cmd_instr,
      p1_cmd_bl        => p1_cmd_bl,
      p1_cmd_byte_addr => p1_cmd_byte_addr,
      p1_cmd_empty     => p1_cmd_empty,
      p1_cmd_full      => p1_cmd_full,
      p1_wr_clk        => p1_wr_clk,
      p1_wr_en         => p1_wr_en,
      p1_wr_mask       => p1_wr_mask,
      p1_wr_data       => p1_wr_data,
      p1_wr_full       => p1_wr_full,
      p1_wr_empty      => p1_wr_empty,
      p1_wr_count      => p1_wr_count,
      p1_wr_underrun   => p1_wr_underrun,
      p1_wr_error      => p1_wr_error,
      p1_rd_clk        => p1_rd_clk,
      p1_rd_en         => p1_rd_en,
      p1_rd_data       => p1_rd_data,
      p1_rd_full       => p1_rd_full,
      p1_rd_empty      => p1_rd_empty,
      p1_rd_count      => p1_rd_count,
      p1_rd_overflow   => p1_rd_overflow,
      p1_rd_error      => p1_rd_error,

      p2_cmd_clk       => p2_cmd_clk,
      p2_cmd_en        => p2_cmd_en,
      p2_cmd_instr     => p2_cmd_instr,
      p2_cmd_bl        => p2_cmd_bl,
      p2_cmd_byte_addr => p2_cmd_byte_addr,
      p2_cmd_empty     => p2_cmd_empty,
      p2_cmd_full      => p2_cmd_full,
      p2_wr_clk        => p2_wr_clk,
      p2_wr_en         => p2_wr_en,
      p2_wr_mask       => p2_wr_mask,
      p2_wr_data       => p2_wr_data,
      p2_wr_full       => p2_wr_full,
      p2_wr_empty      => p2_wr_empty,
      p2_wr_count      => p2_wr_count,
      p2_wr_underrun   => p2_wr_underrun,
      p2_wr_error      => p2_wr_error,

      p3_cmd_clk       => p3_cmd_clk,
      p3_cmd_en        => p3_cmd_en,
      p3_cmd_instr     => p3_cmd_instr,
      p3_cmd_bl        => p3_cmd_bl,
      p3_cmd_byte_addr => p3_cmd_byte_addr,
      p3_cmd_empty     => p3_cmd_empty,
      p3_cmd_full      => p3_cmd_full,
      p3_rd_clk        => p3_rd_clk,
      p3_rd_en         => p3_rd_en,
      p3_rd_data       => p3_rd_data,
      p3_rd_full       => p3_rd_full,
      p3_rd_empty      => p3_rd_empty,
      p3_rd_count      => p3_rd_count,
      p3_rd_overflow   => p3_rd_overflow,
      p3_rd_error      => p3_rd_error,

      selfrefresh_enter => '0',         --selfrefresh_enter,
      selfrefresh_mode  => open         --selfrefresh_mode
      );

-----------------------------------------------------------------------------
-- DVI
-----------------------------------------------------------------------------
  inst_localrstc : entity digilent.localrst port map(
    rst_i  => rstc,
    clk_i  => clkc,
    srst_o => srstc
    );
  rstc <= rstc_i or not calib_done;
  sync_proc : process (clkc)
  begin
    if rising_edge(clkc) then
      if (srstc = '1') then
        staterd     <= strdidle;
        rd_data_sel <= '0';
        x     <= (others => '0');
        y     <= (others => '0');
        src_a <= 0;
        src_b <= 0;
        src_c <= 0;

        rdy_o       <= '0';
      else
        
        staterd <= nstaterd;

        if (enc = '1') then
          rd_data_sel <= not rd_data_sel;
        end if;
        if (staterd = strdcmd) then
          if x < 20-1 then
            x <= x + 1;
          else
            x <= (others => '0');
            if y < 480-1 then
              y <= y + 1;
            else
              y <= (others => '0');

              x     <= (others => '0');
              y     <= (others => '0');
              src_a <= 0;
              src_b <= 0;
              src_c <= 0;
              
            end if;
          end if;

          if x < 10 and y < 240 then
            src_a <= src_a + 1;
          end if;

          if x >= 10 and x < 20 and y < 240 then
            src_b <= src_b + 1;
          end if;

          if x < 10 and y >= 240 and y < 480 then
            src_c <= src_c + 1;
          end if;

        end if;
        if (p3_rd_empty = '0') then
          rdy_o <= '1';
        end if;
        
      end if;
      
    end if;
  end process;
  doc <= p3_rd_data(31 downto 16) when rd_data_sel = '1' else
         p3_rd_data(15 downto 0);

  sel <= 0 when x < 10 and y < 240 else
         1 when x >= 10 and x < 20 and y < 240  else
         2 when x < 10 and y >= 240 and y < 480 else 3;
  
  p3_cmd_byte_addr <= std_logic_vector(to_unsigned(src_a*(rd_batch*4)+(CAMA_OFFSET), 30)) when sel = 0 else
                      std_logic_vector(to_unsigned(src_b*(rd_batch*4)+(CAMB_OFFSET), 30)) when sel = 1 else
                      std_logic_vector(to_unsigned(src_c*(rd_batch*4)+(DVI_OFFSET), 30))  when sel = 2 else (others => '0');

  
  next_state_decode : process (staterd, p3_rd_count, p3_rd_error)
  begin
    nstaterd <= staterd;                --default is to stay in current state

    p3_cmd_instr <= mcb_cmd_rd;         -- port 3 read-only
    p3_cmd_bl    <= std_logic_vector(to_unsigned(rd_batch-1, 6));  -- we read 32 dwords (32-bit) at a time
    p3_cmd_clk   <= clkc;

    p3_cmd_en <= '0';

    p3_rd_en  <= rd_data_sel and enc;
    p3_rd_clk <= clkc;

    d.dvistate <= (others => '0');
    case (staterd) is
      when strdidle =>
        d.dvistate(0) <= '1';
        if (p3_rd_count < 16) then
          nstaterd <= strdcmd;
        end if;
      when strdcmd =>
        d.dvistate(1) <= '1';
        p3_cmd_en     <= '1';
        nstaterd      <= strdcmdwait;
      when strdcmdwait =>
        d.dvistate(2) <= '1';
        if (p3_rd_error = '1') then
          nstaterd <= strderr;             --the read fifo got empty
        elsif not (p3_rd_count < 16) then  -- data is present in the fifo
          nstaterd <= strdidle;
        end if;
      when strderr =>
        d.dvistate(3) <= '1';
        null;
    end case;
  end process;

  d.p3 <= p3_rd_empty & p3_rd_full & p3_rd_overflow & p3_rd_error & "0000";

-----------------------------------------------------------------------------
-- CAMERA A
-----------------------------------------------------------------------------
  inst_localrstb1_a : entity digilent.localrst port map(
    rst_i  => rstcam_a_int,
    clk_i  => clkcam_a,
    srst_o => srstcam_a
    );
  rstcam_a_int <= rstcam_a or not calib_done;
  
  inst_localrstb2_a : entity digilent.localrst port map(
    rst_i  => calib_done,
    clk_i  => clkcam_a,
    srst_o => scalibdonea
    );

  inst_inputsync_fva : entity digilent.inputsync port map(
    d_i   => cfg(2).p(1)(0),
    d_o   => cama_trigger,
    clk_i => clkcam_a
    );  

  portarst_proc_aa : process(clkcam_a)
  begin
    if rising_edge(clkcam_a) then
      if (srstcam_a = '1') then
        pa_int_rst <= '1';

        if cama_trigger = '1' then
          done_a <= '1';
        else
          done_a <= '0';
        end if;

        --if cama_trigger /= cama_trigger_old then
        --  done_a <= '1';
        --  cama_trigger_old <= cama_trigger;
        --end if;       
        
      elsif (p2_wr_empty = '1') then
        pa_int_rst <= '0';
      end if;

-------------------------------------------------------------------------------
-- SELECTOR
-------------------------------------------------------------------------------
      if (srstcam_a = '1') then
        pa_wr_data_sel <= '0';
      elsif (encam_a = '1') then
        pa_wr_data_sel <= not pa_wr_data_sel;
      end if;

      if (encam_a = '1') then
        if (pa_wr_data_sel = '0') then
          p2_wr_data(15 downto 0) <= dcam_a;
        end if;
      end if;
-------------------------------------------------------------------------------
-- ADR COUNT
-------------------------------------------------------------------------------      
      if (pa_int_rst = '1' and p2_wr_empty = '1') then
        pa_wr_addr <= 0;
      elsif (statewra = stwrcmd) then
        if (pa_wr_addr = SIZE/(wr_batch*4)-1) then
          pa_wr_addr <= 0;
        else
          pa_wr_addr <= pa_wr_addr + 1;
        end if;
      end if;
-------------------------------------------------------------------------------
-- STATE
-------------------------------------------------------------------------------
      if (scalibdonea = '0' or p2_wr_empty = '1') then
        statewra <= stwridle;
      else
        statewra <= nstatewra;
      end if;
-------------------------------------------------------------------------------
-- WR COUNT
-------------------------------------------------------------------------------
      if (statewra = stwrcmd) then
        if (p2_wr_en = '1' and pa_int_rst = '0') then
          pa_wr_cnt <= 1;
        else
          pa_wr_cnt <= 0;
        end if;
      elsif (p2_wr_en = '1' and pa_int_rst = '0') then
        pa_wr_cnt <= pa_wr_cnt + 1;
      end if;
      
    end if;
  end process;

  p2_wr_clk                <= clkcam_a;
  p2_wr_en                 <= pa_wr_data_sel and encam_a and done_a;
  p2_wr_data(31 downto 16) <= dcam_a;
  p2_wr_mask               <= "0000";

  p2_cmd_clk       <= clkcam_a;
  p2_cmd_instr     <= mcb_cmd_wr;       -- port 1 write-only
  p2_cmd_byte_addr <= std_logic_vector(to_unsigned(pa_wr_addr * (wr_batch*4)+CAMA_OFFSET, 30));
  p2_cmd_bl        <= std_logic_vector(to_unsigned(pa_wr_cnt-1, 6)) when pa_int_rst = '1' else
                      std_logic_vector(to_unsigned(wr_batch-1, 6));

  wrnext_state_decode_aa : process (statewra, p2_wr_count, p2_wr_error, pa_int_rst, p2_wr_empty, pa_wr_cnt)
  begin
    nstatewra <= statewra;              --default is to stay in current state
    p2_cmd_en <= '0';
    d.p2state <= (others => '0');
    case (statewra) is
      when stwridle =>
        d.p2state(0) <= '1';
        if (pa_wr_cnt >= wr_batch or pa_int_rst = '1') then
          nstatewra <= stwrcmd;
        end if;
      when stwrcmd =>
        d.p2state(1) <= '1';
        p2_cmd_en    <= '1';
        nstatewra    <= stwrcmdwait;
      when stwrcmdwait =>
        d.p2state(2) <= '1';
        if (p2_wr_error = '1') then
          nstatewra <= stwrerr;         --the write fifo got empty
        elsif ((pa_int_rst = '0' and p2_wr_count < wr_batch) or
               (pa_int_rst = '1' and p2_wr_empty = '1')) then  -- data got transferred from the fifo
          nstatewra <= stwridle;
        end if;
      when stwrerr =>
        d.p2state(3) <= '1';
        null;
    end case;
  end process;
  d.p2 <= p2_wr_empty & p2_wr_full & p2_wr_underrun & p2_wr_error & p2_wr_en & p2_cmd_en & "00";
-----------------------------------------------------------------------------
-- CAMERA B
-----------------------------------------------------------------------------
  inst_localrstb1_b : entity digilent.localrst port map(
    rst_i  => rstcam_b_int,
    clk_i  => clkcam_b,
    srst_o => srstcam_b
    );
  rstcam_b_int <= rstcam_b or not calib_done;
  
  inst_localrstb2_b : entity digilent.localrst port map(
    rst_i  => calib_done,
    clk_i  => clkcam_b,
    srst_o => scalibdoneb
    );

  inst_inputsync_fvb : entity digilent.inputsync port map(
    d_i   => cfg(2).p(1)(0),
    d_o   => camb_trigger,
    clk_i => clkcam_b
    );

  portarst_proc_b : process(clkcam_b)
  begin
    if rising_edge(clkcam_b) then
      if (srstcam_b = '1') then
        pb_int_rst <= '1';

        if camb_trigger = '1' then
          done_b <= '1';
        else
          done_b <= '0';
        end if;

        --if camb_trigger /= camb_trigger_old then
        --  done_b <= '1';
        --  camb_trigger_old <= camb_trigger;
        --end if;       
      elsif (p1_wr_empty = '1') then
        pb_int_rst <= '0';
      end if;

-------------------------------------------------------------------------------
-- SELECTOR
-------------------------------------------------------------------------------
      if (srstcam_b = '1') then
        pb_wr_data_sel <= '0';
      elsif (encam_b = '1') then
        pb_wr_data_sel <= not pb_wr_data_sel;
      end if;

      if (encam_b = '1') then
        if (pb_wr_data_sel = '0') then
          p1_wr_data(15 downto 0) <= dcam_b;
        end if;
      end if;
-------------------------------------------------------------------------------
-- ADR COUNT
-------------------------------------------------------------------------------
      if (pb_int_rst = '1' and p1_wr_empty = '1') then
        pb_wr_addr <= 0;
      elsif (statewrb = stwrcmd) then
        if (pb_wr_addr = SIZE/(wr_batch*4)-1) then
          pb_wr_addr <= 0;
--          done_b <= '0';
        else
          pb_wr_addr <= pb_wr_addr + 1;
        end if;
      end if;
-------------------------------------------------------------------------------
--  STATE
-------------------------------------------------------------------------------      
      if (scalibdoneb = '0' or p1_wr_empty = '1') then
        statewrb <= stwridle;
      else
        statewrb <= nstatewrb;
      end if;
-------------------------------------------------------------------------------
--  WR COUNT
-------------------------------------------------------------------------------
      if (statewrb = stwrcmd) then
        if (p1_wr_en = '1' and pb_int_rst = '0') then
          pb_wr_cnt <= 1;
        else
          pb_wr_cnt <= 0;
        end if;
      elsif (p1_wr_en = '1' and pb_int_rst = '0') then
        pb_wr_cnt <= pb_wr_cnt + 1;
      end if;
      
    end if;
  end process;

  p1_wr_clk                <= clkcam_b;
  p1_wr_en                 <= pb_wr_data_sel and encam_b and done_b;
  p1_wr_data(31 downto 16) <= dcam_b;
  p1_wr_mask               <= "0000";

  p1_cmd_clk       <= clkcam_b;
  p1_cmd_instr     <= mcb_cmd_wr;       -- port 1 write-only
  p1_cmd_byte_addr <= std_logic_vector(to_unsigned(pb_wr_addr * (wr_batch*4)+CAMB_OFFSET, 30));
  p1_cmd_bl        <= std_logic_vector(to_unsigned(pb_wr_cnt-1, 6)) when pb_int_rst = '1' else
                      std_logic_vector(to_unsigned(wr_batch-1, 6));

  wrnext_state_decode_b : process (statewrb, p1_wr_count, p1_wr_error, pb_int_rst, p1_wr_empty, pb_wr_cnt)
  begin
    nstatewrb <= statewrb;              --default is to stay in current state
    p1_cmd_en <= '0';
    d.p1state <= (others => '0');
    case (statewrb) is
      when stwridle =>
        d.p1state(0) <= '1';
        if (pb_wr_cnt >= wr_batch or pb_int_rst = '1') then
          nstatewrb <= stwrcmd;
        end if;
      when stwrcmd =>
        d.p1state(1) <= '1';
        p1_cmd_en    <= '1';
        nstatewrb    <= stwrcmdwait;
      when stwrcmdwait =>
        d.p1state(2) <= '1';
        if (p1_wr_error = '1') then
          nstatewrb <= stwrerr;         --the write fifo got empty
        elsif ((pb_int_rst = '0' and p1_wr_count < wr_batch) or
               (pb_int_rst = '1' and p1_wr_empty = '1')) then  -- data got transferred from the fifo
          nstatewrb <= stwridle;
        end if;
      when stwrerr =>
        d.p1state(3) <= '1';
        null;
    end case;
  end process;
  d.p1 <= p1_wr_empty & p1_wr_full & p1_wr_underrun & p1_wr_error & p1_wr_en & p1_cmd_en & "00";

-------------------------------------------------------------------------------
-- ALGO on P0 and P1
-------------------------------------------------------------------------------
  clkalg <= clk24;
  inst_localrstalg : entity digilent.localrst port map(
    rst_i  => srstc,
    clk_i  => clkalg,
    srst_o => rstalg
    );

  process (clkalg)
  begin  -- process
    if clkalg'event and clkalg = '1' then  -- rising clock edge
      if rstalg = '1' then                 -- synchronous reset (active high)
        move_state <= move_reset;

        my_pixel_a_rd_addr <= 0;
        my_pixel_b_rd_addr <= 0;
        my_pixel_wr_addr   <= 0;
        my_aux_rd_addr     <= 0;
        my_aux_wr_addr     <= 0;
      else
-------------------------------------------------------------------------------
-- Memory 
-------------------------------------------------------------------------------
        if move_state = move_r_pa_inc then
          if (my_pixel_a_rd_addr = (SIZE-16*4)) then
            my_pixel_a_rd_addr <= 0;
          else
            my_pixel_a_rd_addr <= my_pixel_a_rd_addr + 16*4;
          end if;
        end if;

        if move_state = move_r_pb_inc then
          if (my_pixel_b_rd_addr = (SIZE-16*4)) then
            my_pixel_b_rd_addr <= 0;
          else
            my_pixel_b_rd_addr <= my_pixel_b_rd_addr + 16*4;
          end if;
        end if;

        if move_state = move_r_aux_inc then
          if (my_aux_rd_addr = (SIZE-32*4)) then
            my_aux_rd_addr <= 0;
          else
            my_aux_rd_addr <= my_aux_rd_addr + 32*4;
          end if;
        end if;

        if move_state = move_w_p_inc then
          if (my_pixel_wr_addr = (SIZE-16*4)) then
            my_pixel_wr_addr <= 0;
          else
            my_pixel_wr_addr <= my_pixel_wr_addr + 16*4;
          end if;
        end if;

        if move_state = move_w_aux_inc then
          if (my_aux_wr_addr = (SIZE-32*4)) then
            my_aux_wr_addr <= 0;
          else
            my_aux_wr_addr <= my_aux_wr_addr + 32*4;
          end if;
        end if;

        move_state <= move_nstate;
      end if;
    end if;
  end process;

-------------------------------------------------------------------------------
-- MCB_FIFO TO PR/AUXR_FIFO
-------------------------------------------------------------------------------

  pr_fifo_comp_a : entity work.mcb_pixel_fifo
    port map (
      clk        => pra_clk,            -- [IN]
      rst        => pra_rst,            -- [IN]
      din        => pra_in,             -- [IN]
      wr_en      => pra_wr,             -- [IN]
      rd_en      => pra_rd,             -- [IN]
      dout       => pra_out,
      full       => pra_full,           -- [OUT]
      empty      => pra_empty,
      data_count => pra_count(6 downto 0)
      );                                -- [OUT]

  pr_fifo_comp_b : entity work.mcb_pixel_fifo
    port map (
      clk        => prb_clk,            -- [IN]
      rst        => prb_rst,            -- [IN]
      din        => prb_in,             -- [IN]
      wr_en      => prb_wr,             -- [IN]
      rd_en      => prb_rd,             -- [IN]
      dout       => prb_out,
      full       => prb_full,           -- [OUT]
      empty      => prb_empty,
      data_count => prb_count(6 downto 0)
      );                                -- [OUT]

  pw_fifo_comp : entity work.mcb_pixel_fifo
    port map (
      clk        => pw_clk,             -- [IN]
      rst        => pw_rst,             -- [IN]
      din        => pw_in,              -- [IN]
      wr_en      => pw_wr,              -- [IN]
      rd_en      => pw_rd,              -- [IN]
      dout       => pw_out,
      full       => pw_full,            -- [OUT]
      empty      => pw_empty,
      data_count => pw_count(6 downto 0)
      );                                -- [OUT]

--
  
  auxr_fifo_comp : entity work.mcb_aux_fifo
    port map (
      clk        => auxr_clk,           -- [IN]
      rst        => auxr_rst,           -- [IN]
      din        => auxr_in,            -- [IN]
      wr_en      => auxr_wr,            -- [IN]
      rd_en      => auxr_rd,            -- [IN]
      dout       => auxr_out,           -- [OUT]
      full       => auxr_full,          -- [OUT]
      empty      => auxr_empty,
      data_count => auxr_count(7 downto 0)
      );                                -- [OUT] 

  auxw_fifo_comp : entity work.mcb_aux_fifo
    port map (
      clk        => auxw_clk,           -- [IN]
      rst        => auxw_rst,           -- [IN]
      din        => auxw_in,            -- [IN]
      wr_en      => auxw_wr,            -- [IN]
      rd_en      => auxw_rd,            -- [IN]
      dout       => auxw_out,           -- [OUT]
      full       => auxw_full,          -- [OUT]
      empty      => auxw_empty,
      data_count => auxw_count(7 downto 0)
      );                                -- [OUT]

-------------------------------------------------------------------------------
-- READ
-------------------------------------------------------------------------------
  -- mbc_fifo to p/aux_fifo
  pra_rst        <= rstalg;
  pra_clk        <= pra_fifo.clk;
  pra_rd         <= pra_fifo.en;
  pra_fifo.stall <= pra_empty;
  pra_fifo.data  <= pra_out;

  prb_rst        <= rstalg;
  prb_clk        <= prb_fifo.clk;
  prb_rd         <= prb_fifo.en;
  prb_fifo.stall <= prb_empty;
  prb_fifo.data  <= prb_out;

  auxr_rst        <= rstalg;
  auxr_clk        <= auxr_fifo.clk;
  auxr_rd         <= auxr_fifo.en;
  auxr_fifo.stall <= auxr_empty;
  auxr_fifo.data  <= auxr_out;

-------------------------------------------------------------------------------
-- WRITE
-------------------------------------------------------------------------------
  pw_rst        <= rstalg;
  pw_clk        <= pw_fifo.clk;
  pw_wr         <= pw_fifo.en;
  pw_fifo.stall <= pw_full;
  pw_in         <= pw_fifo.data;

  auxw_rst        <= rstalg;
  auxw_clk        <= auxw_fifo.clk;
  auxw_wr         <= auxw_fifo.en;
  auxw_fifo.stall <= auxw_full;
  auxw_in         <= auxw_fifo.data;

  -- p/aux_fifo to real mcb
  pra_in  <= p0_rd_data;
  prb_in  <= p0_rd_data;
  auxr_in <= p0_rd_data;

  p0_cmd_clk <= clkalg;
  p0_rd_clk  <= clkalg;
  p0_wr_clk  <= clkalg;

  process (move_state)
  begin  -- process
    move_nstate <= move_state;

    p0_cmd_en        <= '0';
    p0_cmd_instr     <= (others => '0');
    p0_cmd_bl        <= (others => '0');
    p0_cmd_byte_addr <= (others => '0');
    p0_wr_mask       <= "0000";

    p0_rd_en <= '0';
    p0_wr_en <= '0';
    pra_wr   <= '0';
    prb_wr   <= '0';
    auxr_wr  <= '0';
    pw_rd    <= '0';
    auxw_rd  <= '0';

    p0_wr_data <= (others => '0');
    d.state    <= (others => '0');
    case move_state is

      when move_reset =>
        move_nstate <= move_wait;

        
      when move_wait =>
        if pra_count <= std_logic_vector(to_unsigned((64-16), 7)) then
          move_nstate <= move_r_pa;
        end if;
        if prb_count <= std_logic_vector(to_unsigned((64-16), 7)) then
          move_nstate <= move_r_pb;
        end if;
        if auxr_count <= std_logic_vector(to_unsigned((128-32), 8)) then
          move_nstate <= move_r_aux;
        end if;
        if pw_count >= std_logic_vector(to_unsigned(16, 7)) then
          move_nstate <= move_w_transfer_p;
        end if;
        if auxw_count >= std_logic_vector(to_unsigned(32, 8)) then
          move_nstate <= move_w_transfer_aux;
        end if;
        d.state(0) <= '1';
        
      when move_r_pa =>
        d.state(1) <= '1';
        if p0_cmd_empty = '1' then
          p0_cmd_en        <= '1';
          p0_cmd_instr     <= MCB_CMD_RD;
          p0_cmd_bl        <= std_logic_vector(to_unsigned(15, 6));
          p0_cmd_byte_addr <= std_logic_vector(to_unsigned(my_pixel_a_rd_addr+CAMA_OFFSET, 30));
          move_nstate      <= move_r_transfer_pa;
        end if;
      when move_r_transfer_pa =>
        d.state(2) <= '1';
        if p0_rd_count >= std_logic_vector(to_unsigned(16, 6)) then
          move_nstate <= move_r_transfer_pa_1;
        end if;
      when move_r_transfer_pa_1 =>
        d.state(3) <= '1';
        if p0_rd_empty = '0' then
          p0_rd_en <= '1';
          pra_wr   <= '1';
        else
          move_nstate <= move_r_pa_inc;
        end if;
      when move_r_pa_inc =>
        move_nstate <= move_wait;

      when move_r_pb =>
        d.state(1) <= '1';
        if p0_cmd_empty = '1' then
          p0_cmd_en        <= '1';
          p0_cmd_instr     <= MCB_CMD_RD;
          p0_cmd_bl        <= std_logic_vector(to_unsigned(15, 6));
          p0_cmd_byte_addr <= std_logic_vector(to_unsigned(my_pixel_b_rd_addr+CAMB_OFFSET, 30));
          move_nstate      <= move_r_transfer_pb;
        end if;
      when move_r_transfer_pb =>
        d.state(2) <= '1';
        if p0_rd_count >= std_logic_vector(to_unsigned(16, 6)) then
          move_nstate <= move_r_transfer_pb_1;
        end if;
      when move_r_transfer_pb_1 =>
        d.state(3) <= '1';
        if p0_rd_empty = '0' then
          p0_rd_en <= '1';
          prb_wr   <= '1';
        else
          move_nstate <= move_r_pb_inc;
        end if;
      when move_r_pb_inc =>
        move_nstate <= move_wait;
        
      when move_r_aux =>
        d.state(4) <= '1';
        if p0_cmd_empty = '1' then
          p0_cmd_en        <= '1';
          p0_cmd_instr     <= MCB_CMD_RD;
          p0_cmd_bl        <= std_logic_vector(to_unsigned(31, 6));
          p0_cmd_byte_addr <= std_logic_vector(to_unsigned(my_aux_rd_addr+AUX_OFFSET, 30));
          move_nstate      <= move_r_transfer_aux;
        end if;
      when move_r_transfer_aux =>
        d.state(5) <= '1';
        if p0_rd_count >= std_logic_vector(to_unsigned(32, 6)) then
          move_nstate <= move_r_transfer_aux_1;
        end if;
      when move_r_transfer_aux_1 =>
        d.state(6) <= '1';
        if p0_rd_empty = '0' then
          p0_rd_en <= '1';
          auxr_wr  <= '1';
        else
          move_nstate <= move_r_aux_inc;
        end if;
      when move_r_aux_inc =>
        move_nstate <= move_wait;

-------------------------------------------------------------------------------        

      when move_w_transfer_p =>
        d.state(7) <= '1';
        p0_wr_data <= pw_out;
        if p0_wr_count < std_logic_vector(to_unsigned(16, 6)) then
          p0_wr_en <= '1';
          pw_rd    <= '1';
        else
          move_nstate <= move_w_p;
        end if;
      when move_w_p =>
        d.state(8) <= '1';
        if p0_cmd_empty = '1' then
          p0_cmd_en        <= '1';
          p0_cmd_instr     <= MCB_CMD_WR;
          p0_cmd_bl        <= std_logic_vector(to_unsigned(15, 6));
          p0_cmd_byte_addr <= std_logic_vector(to_unsigned(my_pixel_wr_addr+DVI_OFFSET, 30));
          move_nstate      <= move_w_transfer_p_1;
        end if;
      when move_w_transfer_p_1 =>
        d.state(9) <= '1';
        if p0_wr_empty = '1' then
          move_nstate <= move_w_p_inc;
        end if;
      when move_w_p_inc =>
        move_nstate <= move_wait;

        
      when move_w_transfer_aux =>
        d.state(10) <= '1';
        p0_wr_data  <= auxw_out;
        if p0_wr_count < std_logic_vector(to_unsigned(32, 6)) then
          p0_wr_en <= '1';
          auxw_rd  <= '1';
        else
          move_nstate <= move_w_aux;
        end if;
      when move_w_aux =>
        d.state(11) <= '1';
        if p0_cmd_empty = '1' then
          p0_cmd_en        <= '1';
          p0_cmd_instr     <= MCB_CMD_WR;
          p0_cmd_bl        <= std_logic_vector(to_unsigned(31, 6));
          p0_cmd_byte_addr <= std_logic_vector(to_unsigned(my_aux_wr_addr+AUX_OFFSET, 30));
          move_nstate      <= move_w_transfer_aux_1;
        end if;
      when move_w_transfer_aux_1 =>
        d.state(12) <= '1';
        if p0_wr_empty = '1' then
          move_nstate <= move_w_aux_inc;
        end if;
      when move_w_aux_inc =>
        move_nstate <= move_wait;


        
      when others => null;
    end case;
  end process;



  my_cfg_sync : entity work.cfg_sync
    port map (
      clk  => clkalg,                   -- [in]
      din  => cfg_unsync,               -- [in]
      dout => cfg);                     -- [out] 

  led_o <= (others => '0');
-------------------------------------------------------------------------------
-- PIPE
-------------------------------------------------------------------------------  

  my_pipe_head : entity work.pipe_head
    generic map (
      ID => 0)
    port map (
      clk      => clkalg,               -- [in]
      rst      => rstalg,               -- [in]
      cfg      => cfg,                  -- [in]
      pipe_out => pipe(0));             -- [out]

  stallo <= stall(0);
  my_mcb_feed_dual : entity work.mcb_feed_dual
    generic map (
      ID => 1)
    port map (
      pipe_in   => pipe(0),             -- [in]
      pipe_out  => pipe(1),             -- [out]
      stall_in  => stall(1),
      stall_out => stall(0),
      pa_fifo   => pra_fifo,            -- [inout]
      pb_fifo   => prb_fifo,            -- [inout]      
      p1_fifo   => auxr_fifo);          -- [inout]


  --dut2 : entity work.win_test_8
  --  generic map (
  --    ID     => 28,
  --    KERNEL => 5)
  --  port map (
  --    pipe_in     => pipe(2),           -- [in]
  --    pipe_out    => pipe(3),
  --    stall_in    => stall(3),
  --    stall_out   => stall(2),
  --    gray8_2d_in => gray8_2d
  --    );                                -- [inout] 


  ----my_motion : entity work.motion
  ----  generic map (
  ----    ID => 3)
  ----  port map (
  ----    pipe_in  => pipe(2),              -- [in]
  ----    pipe_out => pipe(3));             -- [out]

  --my_morph : entity work.morph_set
  --  generic map (
  --    ID     => 4,
  --    KERNEL => 5,
  --    WIDTH  => WIDTH,
  --    HEIGHT => HEIGHT)
  --  port map (
  --    pipe_in   => pipe(2),             -- [in]
  --    pipe_out  => pipe(3),
  --    stall_in  => stall(3),
  --    stall_out => stall(2));

  --my_hist_x : entity work.hist_x
  --  generic map (
  --    ID     => 24,
  --    WIDTH  => WIDTH,
  --    HEIGHT => HEIGHT)
  --  port map (
  --    pipe_in  => pipe(4),              -- [in]
  --    pipe_out => pipe(5));             -- [out]

  --my_hist_y : entity work.hist_y
  --  generic map (
  --    ID     => 25,
  --    WIDTH  => WIDTH,
  --    HEIGHT => HEIGHT)
  --  port map (
  --    pipe_in  => pipe(5),              -- [in]
  --    pipe_out => pipe(6));             -- [out]

  --dut : entity work.win_16
  --  generic map (
  --    ID     => 25,
  --    KERNEL => 9,
  --    WIDTH  => WIDTH,
  --    HEIGHT => HEIGHT)
  --  port map (
  --    pipe_in      => pipe(1),          -- [in]
  --    pipe_out     => pipe(2),
  --    stall_in     => stall(2),
  --    stall_out    => stall(1),
  --    rgb565_2d_out => rgb565_2d
  --    );                                -- [inout]

  --dut2 : entity work.census
  --  generic map (
  --    ID     => 26,
  --    KERNEL => 9
  --  port map (
  --    pipe_in     => pipe(2),           -- [in]
  --    pipe_out    => pipe(3),
  --    stall_in    => stall(3),
  --    stall_out   => stall(2),
  --    rgb565_2d_in => rgb565_2d,
  --    mono_2d_l => mono_2d_l,
  --    mono_2d_r => mono_2d_r      
  --    );                                -- [inout]

  --dut3 : entity work.disparity
  --  generic map (
  --    ID     => 27,
  --    KERNEL => 9 ,
  --    MAX_DISPARITY => 8
  --  port map (
  --    pipe_in     => pipe(3),           -- [in]
  --    pipe_out    => pipe(4),
  --    stall_in    => stall(4),
  --    stall_out   => stall(3),
  --    mono_2d_l => mono_2d_l,
  --    mono_2d_r => mono_2d_r      
  --    );                                -- [inout]

  --dut2 : entity work.win_test_8
  --  generic map (
  --    ID     => 25)
  --  port map (
  --    pipe_in      => pipe(3),          -- [in]
  --    pipe_out     => pipe(4),
  --    stall_in     => stall(4),
  --    stall_out    => stall(3),
  --    gray8_2d_in => gray8_2d_1      
  --    );                                -- [inout]


  --bitest : entity work.bi
  --  generic map (
  --    ID     => 25,
  --    WIDTH  => WIDTH,
  --    HEIGHT => HEIGHT)
  --  port map (
  --    pipe_in      => pipe(3),          -- [in]
  --    pipe_out     => pipe(4),
  --    stall_in     => stall(4),
  --    stall_out    => stall(3),
  --    abcd         => abcd,
  --    gray8_2d_in  => gray8_2d_1,
  --    gray8_2d_out => gray8_2d_2
  --    );                                -- [inout]

  --bitest2 : entity work.bi2
  --  generic map (
  --    ID     => 26,
  --    WIDTH  => WIDTH,
  --    HEIGHT => HEIGHT)
  --  port map (
  --    pipe_in     => pipe(4),           -- [in]
  --    pipe_out    => pipe(5),
  --    stall_in    => stall(5),
  --    stall_out   => stall(4),
  --    abcd        => abcd,
  --    gray8_2d_in => gray8_2d_2,
  --    abcd2       => abcd2
  --    );                                -- [inout]

  --bitest3 : entity work.bi3
  --  generic map (
  --    ID     => 27,
  --    WIDTH  => WIDTH,
  --    HEIGHT => HEIGHT)
  --  port map (
  --    pipe_in   => pipe(5),             -- [in]
  --    pipe_out  => pipe(6),
  --    stall_in  => stall(6),
  --    stall_out => stall(5),
  --    abcd2     => abcd2
  --    );                                -- [inout]

  my_col_mux : entity work.color_mux
    generic map (
      ID   => 3,
      MODE => 3)
    port map (
      pipe_in   => pipe(1),             -- [in]
      pipe_out  => pipe(7),
      stall_in  => stall(7),
      stall_out => stall(1));           -- [inout]

  my_fifo_sink : entity work.fifo_sink
    generic map (
      ID     => 4,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT
      )
    port map (
      pipe_in   => pipe(7),             -- [in]
      pipe_out  => pipe(8),             -- [out]
      stall_in  => stall(8),
      stall_out => stall(7),
      p0_fifo   => out_fifo);           -- [inout]

  my_mcb_sink : entity work.mcb_sink
    generic map (
      ID => 2)
    port map (
      pipe_in   => pipe(8),             -- [in]
      pipe_out  => pipe(9),             -- [out]
      stall_in  => '0',
      stall_out => stall(8),
      p0_fifo   => pw_fifo,             -- [inout]
      p1_fifo   => auxw_fifo);          -- [inout]

  inspect.identity <= pipe(9).stage.identity;

  my_pixel_fifo : entity work.pixel_fifo
    port map (
      rst           => rstalg,                       -- [IN]
      wr_clk        => out_fifo.clk,                 -- [IN]
      rd_clk        => usb_fifo.clk,                 -- [IN]
      din           => out_fifo.data,                -- [IN]
      wr_en         => out_fifo.en,                  -- [IN]
      rd_en         => usb_fifo.en,                  -- [IN]
      dout          => usb_fifo.data(7 downto 0),    -- [OUT]
      full          => out_fifo.stall,               -- [OUT]
      empty         => usb_fifo.stall,
      rd_data_count => usb_fifo.count(7 downto 0));  -- [OUT]

  --usb_fifo.data  <= (others => '0');
  --usb_fifo.count <= (others => '0');
  --usb_fifo.stall <= '0';


  d.pr_count   <= "0" & pra_count;
  d.pw_count   <= "0" & pw_count;
  d.auxr_count <= auxr_count;
  d.auxw_count <= auxw_count;

  d.fe(0) <= pra_empty;
  d.fe(1) <= pra_full;
  d.fe(2) <= pw_empty;
  d.fe(3) <= pw_full;
  d.fe(4) <= auxr_empty;
  d.fe(5) <= auxr_full;
  d.fe(6) <= auxw_empty;
  d.fe(7) <= auxw_full;


  d.off <= stall(1) & stall(0) & stall(7) & stall(8) & "0000";
end Behavioral;


