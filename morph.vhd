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
    pipe_in   : in  pipe_t;
    pipe_out  : out pipe_t;
    stall_in  : in  std_logic;
    stall_out : out std_logic
    );  

end morph;

architecture myrtl of morph is

  signal pipe    : pipe_set_t;
  signal mono_1d : mono_1d_t;
  signal mono_2d : mono_2d_t;

  signal stall : std_logic_vector(MAX_PIPE-1 downto 0);
begin  -- myrtl

  pipe(0)  <= pipe_in;
  pipe_out <= pipe(5);

  stall_out <= stall(0);
  stall(5)  <= stall_in;

  my_translate : entity work.translate
    generic map (
      ID     => (ID+0),
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT,
      CUT    => 0,
      APPEND => 2)
    port map (
      pipe_in   => pipe(0),             -- [in]
      pipe_out  => pipe(1),
      stall_in  => stall(1),
      stall_out => stall(0)
      );                                -- [out]

  my_filter0_buffer : entity work.line_buffer
    generic map (
      ID        => (ID+1),
      NUM_LINES => KERNEL,
      HEIGHT    => HEIGHT+2,
      WIDTH     => WIDTH+2)
    port map (
      pipe_in     => pipe(1),
      pipe_out    => pipe(2),
      stall_in    => stall(2),
      stall_out   => stall(1),
      mono_1d_out => mono_1d
      );

  my_filter0_window : entity work.window
    generic map (
      ID       => (ID+2),
      NUM_COLS => KERNEL,
      HEIGHT   => HEIGHT+2,
      WIDTH    => WIDTH+2)
    port map (
      pipe_in     => pipe(2),
      pipe_out    => pipe(3),
      stall_in    => stall(3),
      stall_out   => stall(2),
      mono_1d_in  => mono_1d,
      mono_2d_out => mono_2d
      );

  my_filter0_kernel : entity work.morph_kernel
    generic map (
      ID     => (ID+3),
      KERNEL => KERNEL)
    port map (
      pipe_in    => pipe(3),
      pipe_out   => pipe(4),
      stall_in   => stall(4),
      stall_out  => stall(3),
      mono_2d_in => mono_2d
      );

  my_translatea : entity work.translate
    generic map (
      ID     => (ID+4),
      WIDTH  => WIDTH+2,
      HEIGHT => HEIGHT+2,
      CUT    => 2,
      APPEND => 0)
    port map (
      pipe_in   => pipe(4),             -- [in]
      pipe_out  => pipe(5),
      stall_in  => stall(5),
      stall_out => stall(4)
      );                                -- [out]

end myrtl;
