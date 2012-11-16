----------------------------------------------------------------------------------
-- company: digilent ro
-- engineer: elod gyorgy
-- 
-- create date:    12:50:18 04/06/2011 
-- design name:      vmodcam reference design 1
-- module name:      vmodcam_ref - behavioral
-- project name:     
-- target devices: 
-- tool versions: 
-- description: the design shows off the video feed from two cameras located on
-- a vmodcam add-on board connected to an atlys. the video feeds are displayed on
-- a dvi-capable flat panel.
--
-- dependencies: 
--
-- revision: 
-- revision 0.01 - file created
-- additional comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


library digilent;
use digilent.video.all;
-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx primitives in this code.
library unisim;
use unisim.vcomponents.all;

library work;
use work.cam_pkg.all;


entity top is
  generic (
    c3_num_dq_pins        : integer := 16;
    c3_mem_addr_width     : integer := 13;
    c3_mem_bankaddr_width : integer := 3;
    fpgalink              : integer := 1

    );
  port (
    tmds_tx_2_p   : out   std_logic;
    tmds_tx_2_n   : out   std_logic;
    tmds_tx_1_p   : out   std_logic;
    tmds_tx_1_n   : out   std_logic;
    tmds_tx_0_p   : out   std_logic;
    tmds_tx_0_n   : out   std_logic;
    tmds_tx_clk_p : out   std_logic;
    tmds_tx_clk_n : out   std_logic;
    tmds_tx_scl   : inout std_logic;
    tmds_tx_sda   : inout std_logic;
    sw_i          : in    std_logic_vector(7 downto 0);
    led_o         : out   std_logic_vector(7 downto 0);
    clk_i         : in    std_logic;
    reset_i       : in    std_logic;
    sup_rst       : in    std_logic;


    tmdsclk_p : in  std_logic;
    tmdsclk_n : in  std_logic;
    blue_p    : in  std_logic;
    green_p   : in  std_logic;
    red_p     : in  std_logic;
    blue_n    : in  std_logic;
    green_n   : in  std_logic;
    red_n     : in  std_logic;

----------------------------------------------------------------------------------
-- ddr2 interface
----------------------------------------------------------------------------------
    mcb3_dram_dq     : inout std_logic_vector(c3_num_dq_pins-1 downto 0);
    mcb3_dram_a      : out   std_logic_vector(c3_mem_addr_width-1 downto 0);
    mcb3_dram_ba     : out   std_logic_vector(c3_mem_bankaddr_width-1 downto 0);
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
-- fpga link
-------------------------------------------------------------------------------
    -- fx2 interface -----------------------------------------------------------------------------
    fx2clk_in   : in    std_logic;      -- 48mhz clock from fx2
    fx2addr_out : out   std_logic_vector(1 downto 0);  -- select fifo: "10" for ep6out, "11" for ep8in
    fx2data_io  : inout std_logic_vector(7 downto 0);  -- 8-bit data to/from fx2

    -- when ep6out selected:
    fx2read_out   : out std_logic;  -- asserted (active-low) when reading from fx2
    fx2oe_out     : out std_logic;  -- asserted (active-low) to tell fx2 to drive bus
    fx2gotdata_in : in  std_logic;  -- asserted (active-high) when fx2 has data for us

    -- when ep8in selected:
    fx2write_out  : out std_logic;  -- asserted (active-low) when writing to fx2
    fx2gotroom_in : in  std_logic;  -- asserted (active-high) when fx2 has room for more data from us
    fx2pktend_out : out std_logic;  -- asserted (active-low) when a host read needs to be committed early

    du : out std_logic_vector(1 downto 0)
    );
end top;

architecture behavioral of top is
  signal sysclk, pclk, pclkx2, sysrst, serclk, serstb : std_logic;
  signal msel                                         : std_logic_vector(1 downto 0);

  signal vtchs, vtcvs, vtcvde, vtcrst : std_logic;
  signal vtchcnt, vtcvcnt             : natural;

  signal camclk, camclk_180                             : std_logic;
  --
  signal camapclk, camadv, camavdden, fbwrarst, int_fva : std_logic;
  signal camad                                          : std_logic_vector(15 downto 0);
  signal dummya_t, int_cama_pclk_i                      : std_logic;
  --

  signal ddr2clk_2x, ddr2clk_2x_180, mcb_drp_clk, pll_ce_0, pll_ce_90, pll_lock, async_rst : std_logic;
  signal fbrdy, fbrden, fbrdrst, fbrdclk                                                   : std_logic;
  signal fbrddata                                                                          : std_logic_vector(16-1 downto 0);


  signal counter : natural range 0 to 2**23-1;
  signal rd      : std_logic;
  signal wr      : std_logic;
  signal wr_data : std_logic_vector(7 downto 0);
  signal rd_data : std_logic_vector(7 downto 0);
  signal led_o_t : std_logic_vector(7 downto 0);

