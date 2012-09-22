library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use work.txt_util.all;

use work.cam_pkg.all;

entity tb is
  generic (
    KERNEL : natural range 0 to 5    := 5;
    WIDTH  : natural range 0 to 2048 := 16;
    HEIGHT : natural range 0 to 2048 := 16;
    NUM    : natural range 0 to 4    := 4
    );
end tb;

architecture impl of tb is
  
  signal clk : std_logic;
  signal rst : std_logic;

  signal col : natural range 0 to 2048 := 0;
  signal row : natural range 0 to 2048 := 0;

  signal ce_count : unsigned(4 downto 0);
  signal ce       : std_logic;

  signal go : std_logic;

  subtype pixel_t is std_logic_vector(0 downto 0);
  type    mem_t is array (0 to (2*HEIGHT*WIDTH-1)) of pixel_t;

  signal mem : mem_t;

  signal pipe_in  : pipe_t;
  signal pipe_out : pipe_t;
  signal pipe     : pipe_set_t;
  signal cfg      : cfg_set_t;

  signal mono_1d : mono_1d_t;
  signal mono_2d : mono_2d_t;

  signal pr_fifo   : mcb_fifo_t;
  signal pw_fifo   : mcb_fifo_t;
  signal auxr_fifo : mcb_fifo_t;
  signal auxw_fifo : mcb_fifo_t;

  signal pr_clk   : std_logic;
  signal pr_rst   : std_logic;
  signal pr_in    : std_logic_vector(31 downto 0);
  signal pr_out   : std_logic_vector(31 downto 0);
  signal pr_rd    : std_logic;
  signal pr_wr    : std_logic;
  signal pr_empty : std_logic;
  signal pr_full  : std_logic;
  signal pr_count : std_logic_vector(4 downto 0);

  signal pw_clk   : std_logic;
  signal pw_rst   : std_logic;
  signal pw_in    : std_logic_vector(31 downto 0);
  signal pw_out   : std_logic_vector(31 downto 0);
  signal pw_rd    : std_logic;
  signal pw_wr    : std_logic;
  signal pw_empty : std_logic;
  signal pw_full  : std_logic;
  signal pw_count : std_logic_vector(4 downto 0);

  signal auxr_clk   : std_logic;
  signal auxr_rst   : std_logic;
  signal auxr_in    : std_logic_vector(31 downto 0);
  signal auxr_out   : std_logic_vector(31 downto 0);
  signal auxr_rd    : std_logic;
  signal auxr_wr    : std_logic;
  signal auxr_empty : std_logic;
  signal auxr_full  : std_logic;
  signal auxr_count : std_logic_vector(5 downto 0);

  signal auxw_clk   : std_logic;
  signal auxw_rst   : std_logic;
  signal auxw_in    : std_logic_vector(31 downto 0);
  signal auxw_out   : std_logic_vector(31 downto 0);
  signal auxw_rd    : std_logic;
  signal auxw_wr    : std_logic;
  signal auxw_empty : std_logic;
  signal auxw_full  : std_logic;
  signal auxw_count : std_logic_vector(5 downto 0);

begin  -- impl
-------------------------------------------------------------------------------
-- READ
-------------------------------------------------------------------------------
  pr_rst        <= rst;
  pr_clk        <= pr_fifo.clk;
  pr_rd         <= pr_fifo.en;
  pr_fifo.stall <= pr_empty;
  pr_fifo.data  <= pr_out;

  auxr_rst        <= rst;
  auxr_clk        <= auxr_fifo.clk;
  auxr_rd         <= auxr_fifo.en;
  auxr_fifo.stall <= auxr_empty;
  auxr_fifo.data  <= auxr_out;

  pr_in   <= indata;
  auxr_in <= indata;
