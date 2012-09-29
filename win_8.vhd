library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;


entity win_gray8 is

  generic (
    ID     : integer range 0 to 63   := 0;
    KERNEL : natural range 0 to 5    := 5;
    WIDTH  : natural range 0 to 2048 := 2048;
    HEIGHT : natural range 0 to 2048 := 2048);
  port (
    pipe_in      : in  pipe_t;
    pipe_out     : out pipe_t;
    stall_in     : in  std_logic;
    stall_out    : out std_logic;
    gray8_2d_out : out gray8_2d_t
    );  

end win_gray8;

architecture myrtl of win_gray8 is

  signal pipe     : pipe_set_t;
  signal gray8_1d : gray8_1d_t;
  signal gray8_2d : gray8_2d_t;

  signal stall : std_logic_vector(MAX_PIPE-1 downto 0);
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
      APPEND => 2)
    port map (
      pipe_in   => pipe(0),             -- [in]
      pipe_out  => pipe(1),
      stall_in  => stall(1),
      stall_out => stall(0)
      );                                -- [out]

  my_filter0_buffer : entity work.line_buffer_8
    generic map (
      ID        => (ID+1),
      NUM_LINES => KERNEL,
      HEIGHT    => HEIGHT+2,
      WIDTH     => WIDTH+2)
    port map (
      pipe_in      => pipe(1),
      pipe_out     => pipe(2),
      stall_in     => stall(2),
      stall_out    => stall(1),
      gray8_1d_out => gray8_1d
      );

  my_filter0_window : entity work.window_8
    generic map (
      ID       => (ID+2),
      NUM_COLS => KERNEL,
      HEIGHT   => HEIGHT+2,
      WIDTH    => WIDTH+2)
    port map (
      pipe_in      => pipe(2),
      pipe_out     => pipe(3),
      stall_in     => stall(3),
      stall_out    => stall(2),
      gray8_1d_in  => gray8_1d,
      gray8_2d_out => gray8_2d
      );

  my_translatea : entity work.translate_win
    generic map (
      ID     => (ID+3),
      WIDTH  => WIDTH+2,
      HEIGHT => HEIGHT+2,
      CUT    => 2,
      APPEND => 0)
    port map (
      pipe_in      => pipe(3),          -- [in]
      pipe_out     => pipe(4),
      stall_in     => stall(4),
      stall_out    => stall(3),
      gray8_2d_in  => gray8_2d,
      gray8_2d_out => gray8_2d_out
      );                                -- [out]

end myrtl;
