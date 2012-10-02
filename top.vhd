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

    camx_vdden_o : out std_logic;  -- common power supply enable (can do power cycle)

    cama_sda    : inout std_logic;
    cama_scl    : inout std_logic;
    cama_d_i    : in    std_logic_vector (7 downto 0);
    cama_pclk_i : inout std_logic;
    cama_mclk_o : out   std_logic;
    cama_lv_i   : in    std_logic;
    cama_fv_i   : in    std_logic;
    cama_rst_o  : out   std_logic;      --reset active low
    cama_pwdn_o : out   std_logic;      --power-down active high           

    camb_sda    : inout std_logic;
    camb_scl    : inout std_logic;
    camb_d_i    : in    std_logic_vector (7 downto 0);
    camb_pclk_i : inout std_logic;
    camb_mclk_o : out   std_logic;
    camb_lv_i   : in    std_logic;
    camb_fv_i   : in    std_logic;
    camb_rst_o  : out   std_logic;      --reset active low
    camb_pwdn_o : out   std_logic;      --power-down active high           
    
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
    fx2clk_int  : in    std_logic;      -- 48mhz clock from fx2
    fx2addr_out : out   std_logic_vector(1 downto 0);  -- select fifo: "10" for ep6out, "11" for ep8in
    fx2data_io  : inout std_logic_vector(7 downto 0);  -- 8-bit data to/from fx2

    -- when ep6out selected:
    fx2read_out   : out std_logic;  -- asserted (active-low) when reading from fx2
    fx2oe_out     : out std_logic;  -- asserted (active-low) to tell fx2 to drive bus
    fx2gotdata_in : in  std_logic;  -- asserted (active-high) when fx2 has data for us

    -- when ep8in selected:
    fx2write_out  : out std_logic;  -- asserted (active-low) when writing to fx2
    fx2gotroom_in : in  std_logic;  -- asserted (active-high) when fx2 has room for more data from us
    fx2pktend_out : out std_logic  -- asserted (active-low) when a host read needs to be committed early

    );
end top;

architecture behavioral of top is
  signal sysclk, pclk, pclkx2, sysrst, serclk, serstb : std_logic;
  signal msel                                         : std_logic_vector(1 downto 0);

  signal vtchs, vtcvs, vtcvde, vtcrst : std_logic;
  signal vtchcnt, vtcvcnt             : natural;

  signal camclk, camclk_180 : std_logic;
  --
  signal camapclk, camadv, camavdden,fbwrarst, int_fva : std_logic;
  signal camad                                           : std_logic_vector(15 downto 0);
  signal dummy_t, int_cama_pclk_i                        : std_logic;
  attribute s                : string;
  attribute s of cama_pclk_i : signal is "true";
  attribute s of dummy_t     : signal is "true";
  --
  signal cambpclk, cambdv, cambvdden,fbwrbrst, int_fvb : std_logic;
  signal cambd                                           : std_logic_vector(15 downto 0);
  signal int_camb_pclk_i                        : std_logic;
  attribute s of camb_pclk_i : signal is "true";
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
  signal fx2clk_in      : std_logic;

  signal usb_fifo : pixel_fifo_t;
  signal fifosel  : std_logic;
  signal fifoen  : std_logic;  
  signal stallo : std_logic;
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
    async_rst        => async_rst
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

      encam_a   => camadv,
      rstcam_a  => fbwrarst,
      dcam_a    => camad,
      clkcam_a  => camapclk,

      encam_b   => cambdv,
      rstcam_b  => fbwrbrst,
      dcam_b    => cambd,
      clkcam_b  => cambpclk,
      
      clk24   => camclk,

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
      stallo => stallo
      );

  fbrden  <= vtcvde;
  fbrdrst <= async_rst;
  fbrdclk <= pclk;
  
  inst_inputsync_fva : entity digilent.inputsync port map(
    d_i   => cama_fv_i,
    d_o   => int_fva,
    clk_i => camapclk
    );
  fbwrarst <= async_rst or not int_fva;

  inst_inputsync_fvb : entity digilent.inputsync port map(
    d_i   => camb_fv_i,
    d_o   => int_fvb,
    clk_i => cambpclk
    );
  fbwrbrst <= async_rst or not int_fvb;
  
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
  inst_camctla : entity work.camctl
    port map (
      d_o     => camad,
      pclk_o  => camapclk,
      dv_o    => camadv,
      rst_i   => async_rst,
      clk     => camclk,
      clk_180 => camclk_180,
      sda     => cama_sda,
      scl     => cama_scl,
      d_i     => cama_d_i,
      pclk_i  => int_cama_pclk_i,
      mclk_o  => cama_mclk_o,
      lv_i    => cama_lv_i,
      fv_i    => cama_fv_i,
      rst_o   => cama_rst_o,
      pwdn_o  => cama_pwdn_o,
      vdden_o => camavdden
      );
  camx_vdden_o <= camavdden;