--
  pr_wr    <= '0';
  auxr_wr  <= '0';
  
  process
  begin  -- process
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
  end process;
  
  
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
--
  pw_rd    <= '0';
  auxw_rd  <= '0';
  
  
  ena : for i in 0 to 31 generate
    cfg(i).enable <= '1';
  end generate ena;

  cfg(3+4).p(0)  <= std_logic_vector(to_unsigned(10, 8));
  cfg(8+4).p(0)  <= std_logic_vector(to_unsigned(10, 8));
  cfg(13+4).p(0) <= std_logic_vector(to_unsigned(10, 8));
  cfg(18+4).p(0) <= std_logic_vector(to_unsigned(10, 8));

  pr_fifo_comp : entity work.mcb_pixel_fifo
    port map (
      clk        => pr_clk,             -- [IN]
      rst        => pr_rst,             -- [IN]
      din        => pr_in,              -- [IN]
      wr_en      => pr_wr,              -- [IN]
      rd_en      => pr_rd,              -- [IN]
      dout       => pr_out,
      full       => pr_full,            -- [OUT]
      empty      => pr_empty,
      data_count => pr_count
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
      data_count => pw_count
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
      data_count => auxr_count
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
      data_count => auxw_count
      );                                -- [OUT]

  
  my_pipe_head : entity work.pipe_head
    generic map (
      ID => 0)
    port map (
      clk       => clkalg,              -- [in]
      rst       => rstalg,              -- [in]
      cfg       => cfg,                 -- [in]
      pipe_tail => pipe(8),
      pipe_out  => pipe(0));            -- [out]

  my_mcb_feed : entity work.mcb_feed
    generic map (
      ID => 1)
    port map (
      pipe_in  => pipe(0),              -- [in]
      pipe_out => pipe(1),              -- [out]
      p0_fifo  => pr_fifo,              -- [inout]
      p1_fifo  => auxr_fifo);           -- [inout]

  my_mcb_sink : entity work.mcb_sink
    generic map (
      ID => 27)
    port map (
      pipe_in  => pipe(1),              -- [in]
      pipe_out => pipe(8),              -- [out]
      p0_fifo  => pw_fifo,              -- [inout]
      p1_fifo  => auxw_fifo);           -- [inout]

  
-------------------------------------------------------------------------------  
-- Clock and Rst
-------------------------------------------------------------------------------
  process
  begin  -- process
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
  end process;

  process
  begin  -- process
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    wait;
  end process;

  --  print(hstr(rd_data));

  --process
  --  constant stim_file : string  := "sim.dat";
  --  file f             : text open read_mode is stim_file;
  --  variable l         : line;
  --  variable s         : string(1 to (24+16+8+1));
  --  variable c         : integer := 0;
  --  variable b         : std_logic_vector((24+16+8+1)-1 downto 0);
  --begin
  --  p0_rd_fifo.stall <= '0';
  --  while not endfile(f) loop
  --    readline(f, l);
  --    read(l, s);                                 --ok
  --    b               := to_std_logic_vector(s);  --ok
  --    p0_rd_fifo.data <= b;
  --    wait until p0_rd_fifo.clk = '0' and p0_rd_fifo.en = '1';
  --    wait until p0_rd_fifo.clk = '1';
  --  end loop;
  --  p0_rd_fifo.stall <= '1';
  --  wait;
  --end process;

  --process
  --  constant stim_file : string  := "sim.out";
  --  file f             : text open write_mode is stim_file;
  --  variable s         : string(1 to (24+16+8+1));
  --  variable c         : integer := 0;
  --  variable b         : std_logic_vector((24+16+8+1)-1 downto 0);
  --  variable p         : integer := 0;
  --  variable l         : line;
  --begin
  --  p0_wr_fifo.stall <= '0';
  --  for j in (HEIGHT-1) downto 0 loop
  --    for i in (WIDTH-1) downto 0 loop
  --      wait until p0_wr_fifo.clk = '0' and p0_wr_fifo.en = '1';
  --      b := p0_wr_fifo.data;
  --      write(l, str(b));
  --      writeline(f, l);
  --      wait until p0_wr_fifo.clk = '1';
  --    end loop;
  --  end loop;  -- j
  --end process;
  
end impl;