-------------------------------------------------------------------------------
-- fpga link
-------------------------------------------------------------------------------
  signal fx2clk_buffered : std_logic;

  signal chanaddr : std_logic_vector(6 downto 0);  -- the selected channel (0-127)
  signal h2fdata  : std_logic_vector(7 downto 0);  -- data lines used when the host writes to a channel
  signal h2fvalid : std_logic;  -- '1' means "on the next clock rising edge, please accept the data on h2fdata"
  signal h2fready : std_logic;  -- channel logic can drive this low to say "i'm not ready for more data yet"
  signal f2hdata  : std_logic_vector(7 downto 0);  -- data lines used when the host reads from a channel
  signal f2hvalid : std_logic;  -- channel logic can drive this low to say "i don't have data ready for you"
  signal f2hready : std_logic;  -- '1' means "on the next clock rising edge, put your next byte of data on f2hdata"
  signal fx2read  : std_logic;

  signal p_f2hvalid : std_logic;  -- channel logic can drive this low to say "i don't have data ready for you"
  signal p_f2hdata  : std_logic_vector(7 downto 0);  -- data lines used when the host reads from a channel  
  signal p_h2fready : std_logic;  -- channel logic can drive this low to say "i'm not ready for more data yet"
  signal p_h2fdata  : std_logic_vector(7 downto 0);  -- data lines used when the host writes to a channel
------------------------------------------------------------------------------------------------
-- registers implementing the channels
-------------------------------------------------------------------------------
  signal reg0, reg0_next : std_logic_vector(7 downto 0) := x"00";
  signal reg1, reg1_next : std_logic_vector(7 downto 0) := x"00";
  signal reg2, reg2_next : std_logic_vector(7 downto 0) := x"00";
  signal reg3, reg3_next : std_logic_vector(7 downto 0) := x"00";
-------------------------------------------------------------------------------
-- user
-------------------------------------------------------------------------------

  signal cfg            : cfg_set_t;
  signal inspect_unsync : inspect_t;
  signal inspect        : inspect_t;
  signal adr            : integer range 0 to max_pipe-1;
  signal fx2clk_int     : std_logic;

  signal usb_fifo : pixel_fifo_t;
  signal fifosel  : std_logic;
  signal fifoen   : std_logic;
  signal d        : d0_t;               --   
  signal stallo   : std_logic;
  signal cam_rst  : std_logic;
  signal clk10mhz : std_logic;

  signal i2c_en_a : std_logic;
  signal i2c_en_b : std_logic;

  signal i2c_sel_a : std_logic;
  signal i2c_sel_b : std_logic;
  signal i2c_sel_c : std_logic;

  signal wr_en_a : std_logic;
  signal wr_en_b : std_logic;
  signal wr_en_c : std_logic;

  signal rd_en_c : std_logic;

  signal wr_full_a  : std_logic;
  signal wr_full_b  : std_logic;
  signal wr_full_c  : std_logic;
  signal wr_empty_a : std_logic;
  signal wr_empty_b : std_logic;
  signal wr_empty_c : std_logic;
  signal dout       : std_logic_vector(7 downto 0);


  signal t                                 : std_logic;


  signal dec_exrst    : std_logic;                     -- [in]
  signal dec_rx_reset : std_logic;                     -- [out]
  signal dec_pclk     : std_logic;                     -- [out]
  signal dec_pclkx2   : std_logic;                     -- [out]
  signal dec_pclkx10  : std_logic;                     -- [out]
  signal dec_pllclk0  : std_logic;
  signal dec_pllclk1  : std_logic;
  signal dec_pllclk2  : std_logic;
  signal dec_plllckd  : std_logic;  
  signal dec_hsync    : std_logic;                     -- [out]
  signal old_dec_vsync    : std_logic;                     -- [out]
  signal dec_vsync    : std_logic;                     -- [out]
  signal dec_vsync_event    : std_logic;                     -- [out]  
  signal dec_de       : std_logic;                     -- [out]
  signal dec_red      : std_logic_vector(7 downto 0);  -- [out]
  signal dec_green    : std_logic_vector(7 downto 0);  -- [out]
  signal dec_blue     : std_logic_vector(7 downto 0);  -- [out]


