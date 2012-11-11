library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;


entity distort is

  generic (
    ID     : integer range 0 to 63   := 0;
    KERNEL : natural                 := 5;
    WIDTH  : natural range 0 to 2048 := 2048;
    HEIGHT : natural range 0 to 2048 := 2048);
  port (
    pipe_in      : in  pipe_t;
    pipe_out     : out pipe_t;
    stall_in     : in  std_logic;
    stall_out    : out std_logic
    );  

end distort;

architecture myrtl of distort is

  signal pipe          : pipe_set_t;
  signal gray8_1d      : gray8_1d_t;
  signal gray8_2d_untr : gray8_2d_t;

  signal stall : std_logic_vector(MAX_PIPE-1 downto 0);

  constant HALF_KERNEL : natural := (KERNEL-1)/2;
  constant T_W         : natural := HALF_KERNEL;
  constant T_H         : natural := HALF_KERNEL;

  signal abcd       : abcd_t;
  signal abcd_1     : abcd_t;
  signal abcd_2     : abcd_t;
  signal abcd_3     : abcd_t;
  signal abcd2      : abcd2_t;
  signal gray8_2d_1 : gray8_2d_t;
  signal gray8_2d_2 : gray8_2d_t;
  signal gray8_2d_3 : gray8_2d_t;
  signal gray8_2d_4 : gray8_2d_t;
  signal ox_1       : signed((ABCD_BITS/2)+SUBGRID_BITS-1 downto 0);
  signal ox_2       : signed((ABCD_BITS/2)+SUBGRID_BITS-1 downto 0);
  signal oy         : signed((ABCD_BITS/2)+SUBGRID_BITS-1 downto 0);


  attribute keep_hierarchy               : string;
--  attribute keep_hierarchy of inst_bi2_x: label is "yes";
--  attribute keep_hierarchy of inst_bi2_y: label is "yes";
  attribute keep_hierarchy of inst_bi2_c : label is "yes";
 
begin  -- myrtl

  pipe(1)  <= pipe_in;
  pipe_out <= pipe(9);

  stall_out <= stall(1);
  stall(9)  <= stall_in;

  my_translate : entity work.translate
    generic map (
      ID       => (ID+0),
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
      ID        => (ID+1),
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
      ID       => (ID+2),
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
      ID       => (ID+3),
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
      ID     => (ID+4),
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
      ID     => (ID+5),
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
      ID     => (ID+6),
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      pipe_in   => pipe(8),             -- [in]
      pipe_out  => pipe(9),
      stall_in  => stall(9),
      stall_out => stall(8),
      abcd2     => abcd2
      );                                -- [inout]

end myrtl;
