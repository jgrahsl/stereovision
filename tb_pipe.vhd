library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use work.txt_util.all;

use work.cam_pkg.all;

entity tb is
  generic (
    KERNEL  : natural range 0 to 5    := 5;
    WIDTH   : natural range 0 to 2048 := 16;
    HEIGHT  : natural range 0 to 2048 := 16;
    NUM     : natural range 0 to 4    := 4
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

  signal p0_rd_fifo : sim_fifo_t;
  signal p0_wr_fifo : sim_fifo_t;

  signal mono_1d : mono_1d_t;
  signal mono_2d : mono_2d_t;  
begin  -- impl

  cfg(0).enable <= '1';
  cfg(1).enable <= '1';
  cfg(2).enable <= '1';
  cfg(3).enable <= '1';
  cfg(4).enable <= '1';
  cfg(5).enable <= '1';
  cfg(6).enable <= '1';
  cfg(7).enable <= '1';
  
  
  my_pipe_head : entity work.pipe_head
    generic map (
      ID => 0)
    port map (
      clk       => clk,                 -- [in]
      rst       => rst,                 -- [in]
      cfg       => cfg,                 -- [in]
      pipe_tail => pipe(7),
      pipe_out  => pipe(0));            -- [out]

  my_sim_feed : entity work.sim_feed
    generic map (
      ID => 1)
    port map (
      pipe_in  => pipe(0),              -- [in]
      pipe_out => pipe(1),              -- [out]
      p0_fifo  => p0_rd_fifo);          -- [inout]

  my_translate : entity work.translate
    generic map (
      ID     => 2,
      WIDTH  => 16,
      HEIGHT => 16,
      PRE_COUNT => 0,
      POST_COUNT => 32)
    port map (
      pipe_in  => pipe(1),              -- [in]
      pipe_out => pipe(2));             -- [out]

  my_filter0_buffer : entity work.line_buffer
    generic map (
      ID        => 3,
      NUM_LINES => KERNEL,
      HEIGHT    => HEIGHT+2,
      WIDTH     => WIDTH)
    port map (
      pipe_in     => pipe(2),
      pipe_out    => pipe(3),
      mono_1d_out => mono_1d
      );

  my_filter0_window : entity work.window
    generic map (
      ID       => 4,
      NUM_COLS => KERNEL,
      HEIGHT   => HEIGHT+2,
      WIDTH    => WIDTH)
    port map (
      pipe_in     => pipe(3),
      pipe_out    => pipe(4),
      mono_1d_in  => mono_1d,
      mono_2d_out => mono_2d
      );
 
  my_filter0_kernel : entity work.win_test
    generic map (
      ID     => 5,
      KERNEL => KERNEL)
    port map (
      pipe_in    => pipe(4),
      pipe_out   => pipe(5),
      mono_2d_in => mono_2d
      );

  my_translatea : entity work.translate
    generic map (
      ID     => 6,
      WIDTH  => 16,
      HEIGHT => 16,
      PRE_COUNT => 32,
      POST_COUNT => 0)
    port map (
      pipe_in  => pipe(5),              -- [in]
      pipe_out => pipe(6));             -- [out]
  
  my_sim_sink : entity work.sim_sink
    generic map (
      ID => 7)
    port map (
      pipe_in  => pipe(2),              -- [in]
      pipe_out => pipe(7),              -- [out]
      p0_fifo  => p0_wr_fifo);          -- [inout]

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

  process
    constant stim_file : string  := "sim.dat";
    file f             : text open read_mode is stim_file;
    variable l         : line;
    variable s         : string(1 to (24+16+8+1));
    variable c         : integer := 0;
    variable b         : std_logic_vector((24+16+8+1)-1 downto 0);
  begin
    p0_rd_fifo.stall <= '0';
    while not endfile(f) loop
      readline(f, l);
      read(l, s);                                 --ok
      b               := to_std_logic_vector(s);  --ok
      p0_rd_fifo.data <= b;
      wait until p0_rd_fifo.clk = '0' and p0_rd_fifo.en = '1';
      wait until p0_rd_fifo.clk = '1';
    end loop;
    p0_rd_fifo.stall <= '1';
    wait;
  end process;

  process
    constant stim_file : string  := "sim.out";
    file f             : text open write_mode is stim_file;
    variable s         : string(1 to (24+16+8+1));    
    variable c         : integer := 0;
    variable b         : std_logic_vector((24+16+8+1)-1 downto 0);
    variable p         : integer := 0;
    variable l         : line;
  begin
    p0_wr_fifo.stall <= '0';
    for j in (HEIGHT-1) downto 0 loop
      for i in (WIDTH-1) downto 0 loop
        wait until p0_wr_fifo.clk = '0' and p0_wr_fifo.en = '1';
        b := p0_wr_fifo.data;
        write(l, str(b));
        writeline(f, l);
        wait until p0_wr_fifo.clk = '1';
      end loop;
    end loop;  -- j

    for j in (HEIGHT-1) downto 0 loop
      for i in (WIDTH-1) downto 0 loop
        wait until p0_wr_fifo.clk = '0' and p0_wr_fifo.en = '1';
        b := p0_wr_fifo.data;
        write(l, str(b));
        writeline(f, l);
        wait until p0_wr_fifo.clk = '1';
      end loop;
    end loop;  -- j
    
    --for j in (HEIGHT-1) downto 0 loop
    --  for i in (WIDTH-1) downto 0 loop
    --    wait until p0_wr_fifo.clk = '0' and p0_wr_fifo.en = '1';
    --    b := p0_wr_fifo.data;
    --    write(l, str(b));
    --    writeline(f, l);
    --    wait until p0_wr_fifo.clk = '1';
    --  end loop;
    --end loop;  -- j

    wait;
  end process;
  
end impl;


