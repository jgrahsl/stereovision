library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.read;
use std.textio.write;
use std.textio.writeline;
use std.textio.text;
use std.textio.line;
use std.textio.readline;
use work.txt_util.all;

use work.cam_pkg.all;
use work.sim_pkg.all;

entity tb is
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

  signal stall : std_logic_vector(MAX_PIPE-1 downto 0);

  signal finish : std_logic := '0';
begin  -- impl

  ena : for i in 0 to (MAX_PIPE-1) generate
    cfg(i).enable   <= '1';
    cfg(i).identify <= '0';
  end generate ena;

  cfg(4+2).p(0)    <= std_logic_vector(to_unsigned(THRESH, 8));
  cfg(4+5+2).p(0)  <= std_logic_vector(to_unsigned(THRESH, 8));
  cfg(4+10+2).p(0) <= std_logic_vector(to_unsigned(THRESH, 8));
  cfg(4+15+2).p(0) <= std_logic_vector(to_unsigned(THRESH, 8));

  stall(8) <= '0';

  my_pipe_head : entity work.pipe_head
    generic map (
      ID => 0)
    port map (
      clk      => clk,                  -- [in]
      rst      => rst,                  -- [in]
      cfg      => cfg,                  -- [in]
      pipe_out => pipe(0));             -- [out]

  my_sim_feed : entity work.sim_feed
    generic map (
      ID => 1)
    port map (
      pipe_in   => pipe(0),             -- [in]
      pipe_out  => pipe(1),
      stall_in  => stall(1),
      stall_out => stall(0),
      p0_fifo   => p0_rd_fifo);         -- [inout]

  nu : entity work.null_filter
    generic map (
      ID     => 25,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      pipe_in   => pipe(1),             -- [in]
      pipe_out  => pipe(2),
      stall_in  => stall(2),
      stall_out => stall(1));           -- [inout]

  dut : entity work.morph_set
    generic map (
      ID     => 2,
      KERNEL => KERNEL,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      pipe_in   => pipe(2),             -- [in]
      pipe_out  => pipe(3),
      stall_in  => stall(3),
      stall_out => stall(2)
      );                                -- [out]

  colmux : entity work.color_mux
    generic map (
      ID   => 23,
      MODE => 1)
    port map (
      pipe_in   => pipe(3),             -- [in]
      pipe_out  => pipe(4),
      stall_in  => stall(4),
      stall_out => stall(3));           -- [inout]

  my_sim_sink : entity work.sim_sink
    generic map (
      ID => 22)
    port map (
      pipe_in   => pipe(4),             -- [in]
      pipe_out  => pipe(8),
      stall_in  => stall(8),
      stall_out => stall(4),
      p0_fifo   => p0_wr_fifo);         -- [inout]

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

    write(l, str(WIDTH, 10));
    writeline(f, l);
    write(l, str(HEIGHT, 10));
    writeline(f, l);
    for m in SKIP-1 downto 0 loop
      for j in (HEIGHT-1) downto 0 loop
        for i in (WIDTH-1) downto 0 loop
          wait until p0_wr_fifo.clk = '0' and p0_wr_fifo.en = '1';
          b := p0_wr_fifo.data;
--        write(l, str(b));
--        writeline(f, l);
          wait until p0_wr_fifo.clk = '1';
        end loop;
      end loop;  -- j      
    end loop;  -- m

    for j in (HEIGHT-1) downto 0 loop
      for i in (WIDTH-1) downto 0 loop
        wait until p0_wr_fifo.clk = '0' and p0_wr_fifo.en = '1';
        b := p0_wr_fifo.data;
        write(l, str(b));
        writeline(f, l);
        wait until p0_wr_fifo.clk = '1';
      end loop;
    end loop;  -- j
    wait for 5 us;
    report "Done" severity note;
    finish <= '1';
    wait;
  end process;
  
end impl;


