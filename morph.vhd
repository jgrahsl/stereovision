library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;


entity morph is

  generic (
    ID     : integer range 0 to 63   := 0;
    KERNEL : natural range 0 to 5    := 5;
    WIDTH  : natural range 0 to 2048 := 2048;
    HEIGHT : natural range 0 to 2048 := 2048);
  port (
    pipe_in  : in  pipe_t;
    pipe_out : out pipe_t);  

end morph;

architecture myrtl of morph is

  signal pipe    : pipe_set_t;
  signal mono_1d : mono_1d_t;
  signal mono_2d : mono_2d_t;
  
begin  -- myrtl
  
  pipe(0)  <= pipe_in;
  pipe_out <= pipe(3);

  my_filter0_buffer : entity work.cyclic_bit_buffer
    generic map (
      ID        => (ID),
      NUM_LINES => KERNEL,
      HEIGHT    => HEIGHT,
      WIDTH     => WIDTH)
    port map (
      pipe_in     => pipe(0),
      pipe_out    => pipe(1),
      mono_1d_out => mono_1d
      );

  my_filter0_window : entity work.bit_window
    generic map (
      ID       => (ID+1),
      NUM_COLS => KERNEL,
      HEIGHT   => HEIGHT,
      WIDTH    => WIDTH)
    port map (
      pipe_in     => pipe(1),
      pipe_out    => pipe(2),
      mono_1d_in  => mono_1d,
      mono_2d_out => mono_2d
      );

  my_filter0_kernel : entity work.morph_kernel
    generic map (
      ID     => (ID+2),
      KERNEL => KERNEL)
    port map (
      pipe_in    => pipe(2),
      pipe_out   => pipe(3),
      mono_2d_in => mono_2d
      );

end myrtl;