begin
----------------------------------------------------------------------------------
-- system control unit
-- this component provides a system clock, a synchronous reset and other signals
-- needed for the 40:4 serialization:
-- - serialization clock (5x system clock)
-- - serialization strobe
-- - 2x pixel clock
----------------------------------------------------------------------------------
  inst_syscon : entity work.syscon port map(
    clk_i          => clk_i,
    clk_o          => open,
    rstn_i         => reset_i,
    rsel_o         => open,  --resolution selector synchronized with pclk
    camclk_o       => camclk,
    camclk_180_o   => camclk_180,
    pclk_o         => pclk,
    pclk_x2_o      => pclkx2,
    pclk_x10_o     => serclk,
    serdesstrobe_o => serstb,

    ddr2clk_2x_o     => ddr2clk_2x,
    ddr2clk_2x_180_o => ddr2clk_2x_180,
    mcb_drp_clk_o    => mcb_drp_clk,
    pll_ce_0_o       => pll_ce_0,
    pll_ce_90_o      => pll_ce_90,
    pll_lock         => pll_lock,
    async_rst        => async_rst,
    clk10mhz         => clk10mhz
    );

----------------------------------------------------------------------------------
-- video timing controller
-- generates horizontal and vertical sync and video data enable signals.
----------------------------------------------------------------------------------
  inst_videotimingctl : entity digilent.videotimingctl port map (
    pclk_i => pclk,
    rsel_i => r640_480p,                --this project supports only vga
    rst_i  => vtcrst,
    vde_o  => vtcvde,
    hs_o   => vtchs,
    vs_o   => vtcvs,
    hcnt_o => vtchcnt,
    vcnt_o => vtcvcnt
    );
  vtcrst <= async_rst or not fbrdy;
----------------------------------------------------------------------------------
-- frame buffer
----------------------------------------------------------------------------------
  inst_fbctl : entity work.fbctl
    generic map (
      debug_en   => 0,
      colordepth => 16
      )
    port map(
      rdy_o   => fbrdy,
      enc     => fbrden,
      rstc_i  => fbrdrst,
      doc     => fbrddata,
      clkc    => fbrdclk,
      rd_mode => sw_i,

      encam_a  => dec_de,
      rstcam_a => fbwrarst,
      dcam_a   => dec_red(7 downto 3) & dec_green(7 downto 2) & dec_blue(7 downto 3),
      clkcam_a => dec_pclk,

      clk24 => camclk,

      ddr2clk_2x       => ddr2clk_2x,
      ddr2clk_2x_180   => ddr2clk_2x_180,
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

      cfg_unsync => cfg,
      inspect    => inspect_unsync,
      led_o      => led_o_t,
      usb_fifo   => usb_fifo,
      stallo     => stallo,
      d          => d,
      clk10mhz   => clk10mhz
      );

  fbrden  <= vtcvde;
  fbrdrst <= async_rst;
  fbrdclk <= pclk;

  process (dec_pclk)
  begin  -- process
    if dec_pclk'event and dec_pclk = '1' then     -- rising clock edge
      old_dec_vsync <= dec_vsync;
      dec_vsync_event <= '0';      
      if old_dec_vsync = '0' and dec_vsync = '1' then
        dec_vsync_event <= '1';
      end if;
    end if;
  end process;
  
  fbwrarst <= async_rst or dec_vsync_event;

----------------------------------------------------------------------------------
-- dvi transmitter
----------------------------------------------------------------------------------
  inst_dvitransmitter : entity digilent.dvitransmitter port map(
    red_i         => fbrddata(15 downto 11) & "000",
    green_i       => fbrddata(10 downto 5) & "00",
    blue_i        => fbrddata(4 downto 0) & "000",
    hs_i          => vtchs,
    vs_i          => vtcvs,
    vde_i         => vtcvde,
    pclk_i        => pclk,
    pclk_x2_i     => pclkx2,
    serclk_i      => serclk,
    serstb_i      => serstb,
    tmds_tx_2_p   => tmds_tx_2_p,
    tmds_tx_2_n   => tmds_tx_2_n,
    tmds_tx_1_p   => tmds_tx_1_p,
    tmds_tx_1_n   => tmds_tx_1_n,
    tmds_tx_0_p   => tmds_tx_0_p,
    tmds_tx_0_n   => tmds_tx_0_n,
    tmds_tx_clk_p => tmds_tx_clk_p,
    tmds_tx_clk_n => tmds_tx_clk_n
    );

