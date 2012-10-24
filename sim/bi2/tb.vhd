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

  signal pipe_in    : pipe_t;
  signal pipe_out   : pipe_t;
  signal pipe       : pipe_set_t;
  signal stall      : std_logic_vector(MAX_PIPE-1 downto 0);
  signal cfg        : cfg_set_t;
  signal p0_rd_fifo : sim_fifo_t;
  signal p0_wr_fifo : sim_fifo_t;

  signal finish : std_logic := '0';

  signal abcd_1     : abcd_t;
  signal abcd_2     : abcd_t;
  signal abcd_3     : abcd_t;
  signal abcd_4     : abcd_t;
  signal abcd2      : abcd2_t;
  signal gray8_2d_1 : gray8_2d_t;
  signal gray8_2d_2 : gray8_2d_t;
  signal gray8_2d_3 : gray8_2d_t;
  signal gray8_2d_4 : gray8_2d_t;
  signal ox_1       : signed((ABCD_BITS/2)+SUBGRID_BITS-1 downto 0);
  signal ox_2       : signed((ABCD_BITS/2)+SUBGRID_BITS-1 downto 0);
  signal oy         : signed((ABCD_BITS/2)+SUBGRID_BITS-1 downto 0);

  constant KERNEL : natural := 7;  
  constant HALF_KERNEL : natural := (KERNEL-1)/2;
  constant T_W         : natural := HALF_KERNEL;
  constant T_H         : natural := HALF_KERNEL;
  signal gray8_1d      : gray8_1d_t;

begin  -- impl

  ena : for i in 0 to (MAX_PIPE-1) generate
    cfg(i).enable   <= '1';
    cfg(i).identify <= '0';
  end generate ena;

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


  my_translate : entity work.translate
    generic map (
      ID       => (10),
      WIDTH    => WIDTH,
      HEIGHT   => HEIGHT,
      CUT_W    => 0,
      CUT_H    => 0,
      APPEND_W => T_W,
      APPEND_H => T_H
      )
    port map (
      pipe_in   => pipe(1),             -- [in]
      pipe_out  => pipe(2),
      stall_in  => stall(2),
      stall_out => stall(1)
      );                                -- [out]

  my_filter0_buffer : entity work.line_buffer_gray8
    generic map (
      ID        => (11),
      NUM_LINES => KERNEL,
      HEIGHT    => HEIGHT+T_H,
      WIDTH     => WIDTH+T_W)
    port map (
      pipe_in      => pipe(2),
      pipe_out_1   => pipe(3),
      pipe_out_2   => pipe(6),
      stall_in_1   => stall(3),
      stall_in_2   => stall(6),
      stall_out    => stall(2),
      gray8_1d_out => gray8_1d
      );

  my_filter0_window : entity work.window_gray8
    generic map (
      ID       => (12),
      NUM_COLS => KERNEL,
      HEIGHT   => HEIGHT+T_H,
      WIDTH    => WIDTH+T_W)
    port map (
      pipe_in      => pipe(3),
      pipe_out   => pipe(4),
      stall_in   => stall(4),
      stall_out    => stall(3),
      gray8_1d_in  => gray8_1d,
      gray8_2d_out => gray8_2d_1
      );

  my_translatea : entity work.translate_win_gray8
    generic map (
      ID       => (13),
      WIDTH    => WIDTH+T_W,
      HEIGHT   => HEIGHT+T_H,
      CUT_W    => T_W,
      CUT_H    => T_H,
      APPEND_W => 0,
      APPEND_H => 0)      
    port map (
      pipe_in      => pipe(4),          -- [in]
      pipe_out     => pipe(5),
      stall_in     => stall(5),
      stall_out    => stall(4),
      gray8_2d_in  => gray8_2d_1,
      gray8_2d_out => gray8_2d_2
      );                                -- [out]

  bitest : entity work.bi
    generic map (
      ID     => 15,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      pipe_in    => pipe(6),          -- [in]
      pipe_out     => pipe(7),
      stall_in     => stall(7),
      stall_out     => stall(6),      
      abcd         => abcd_1
      );                                -- [inout]

  inst_bi2_c : entity work.bi2
    generic map (
      ID     => 16,
      KERNEL => KERNEL,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      pipe_in_1    => pipe(5),          -- [in]
      pipe_in_2    => pipe(7),          -- [in]      
      pipe_out    => pipe(8),           -- [out]
      stall_in    => stall(8),          -- [in]
      stall_out_1  => stall(5),
      stall_out_2  => stall(7),
      abcd        => abcd_1,
      gray8_2d_in => gray8_2d_2,
      abcd2       => abcd2);            -- [out]         

  bitest3 : entity work.bi3
    generic map (
      ID     => 17,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      pipe_in   => pipe(8),             -- [in]
      pipe_out  => pipe(9),
      stall_in  => stall(9),
      stall_out => stall(8),
      abcd2     => abcd2
      );                                -- [inout]

  --dut2 : entity work.win_test_gray8
  --  generic map (
  --    ID     => 26,
  --    KERNEL => KERNEL,
  --    OFFSET =>  (12))
  --  port map (
  --    pipe_in_1    => pipe(6),          -- [in]
  --    pipe_in_2    => pipe(7),          -- [in]      
  --    pipe_out    => pipe(8),           -- [out]
  --    stall_in    => stall(8),          -- [in]
  --    stall_out_1  => stall(6),
  --    stall_out_2  => stall(7),
  --    gray8_2d_in => gray8_2d_2
  --    );                                -- [inout]
  
  colmux : entity work.color_mux
    generic map (
      ID   => 3,
      MODE => 2)      
    port map (
      pipe_in   => pipe(9),             -- [in]
      pipe_out  => pipe(10),
      stall_in  => stall(10),
      stall_out => stall(9));           -- [inout]

  my_sim_sink : entity work.sim_sink
    generic map (
      ID => 2)
    port map (
      pipe_in   => pipe(10),             -- [in]
      pipe_out  => pipe(11),
      stall_in  => '0',
      stall_out => stall(10),
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

    if SKIP > 0 then
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
    end if;

    for j in (HEIGHT-1) downto 0 loop
      for i in (WIDTH-1) downto 0 loop
        wait until p0_wr_fifo.clk = '0' and p0_wr_fifo.en = '1';
        b := p0_wr_fifo.data;
        write(l, str(b));
        writeline(f, l);
        wait until p0_wr_fifo.clk = '1';
      end loop;
    end loop;  -- j
    report "Done" severity note;
    finish <= '1';
    wait;
  end process;
  
end impl;


