---------------------------------------------------------------------------------
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
use IEEE.std_logic_arith.all;

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
    RDY_O   : out std_logic;
------------------------------------------------------------------------------------
-- Title : Port C - read only
-- Description: Supports straightforward read functionality for whole frames on a
-- constant basis. Connect to Display Controller
------------------------------------------------------------------------------------
    ENC     : in  std_logic;            --port enable
    RSTC_I  : in  std_logic;            --asynchronous port reset
    DOC     : out std_logic_vector (COLORDEPTH - 1 downto 0);  --data output
    CLKC    : in  std_logic;            --port clock
    RD_MODE : in  std_logic_vector(1 downto 0);
------------------------------------------------------------------------------------
-- Title : Port B - write only
------------------------------------------------------------------------------------
    ENCAM   : in  std_logic;            --port enable
    RSTCAM  : in  std_logic;            --asynchronous port reset
    DCAM    : in  std_logic_vector (COLORDEPTH - 1 downto 0);  --data output
    CLKCAM  : in  std_logic;            --port clock

    debug_wr         : out   std_logic;
    debug_data       : out   std_logic_vector(7 downto 0);
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
    fbctl_debug      : inout   fbctl_debug_t

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

  signal pb_wr_cnt                  : natural                        := 0;
  signal pb_wr_addr                 : natural range 0 to VMEM_SIZE-1 := 0;
  signal pb_wr_data_sel, pb_int_rst : std_logic;

  signal pc_rd_addr1, pc_rd_addr2 : natural   := 0;
  signal fVMemSource              : std_logic := '0';
  signal rd_data_sel              : std_logic;
  signal int_rd_mode              : std_logic_vector(1 downto 0);

  signal RstC, SRstC, SRstcam, SCalibDoneB : std_logic;


  signal my_p0_rd_addr : natural range 0 to 2**22-1 := 0;
  signal my_p0_wr_addr : natural range 0 to 2**22-1 := 0;
  signal my_p1_addr    : natural range 0 to 2**22-1 := 0;

  signal   fill_count : natural range 0 to 32;
  type     my_state_t is (my_idle, my_read_p0, my_read_p1, my_write_p0, my_write_p1, my_inc, my_wait, my_trans, my_trans_2, my_trans_3, my_trans_4, my_wait_l, my_wait_h, my_read_p0_wait, my_reset, my_reset_2, my_idle_2, my_idle_3);
  signal   my_state   : my_state_t;
  signal   my_nstate  : my_state_t;
  signal   go         : std_logic; signal next_go : std_logic;
  constant P0_BATCH   : natural := 16;
  constant P1_BATCH   : natural := 32;

  signal pixell    : unsigned(7 downto 0);
  signal pixelh    : unsigned(7 downto 0);
  signal in_pixell : unsigned(7 downto 0);
  signal in_pixelh : unsigned(7 downto 0);
  signal npixell   : unsigned(7 downto 0);
  signal npixelh   : unsigned(7 downto 0);

  signal in_param4 : unsigned(7 downto 0);
  signal nparam4   : unsigned(7 downto 0);
  signal param4    : unsigned(7 downto 0);

  signal in_param1 : unsigned(7 downto 0);
  signal nparam1   : unsigned(7 downto 0);
  signal param1    : unsigned(7 downto 0);

  signal in_param2 : unsigned(7 downto 0);
  signal nparam2   : unsigned(7 downto 0);
  signal param2    : unsigned(7 downto 0);

  signal in_param3 : unsigned(7 downto 0);
  signal nparam3   : unsigned(7 downto 0);
  signal param3    : unsigned(7 downto 0);

  type alg_state_t is (alg_reset,

                       alg_low,
                       alg_low_1,
                       alg_low_2,
                       alg_low_3,
                       alg_low_4,
                       alg_finish_low,

                       alg_high,
                       alg_high_1,
                       alg_high_2,
                       alg_high_3,
                       alg_high_4,
                       alg_finish_high);

  signal alg_state  : alg_state_t;
  signal alg_nstate : alg_state_t;

  signal clkalg     : std_logic;
  signal rstalg     : std_logic;
  signal rstcam_int : std_logic;

  signal feed_is_high : std_logic;
  signal sink_is_high : std_logic;


  signal vin       : stream_t;
  signal vout      : stream_t;
  signal vin_data  : std_logic_vector(7 downto 0);
  signal vout_data : std_logic_vector(7 downto 0);
  
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
        pc_rd_addr1 <= 0;
        rdy_o       <= '0';
      else
        
        staterd <= nstaterd;

        if (enc = '1') then
          rd_data_sel <= not rd_data_sel;
        end if;
        if (staterd = strdcmd) then
          if (pc_rd_addr1 = 640*2*480/(rd_batch*4)-1) then
            pc_rd_addr1 <= 0;
          else
            pc_rd_addr1 <= pc_rd_addr1 + 1;
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

  next_state_decode : process (staterd, p3_rd_count, p3_rd_error)
  begin
    nstaterd <= staterd;                --default is to stay in current state

    p3_cmd_instr <= mcb_cmd_rd;         -- port 3 read-only
    p3_cmd_bl    <= conv_std_logic_vector(rd_batch-1, 6);  -- we read 32 dwords (32-bit) at a time
    p3_cmd_clk   <= clkc;

    p3_cmd_en        <= '0';
    p3_cmd_byte_addr <= conv_std_logic_vector(pc_rd_addr1 * (rd_batch*4)+(2**20), 30);

    p3_rd_en  <= rd_data_sel and enc;
    p3_rd_clk <= clkc;


    case (staterd) is
      when strdidle =>
        if (p3_rd_count < 16) then
          nstaterd <= strdcmd;
        end if;
      when strdcmd =>
        p3_cmd_en <= '1';
        nstaterd  <= strdcmdwait;
      when strdcmdwait =>
        if (p3_rd_error = '1') then
          nstaterd <= strderr;             --the read fifo got empty
        elsif not (p3_rd_count < 16) then  -- data is present in the fifo
          nstaterd <= strdidle;
        end if;
      when strderr =>
        null;
      when others =>
        nstaterd <= strdidle;
    end case;
  end process;