----------------------------------------------------------------------------------
-- camera a controller
----------------------------------------------------------------------------------

  my_dvi_decoder : entity work.dvi_decoder
    port map (
      tmdsclk_p => tmdsclk_p,           -- [in]
      tmdsclk_n => tmdsclk_n,           -- [in]
      blue_p    => blue_p,              -- [in]
      green_p   => green_p,             -- [in]
      red_p     => red_p,               -- [in]
      blue_n    => blue_n,              -- [in]
      green_n   => green_n,             -- [in]
      red_n     => red_n,               -- [in]
      exrst     => '0',               -- [in]
      reset     => dec_rx_reset,            -- [out]
      pclk      => dec_pclk,                -- [out]
      myclk     => open,
      pclkx2    => dec_pclkx2,              -- [out]
      pclkx10   => dec_pclkx10,             -- [out]
      pllclk0   => dec_pllclk0,             -- [out]
      pllclk1   => dec_pllclk1,             -- [out]
      pllclk2   => dec_pllclk2,  -- [out]                                              --
      pll_lckd  => dec_plllckd,            --      
      hsync     => dec_hsync,               -- [out]
      vsync     => dec_vsync,               -- [out]
      de        => dec_de,                  -- [out]
      psalgnerr => open,
      red       => dec_red,                 -- [out]
      green     => dec_green,               -- [out]
      blue      => dec_blue);               -- [out]

  rd <= '0';

--  my_fx2: entity work.fx2 port map (CLK_IN1  => fx2clk_in,CLK_OUT1 => fx2clk_int);  
  ibufg_inst : ibufg generic map (iostandard => "default")port map (o => fx2clk_int, i => fx2clk_in);
--  fx2clk_in <= fx2clk_int;
-------------------------------------------------------------------------------
-- fpga link
-------------------------------------------------------------------------------

  my_inspect_sync : entity work.inspect_sync
    port map (
      clk  => fx2clk_int,               -- [in]
      din  => inspect_unsync,           -- [in]
      dout => inspect);                 -- [out] 

  usb_fifo.clk <= fx2clk_int;
  process(fx2clk_int)
  begin
    if (rising_edge(fx2clk_int)) then
      --if f2hready = '1' then
      --  if chanaddr = "0001111" then
      --    reg1 <= std_logic_vector(unsigned(reg1) + 1);
      --  end if;
      --end if;
      if h2fvalid = '1' then
        case chanaddr is
          when "1100000" =>
            adr <= to_integer(unsigned(h2fdata));
          when "1100001" =>
            cfg(adr).enable   <= h2fdata(0);
            cfg(adr).identify <= h2fdata(1);
          when "1110000" =>
            cfg(adr).p(0) <= h2fdata;
          when "1110001" =>
            cfg(adr).p(1) <= h2fdata;
            --when "1110010" =>
            --  cfg(adr).p(2) <= h2fdata;
            --when "1110011" =>
            --  cfg(adr).p(3) <= h2fdata;
            --when "1110100" =>
            --  cfg(adr).p(4) <= h2fdata;
            --when "1110101" =>
            --  cfg(adr).p(5) <= h2fdata;
            --when "1110110" =>
            --  cfg(adr).p(6) <= h2fdata;
            --when "1110111" =>
            --  cfg(adr).p(7) <= h2fdata;
          when others => null;
        end case;
      end if;
    end if;
  end process;

  fifosel     <= '1' when chanaddr = "0100000"                                      else '0';
  fifoen      <= '1' when fifosel = '1' and usb_fifo.stall = '0' and f2hready = '1' else '0';
  usb_fifo.en <= fifoen;

  process (fx2clk_int)
  begin  -- process
    if fx2clk_int'event and fx2clk_int = '1' then     -- rising clock edge

      f2hvalid <= p_f2hvalid;
      f2hdata <= p_f2hdata;
      h2fready <= p_h2fready;
    end if;
  end process;

  
  --p_f2hvalid <= '0' when fifosel = '1' and usb_fifo.stall = '1' else
  --            '1';  NOT WORKIN
  
  p_f2hvalid <= '1' when fifoen = '1' else
              '0' when fifosel = '1' and usb_fifo.stall = '1' and f2hready = '1' else
              '1' when f2hready = '1'                                            else
              '0';                      -- WORKING



  
  with chanaddr select p_f2hdata <=
    std_logic_vector(to_unsigned(adr, 8))          when "1100000",
    "000000" & cfg(adr).identify & cfg(adr).enable when "1100001",
    inspect.identity                               when "1100010",

    cfg(adr).p(0)             when "1110000",
    cfg(adr).p(1)             when "1110001",
--    cfg(adr).p(2)             when "1110010",
--    cfg(adr).p(3)             when "1110011",
--    cfg(adr).p(4)             when "1110100",
--    cfg(adr).p(5)             when "1110101",
    --cfg(adr).p(6)               when "1110110",
    --cfg(adr).p(7)               when "1110111",
    --
    usb_fifo.data(7 downto 0) when "0100000",
