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



  dut : entity work.win_gray8
    generic map (
      ID     => 4,
      KERNEL => 7,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      pipe_in      => pipe(1),          -- [in]
      pipe_out     => pipe(2),
      stall_in     => stall(2),
      stall_out    => stall(1),
      gray8_2d_out => gray8_2d_1
      );                                -- [inout]

  bitest : entity work.bi
    generic map (
      ID     => 25,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      pipe_in      => pipe(2),          -- [in]
      pipe_out     => pipe(3),
      stall_in     => stall(3),
      stall_out    => stall(2),
      abcd         => abcd_1,
      gray8_2d_in  => gray8_2d_1,
      gray8_2d_out => gray8_2d_2
      );                                -- [inout]
-------------------------------------------------------------------------------
  gen : if SPLIT = 0 generate
    bitest2 : entity work.bi2
      generic map (
        ID     => 26,
        WIDTH  => WIDTH,
        HEIGHT => HEIGHT)
      port map (
        pipe_in     => pipe(3),         -- [in]
        pipe_out    => pipe(6),
        stall_in    => stall(6),
        stall_out   => stall(3),
        abcd        => abcd_1,
        gray8_2d_in => gray8_2d_2,
        abcd2       => abcd2
        );                              -- [inout]
  end generate gen;
-------------------------------------------------------------------------------
  gen2 : if SPLIT = 1 generate
    bitest2_x : entity work.bi2_x
      generic map (
        ID     => 26,
        WIDTH  => WIDTH,
        HEIGHT => HEIGHT)
      port map (
        pipe_in      => pipe(3),        -- [in]
        pipe_out     => pipe(4),
        stall_in     => stall(4),
        stall_out    => stall(3),
        abcd_in      => abcd_1,
        abcd_out     => abcd_2,
        gray8_2d_in  => gray8_2d_2,
        gray8_2d_out => gray8_2d_3,
        ox_out       => ox_1
        );
    bitest2_y : entity work.bi2_y
      generic map (
        ID     => 27,
        WIDTH  => WIDTH,
        HEIGHT => HEIGHT)
      port map (
        pipe_in      => pipe(4),        -- [in]
        pipe_out     => pipe(5),
        stall_in     => stall(5),
        stall_out    => stall(4),
        abcd_in      => abcd_2,
        abcd_out     => abcd_3,
        gray8_2d_in  => gray8_2d_3,
        gray8_2d_out => gray8_2d_4,
        ox_in        => ox_1,
        ox_out       => ox_2,
        oy_out       => oy
        );
    my_bi2_c : entity work.bi2_c
      generic map (
        ID     => 28,
        KERNEL => 7,        
        WIDTH  => WIDTH,
        HEIGHT => HEIGHT)
      port map (
        pipe_in     => pipe(5),         -- [in]
        pipe_out    => pipe(6),         -- [out]
        stall_in    => stall(6),        -- [in]
        stall_out   => stall(5),        -- [out]
        gray8_2d_in => gray8_2d_4,
        ox          => ox_2,            -- [in]
        oy          => oy,              -- [in]
        abcd2       => abcd2);          -- [out]       
  end generate gen2;
-------------------------------------------------------------------------------
  bitest3 : entity work.bi3
    generic map (
      ID     => 29,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      pipe_in   => pipe(6),             -- [in]
      pipe_out  => pipe(7),
      stall_in  => stall(7),
      stall_out => stall(6),
      abcd2     => abcd2
      );                                -- [inout]


  colmux : entity work.color_mux
    generic map (
      ID   => 3,
      MODE => 2)      
    port map (
      pipe_in   => pipe(7),             -- [in]
      pipe_out  => pipe(8),
      stall_in  => stall(8),
      stall_out => stall(7));           -- [inout]

  my_sim_sink : entity work.sim_sink
    generic map (
      ID => 2)
    port map (
      pipe_in   => pipe(8),             -- [in]
      pipe_out  => pipe(9),
      stall_in  => '0',
      stall_out => stall(8),
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