-----------------------------------------------------------------------------
-- CAMERA
-----------------------------------------------------------------------------
  inst_localrstb1 : entity digilent.localrst port map(
    rst_i  => rstcam_int,
    clk_i  => clkcam,
    srst_o => srstcam
    );
  rstcam_int <= rstcam or not calib_done;
  
  inst_localrstb2 : entity digilent.localrst port map(
    rst_i  => calib_done,
    clk_i  => clkcam,
    srst_o => scalibdoneb
    );

  portarst_proc_b : process(clkcam)
  begin
    if rising_edge(clkcam) then
      if (srstcam = '1') then
        pb_int_rst <= '1';
      elsif (p2_wr_empty = '1') then
        pb_int_rst <= '0';
      end if;

-------------------------------------------------------------------------------
-- SELECTOR
-------------------------------------------------------------------------------
      if (srstcam = '1') then
        pb_wr_data_sel <= '0';
      elsif (encam = '1') then
        pb_wr_data_sel <= not pb_wr_data_sel;
      end if;

      if (encam = '1') then
        if (pb_wr_data_sel = '0') then
          p2_wr_data(15 downto 0) <= dcam;
        end if;
      end if;
-------------------------------------------------------------------------------
-- ADR COUNT
-------------------------------------------------------------------------------      
      if (pb_int_rst = '1' and p2_wr_empty = '1') then
        pb_wr_addr <= 0;
      elsif (statewrb = stwrcmd) then
        if (pb_wr_addr = 640*480*2/(wr_batch*4)-1) then
          pb_wr_addr <= 0;
        else
          pb_wr_addr <= pb_wr_addr + 1;
        end if;
      end if;
-------------------------------------------------------------------------------
-- STATE
-------------------------------------------------------------------------------
      if (scalibdoneb = '0' or p2_wr_empty = '1') then
        statewrb <= stwridle;
      else
        statewrb <= nstatewrb;
      end if;
