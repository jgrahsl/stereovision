library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
--use work.txt_util.all;
use std.textio.all;
use work.txt_util.all;


use work.cam_pkg.all;

entity tb is
  generic (
    KERNEL : natural range 0 to 5    := 5;
    THRESH1 : natural range 0 to 25   := 25;
    THRESH2 : natural range 0 to 25   := 25;    
    WIDTH  : natural range 0 to 2048 := 160;
    HEIGHT : natural range 0 to 2048 := 160;
    NUM    : natural range 0 to 4    := 4
    );
end tb;

architecture impl of tb is
  
  signal clk : std_logic;
  signal rst : std_logic;

  signal vin  : stream_t;
  signal vout : stream_t;

  signal vin_data  : bit_t;
  signal vout_data : bit_t;

  signal col : natural range 0 to 2048 := 0;
  signal row : natural range 0 to 2048 := 0;

  signal ce_count : unsigned(4 downto 0);
  signal ce       : std_logic;

  signal go : std_logic;

  subtype pixel_t is std_logic_vector(0 downto 0);
  type    mem_t is array (0 to (2*HEIGHT*WIDTH-1)) of pixel_t;

  signal mem : mem_t;
begin  -- impl

  dut : entity work.morph_multi
    generic map (
      KERNEL => KERNEL,
      THRESH1 => THRESH1,
      THRESH2 => THRESH2,      
      HEIGHT => HEIGHT,
      WIDTH  => WIDTH,
      NUM    => NUM)
    port map (
      clk       => clk,                 -- [in]
      rst       => rst,                 -- [in]
      vin       => vin,                 -- [in]
      vin_data  => vin_data,            -- [in]
      vout      => vout,                -- [out]
      vout_data => vout_data);          -- [out]

-------------------------------------------------------------------------------  
-- Clock and Rst
-------------------------------------------------------------------------------

  process
  begin  -- process    
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process;

  process
  begin  -- process
    rst <= '0';
    wait for 100 ns;
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
    variable s         : string(1 to 8);
    variable c         : integer := 0;
    variable b         : std_logic_vector(7 downto 0);
  begin
    while not endfile(f) loop
      readline(f, l);
      read(l, s);                       --ok
      b := to_std_logic_vector(s);      --ok
      for i in 0 to 7 loop
        mem(c) <= b(i downto i);
        c      := c + 1;
      end loop;  -- i
    end loop;
    wait;

  end process;


  process
    constant stim_file : string  := "sim.out";
    file f             : text open write_mode is stim_file;
    variable s         : string(1 to 8);
    variable c         : integer := 0;
    variable b         : std_logic_vector(7 downto 0);
    variable p         : integer := 0;    
  begin

    wait until go = '1';
    p := 0;
    for j in (HEIGHT-1) downto 0 loop
      for i in (WIDTH-1) downto 0 loop
        wait until clk = '0' and vout.valid = '1';
        b(p downto p) := vout_data(0 downto 0);
        if p < 7 then
          p := p + 1;            
        else
          p := 0;
          print(f, str(b));          
        end if;
        wait until clk = '1' and vout.valid = '1';
      end loop;
    end loop;  -- j
    

  end process;

-------------------------------------------------------------------------------
  -- video
-------------------------------------------------------------------------------  
  process (clk)

  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      if rst = '1' then                 -- synchronous rst (active high)
        col      <= 0;
        row      <= 0;
        ce_count <= (others => '0');
        go       <= '0';
      else

        ce <= '0';

        if ce_count < 2 then
          ce_count <= ce_count + 1;
        else
          ce_count <= (others => '0');
          ce       <= '1';
        end if;

        col <= col + 1;


        if col < WIDTH-1 then
          col <= col + 1;
        else
          col <= 0;
          if row < HEIGHT-1 then
            row <= row + 1;
          else
            row <= 0;
            go  <= '1';
          end if;
        end if;
      
      end if;
    end if;
  end process;

  vin_data <= mem(row*WIDTH + col); 
  
  vin.valid <= '1' when go = '1' else '0';
  vin.init  <= '0';  -- '1' when col = 0 and row = 0 else '0';

  
end impl;