----------------------------------------------------------------------------------
-- camera b controller
----------------------------------------------------------------------------------
  inst_camctlb : entity work.camctl
    port map (
      d_o     => cambd,
      pclk_o  => cambpclk,
      dv_o    => cambdv,
      rst_i   => async_rst,
      clk     => camclk,
      clk_180 => camclk_180,
      sda     => camb_sda,
      scl     => camb_scl,
      d_i     => camb_d_i,
      pclk_i  => int_camb_pclk_i,
      mclk_o  => camb_mclk_o,
      lv_i    => camb_lv_i,
      fv_i    => camb_fv_i,
      rst_o   => camb_rst_o,
      pwdn_o  => camb_pwdn_o,
      vdden_o => cambvdden
      );

  
----------------------------------------------------------------------------------
-- workaround for in_term bug ar#   40818
----------------------------------------------------------------------------------
  inst_iobuf_cama_pclk : iobuf
    generic map (
      drive      => 12,
      iostandard => "default",
      slew       => "slow")
    port map (
      o  => int_cama_pclk_i,            -- buffer output
      io => cama_pclk_i,  -- buffer inout port (connect directly to top-level port)
      i  => '0',                        -- buffer input
      t  => dummy_t       -- 3-state enable input, high=input, low=output 
      ); 
  inst_iobuf_camb_pclk : iobuf
    generic map (
      drive      => 12,
      iostandard => "default",
      slew       => "slow")
    port map (
      o  => int_camb_pclk_i,            -- buffer output
      io => camb_pclk_i,  -- buffer inout port (connect directly to top-level port)
      i  => '0',                        -- buffer input
      t  => dummy_t       -- 3-state enable input, high=input, low=output 
      ); 

  dummy_t <= '1';

  rd <= '0';

  ibufg_inst : ibufg generic map (iostandard => "default")port map (o => fx2clk_in, i => fx2clk_int);
--  fx2clk_in <= fx2clk_in;
-------------------------------------------------------------------------------
-- fpga link
-------------------------------------------------------------------------------

  my_inspect_sync : entity work.inspect_sync
    port map (
      clk  => fx2clk_in,                -- [in]
      din  => inspect_unsync,           -- [in]
      dout => inspect);                 -- [out] 

  usb_fifo.clk <= fx2clk_in;
  process(fx2clk_in)
  begin
    if (rising_edge(fx2clk_in)) then
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
          when "1110010" =>
            cfg(adr).p(2) <= h2fdata;
          when "1110011" =>
            cfg(adr).p(3) <= h2fdata;
          when "1110100" =>
            cfg(adr).p(4) <= h2fdata;
          when "1110101" =>
            cfg(adr).p(5) <= h2fdata;
            --when "1110110" =>
            --  cfg(adr).p(6) <= h2fdata;
            --when "1110111" =>
            --  cfg(adr).p(7) <= h2fdata;
          when others => null;
        end case;
      end if;
    end if;
  end process;

  fifosel <= '1' when chanaddr = "0100000" else '0';
  fifoen <= '1' when fifosel = '1' and usb_fifo.stall = '0' and f2hready = '1' else '0';
  usb_fifo.en <= fifoen;

  f2hvalid <= '1' when fifoen = '1' else
              '0' when fifosel = '1' and usb_fifo.stall = '1' and f2hready = '1' else
              '1' when f2hready = '1'                                           else
              '0';
 
  led_o <= f2hready & f2hvalid & usb_fifo.stall & fifosel & stallo & h2fready & h2fvalid & "1" when sw_i(1 downto 0) = "00" else  std_logic_vector(to_unsigned(adr, 8));

  with chanaddr select f2hdata <=
    std_logic_vector(to_unsigned(adr, 8))          when "1100000",
    "000000" & cfg(adr).identify & cfg(adr).enable when "1100001",
    inspect.identity                               when "1100010",

    cfg(adr).p(0)                when "1110000",
    cfg(adr).p(1)                when "1110001",
    cfg(adr).p(2)                when "1110010",
    cfg(adr).p(3)                when "1110011",
    cfg(adr).p(4)                when "1110100",
    cfg(adr).p(5)                when "1110101",
    --cfg(adr).p(6)               when "1110110",
    --cfg(adr).p(7)               when "1110111",
    --
    usb_fifo.data(7 downto 0)    when "0100000",
--    "0000000" & usb_fifo.stall   when "0100001",    
--    usb_fifo.count(7 downto 0)   when "0100010",
    x"aa" when others;

  comm : if fpgalink = 1 generate
    h2fready <= '1';

    fx2read_out    <= fx2read;
    fx2oe_out      <= fx2read;
    fx2addr_out(1) <= '1';              -- use ep6out/ep8in, not ep2out/ep4in.

    comm_fpga_fx2 : entity work.comm_fpga_fx2
      port map(
        -- fx2 interface
        fx2clk_in      => fx2clk_in,
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
        f2hready_out => f2hready
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