-------------------------------------------------------------------------------
-- WR COUNT
-------------------------------------------------------------------------------
      if (statewrb = stwrcmd) then
        if (p2_wr_en = '1' and pb_int_rst = '0') then
          pb_wr_cnt <= 1;
        else
          pb_wr_cnt <= 0;
        end if;
      elsif (p2_wr_en = '1' and pb_int_rst = '0') then
        pb_wr_cnt <= pb_wr_cnt + 1;
      end if;
      
    end if;
  end process;

  p2_wr_clk                <= clkcam;
  p2_wr_en                 <= pb_wr_data_sel and encam;
  p2_wr_data(31 downto 16) <= dcam;
  p2_wr_mask               <= "0000";

  p2_cmd_clk       <= clkcam;
  p2_cmd_instr     <= mcb_cmd_wr;       -- port 1 write-only
  p2_cmd_byte_addr <= conv_std_logic_vector(pb_wr_addr * (wr_batch*4), 30);
  p2_cmd_bl        <= conv_std_logic_vector(pb_wr_cnt-1, 6) when pb_int_rst = '1' else
                      conv_std_logic_vector(wr_batch-1, 6);

  wrnext_state_decode_b : process (statewrb, p2_wr_count, p2_wr_error, pb_int_rst, p2_wr_empty, pb_wr_cnt)
  begin
    nstatewrb <= statewrb;              --default is to stay in current state
    p2_cmd_en <= '0';
    case (statewrb) is
      when stwridle =>
        if (pb_wr_cnt >= wr_batch or pb_int_rst = '1') then
          nstatewrb <= stwrcmd;
        end if;
      when stwrcmd =>
        p2_cmd_en <= '1';
        nstatewrb <= stwrcmdwait;
      when stwrcmdwait =>
        if (p2_wr_error = '1') then
          nstatewrb <= stwrerr;         --the write fifo got empty
        elsif ((pb_int_rst = '0' and p2_wr_count < wr_batch) or
               (pb_int_rst = '1' and p2_wr_empty = '1')) then  -- data got transferred from the fifo
          nstatewrb <= stwridle;
        end if;
      when stwrerr =>
        null;
      when others =>
        nstatewrb <= stwridle;
    end case;
  end process;


-------------------------------------------------------------------------------
-- ALGO on P0 and P1
-------------------------------------------------------------------------------
  clkalg <= clkcam;
  inst_localrstalg : entity digilent.localrst port map(
    rst_i  => srstc,
    clk_i  => clkalg,
    srst_o => rstalg
    );

  process (clkalg)
  begin  -- process
    if clkalg'event and clkalg = '1' then  -- rising clock edge
      if rstalg = '1' then                 -- synchronous reset (active high)
        my_state      <= my_reset;
        my_p0_rd_addr <= 0;
        my_p0_wr_addr <= 2**20;
        my_p1_addr    <= 2**21;
        go            <= '0';

        alg_state <= alg_reset;
      else
-------------------------------------------------------------------------------
-- Memory 
-------------------------------------------------------------------------------
        if my_state = my_inc then

          if (my_p0_rd_addr = 640*2*480-P0_BATCH*4) then
            my_p0_rd_addr <= 0;
            my_p0_wr_addr <= 2**20;
            my_p1_addr    <= 2**21;
          else
            my_p0_rd_addr <= my_p0_rd_addr + P0_BATCH*4;
            my_p0_wr_addr <= my_p0_wr_addr + P0_BATCH*4;
            my_p1_addr    <= my_p1_addr + P1_BATCH*4;
          end if;

        end if;
        go       <= next_go;
        my_state <= my_nstate;