--    "0000000" & usb_fifo.stall   when "0100001",    
--    usb_fifo.count(7 downto 0)   when "0100010",
    x"ca"                     when others;


  
  
  led_o <= d.pr_count when sw_i(4 downto 0) = "00000" else
           d.pw_count   when sw_i(4 downto 0) = "00001" else
           d.auxr_count when sw_i(4 downto 0) = "00010" else
           d.auxw_count when sw_i(4 downto 0) = "00011" else

           d.state(7 downto 0)  when sw_i(4 downto 0) = "00100" else
           d.state(15 downto 8) when sw_i(4 downto 0) = "00101" else

           f2hready & f2hvalid & usb_fifo.stall & fifosel & stallo & h2fready & h2fvalid & "1" when sw_i(4 downto 0) = "00110" else
           std_logic_vector(to_unsigned(adr,8))                                                                                when sw_i(4 downto 0) = "00111" else

           d.off when sw_i(4 downto 0) = "01000" else

           d.dvistate when sw_i(4 downto 0) = "10000" else
           d.p3       when sw_i(4 downto 0) = "10001" else

           d.p2state when sw_i(4 downto 0) = "10010" else
           d.p2      when sw_i(4 downto 0) = "10011" else

           d.p1state when sw_i(4 downto 0) = "10100" else
           d.p1      when sw_i(4 downto 0) = "10101" else
           (others => '1');


--  d.off <= "00" & STD_LOGIC_VECTOR(disx+disy);  

-------------------------------------------------------------------------------
-- I2C
-------------------------------------------------------------------------------
  --test : entity work.i2cfifo
  --  port map (
  --    rst    => not i2c_en_a,           -- [IN]
  --    wr_clk => fx2clk_int,             -- [IN]
  --    rd_clk => fx2clk_int,             -- [IN]
  --    din    => h2fdata,                -- [IN]
  --    wr_en  => wr_en_c,                -- [IN]
  --    rd_en  => rd_en_c,                -- [IN]
  --    dout   => dout,                   -- [OUT]
  --    full   => wr_full_c,              -- [OUT]
  --    empty  => wr_empty_c);            -- [OUT]



  i2c_sel_a <= '1' when chanaddr = "0100001" else '0';
  i2c_sel_b <= '1' when chanaddr = "0100010" else '0';
--  i2c_sel_c <= '1' when chanaddr = "0100011" else '0';--

  wr_en_a <= '1' when i2c_sel_a = '1' and h2fvalid = '1' and h2fready = '1' else '0';
  wr_en_b <= '1' when i2c_sel_b = '1' and h2fvalid = '1'  and h2fready = '1' else '0';
--  wr_en_c <= '1' when i2c_sel_c = '1' and h2fvalid = '1' else '0';

--  rd_en_c <= '1' when f2hReady = '1' and i2c_sel_c = '1' else '0'; 
--

  p_h2fready <= '1';
-------------------------------------------------------------------------------
-- COMM
-------------------------------------------------------------------------------  
  comm : if fpgalink = 1 generate

    fx2read_out    <= fx2read;
    fx2oe_out      <= fx2read;
    fx2addr_out(1) <= '1';              -- use ep6out/ep8in, not ep2out/ep4in.

    comm_fpga_fx2 : entity work.comm_fpga_fx2
      port map(
        -- fx2 interface
        fx2clk_in      => fx2clk_int,
        fx2fifosel_out => fx2addr_out(0),
        fx2data_io     => fx2data_io,
        fx2read_out    => fx2read,
        fx2gotdata_in  => fx2gotdata_in,
        fx2write_out   => fx2write_out,
        fx2gotroom_in  => fx2gotroom_in,
        fx2pktend_out  => fx2pktend_out,

        -- channel read/write interface
        chanaddr_out => chanaddr,
        h2fdata_out  => h2fdata,
        h2fvalid_out => h2fvalid,
        h2fready_in  => h2fready,
        f2hdata_in   => f2hdata,
        f2hvalid_in  => f2hvalid,
        f2hready_out => f2hready,
        s            => open
        );

  end generate comm;
  comm_else : if fpgalink = 0 generate
    h2fready <= '1';
    f2hvalid <= '1';

    fx2read_out   <= '0';
    fx2oe_out     <= '0';
    fx2addr_out   <= (others => '0');
    fx2pktend_out <= '0';
    fx2write_out  <= '0';
  end generate comm_else;

end behavioral;

