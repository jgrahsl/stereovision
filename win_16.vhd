library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;


entity win_16 is

  generic (
    ID     : integer range 0 to 63   := 0;
    KERNEL : natural                 := 5;
    WIDTH  : natural range 0 to 2048 := 2048;
    HEIGHT : natural range 0 to 2048 := 2048);
  port (
    pipe_in      : in  pipe_t;
    pipe_out     : out pipe_t;
    stall_in     : in  std_logic;
    stall_out    : out std_logic;
    rgb565_2d_out : out rgb565_2d_t
    );  

end win_16;

architecture myrtl of win_16 is

  signal pipe     : pipe_set_t;
  signal rgb565_1d : rgb565_1d_t;
  signal rgb565_2d : rgb565_2d_t;

  signal stall : std_logic_vector(MAX_PIPE-1 downto 0);

  constant HALF_KERNEL : natural := (KERNEL-1)/2;
begin  -- myrtl

  pipe(0)  <= pipe_in;
  pipe_out <= pipe(4);

  stall_out <= stall(0);
  stall(4)  <= stall_in;

  my_translate : entity work.translate
    generic map (
      ID     => (ID+0),
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT,
      CUT    => 0,
      APPEND => HALF_KERNEL)
    port map (
      pipe_in   => pipe(0),             -- [in]
      pipe_out  => pipe(1),
      stall_in  => stall(1),
      stall_out => stall(0)
      );                                -- [out]

  my_filter0_buffer : entity work.line_buffer_16
    generic map (
      ID        => (ID+1),
      NUM_LINES => KERNEL,
      HEIGHT    => HEIGHT+HALF_KERNEL,
      WIDTH     => WIDTH+HALF_KERNEL)
    port map (
      pipe_in      => pipe(1),
      pipe_out     => pipe(2),
      stall_in     => stall(2),
      stall_out    => stall(1),
      rgb565_1d_out => rgb565_1d
      );

  my_filter0_window : entity work.window_16
    generic map (
      ID       => (ID+2),
      NUM_COLS => KERNEL,
      HEIGHT   => HEIGHT+HALF_KERNEL,
      WIDTH    => WIDTH+HALF_KERNEL)
    port map (
      pipe_in      => pipe(2),
      pipe_out     => pipe(3),
      stall_in     => stall(3),
      stall_out    => stall(2),
      rgb565_1d_in  => rgb565_1d,
      rgb565_2d_out => rgb565_2d
      );

  my_translatea : entity work.translate_win_16
    generic map (
      ID     => (ID+3),
      WIDTH  => WIDTH+HALF_KERNEL,
      HEIGHT => HEIGHT+HALF_KERNEL,
      CUT    => HALF_KERNEL,
      APPEND => 0)
    port map (
      pipe_in      => pipe(3),          -- [in]
      pipe_out     => pipe(4),
      stall_in     => stall(4),
      stall_out    => stall(3),
      rgb565_2d_in  => rgb565_2d,
      rgb565_2d_out => rgb565_2d_out
      );                                -- [out]

end myrtl;