-------------------------------------------------------------------------------
-- Algo
-------------------------------------------------------------------------------
        pixell <= npixell;
        pixelh <= npixelh;

        param1    <= nparam1;
        param2    <= nparam2;
        param3    <= nparam3;
        param4    <= nparam4;
        alg_state <= alg_nstate;
        
      end if;
    end if;
  end process;


  p0_cmd_clk <= clkalg;
  p0_cmd_bl  <= conv_std_logic_vector(P0_BATCH-1, 6);
  p0_rd_clk  <= clkalg;
  p0_wr_clk  <= clkalg;

  p1_cmd_clk <= clkalg;
  p1_cmd_bl  <= conv_std_logic_vector(P1_BATCH-1, 6);  
  p1_rd_clk  <= clkalg;
  p1_wr_clk  <= clkalg;


  p0_wr_mask <= (others => '0');
  p1_wr_mask <= (others => '0');

  process (my_state)
  begin  -- process
    my_nstate <= my_state;

    p0_cmd_en <= '0';
    p1_cmd_en <= '0';

    p0_cmd_byte_addr <= (others => '0');
    p1_cmd_byte_addr <= conv_std_logic_vector(my_p1_addr, 30);

    p0_cmd_instr <= (others => '0');
    p1_cmd_instr <= (others => '0');

    debug_wr   <= '0';
    debug_data <= (others => '0');

    next_go <= '0';

    case my_state is

      when my_reset =>

        my_nstate <= my_read_p0;
        
      when my_read_p0 =>

        if p0_rd_empty = '1' and p0_wr_empty = '1' and p1_wr_empty = '1' and p0_cmd_empty = '1' then
          debug_wr   <= '1';debug_data <= X"0F";
          p0_cmd_en        <= '1';
          p0_cmd_instr     <= MCB_CMD_RD;
          p0_cmd_byte_addr <= conv_std_logic_vector(my_p0_rd_addr, 30);
          my_nstate        <= my_read_p1;
        end if;

      when my_read_p1 =>

        if p1_rd_empty = '1' and p1_wr_empty = '1' and p1_cmd_empty = '1' then
          next_go          <= '1';
          p1_cmd_en        <= '1';
          p1_cmd_instr     <= MCB_CMD_RD;
          p1_cmd_byte_addr <= conv_std_logic_vector(my_p1_addr, 30);
          my_nstate        <= my_write_p0;
        end if;
        
      when my_write_p0 =>

        if p0_wr_count = P0_BATCH and p0_cmd_empty = '1' then
          p0_cmd_en        <= '1';
          p0_cmd_instr     <= MCB_CMD_WR;
          p0_cmd_byte_addr <= conv_std_logic_vector(my_p0_wr_addr, 30);
          my_nstate        <= my_write_p1;
        end if;

      when my_write_p1 =>

        if p1_wr_count = P1_BATCH and p1_cmd_empty = '1' then
          p1_cmd_en        <= '1';
          p1_cmd_instr     <= MCB_CMD_WR;
          p1_cmd_byte_addr <= conv_std_logic_vector(my_p1_addr, 30);
          my_nstate        <= my_inc;
        end if;
        
      when my_inc =>
        my_nstate <= my_read_p0;
        
      when others => null;
    end case;
  end process;


  vin <= (others => '0');
  vout <= (others => '0');  

  process (p0_rd_data)
    variable brightness : std_logic_vector(15 downto 0);
  begin  -- process
    brightness := conv_std_logic_vector(unsigned("000" & p0_rd_data(15 downto 11) & "0") + unsigned("000" & p0_rd_data(10 downto 5)) + unsigned("000" & p0_rd_data(4 downto 0) & "0"), 16);


    in_pixell <= unsigned(brightness(7 downto 0));
    
  end process;

  process (p0_rd_Data)
    variable brightness : std_logic_vector(15 downto 0);
  begin  -- process
    brightness := conv_std_logic_vector(unsigned("000" & p0_rd_data(15+16 downto 11+16) & "0") + unsigned("000" & p0_rd_data(10+16 downto 5+16)) + unsigned("000" & p0_rd_data(4+16 downto 0+16) & "0"), 16);


    in_pixelh <= unsigned(brightness(7 downto 0));
    
  end process;


  p0_wr_data <= p0_rd_data;
  p1_wr_data <= p1_rd_data;

  --p0_wr_data(15 downto 11) <= std_logic_vector(npixell(7 downto 3));
  --p0_wr_data(10 downto 5)  <= std_logic_vector(npixell(7 downto 2));
  --p0_wr_data(4 downto 0)   <= std_logic_vector(npixell(7 downto 3));

  --p0_wr_data(15+16 downto 11+16) <= std_logic_vector(npixelh(7 downto 3));
  --p0_wr_data(10+16 downto 5+16)  <= std_logic_vector(npixelh(7 downto 2));
  --p0_wr_data(4+16 downto 0+16)   <= std_logic_vector(npixelh(7 downto 3));
  
  --in_param1 <= unsigned(p1_rd_data(7 downto 0));
  --in_param2 <= unsigned(p1_rd_data(15 downto 8));
  --in_param3 <= unsigned(p1_rd_data(23 downto 16));
  --in_param4 <= unsigned(p1_rd_data(31 downto 24));

  --p1_wr_data(7 downto 0)   <= std_logic_vector(nparam1);
  --p1_wr_data(15 downto 8)  <= std_logic_vector(nparam2);
  --p1_wr_data(23 downto 16) <= std_logic_vector(nparam3);
  --p1_wr_data(31 downto 24) <= std_logic_vector(nparam4);


  p0_rd_en <= '1' when p0_rd_empty = '0' else
              '0';
  p0_wr_en <= '1' when p0_rd_empty = '0' else
              '0';
  p1_rd_en <= '1' when p1_rd_empty = '0' else
              '0';
  p1_wr_en <= '1' when p1_rd_empty = '0' else
              '0';




end Behavioral;

