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

  signal pipe         : pipe_set_t;
  signal mono_2d      : mono_2d_t;

  signal stall : std_logic_vector(MAX_PIPE-1 downto 0);
begin  -- myrtl

  pipe(0)  <= pipe_in;
  pipe_out <= pipe(2);

  stall_out <= stall(0);
  stall(2)  <= stall_in;

  my_filter0_window : entity work.win_mono
    generic map (
      ID     => (ID+0),
      KERNEL => KERNEL,
      HEIGHT => HEIGHT,
      WIDTH  => WIDTH)
    port map (
      pipe_in     => pipe(0),
      pipe_out    => pipe(1),
      stall_in    => stall(1),
      stall_out   => stall(0),
      mono_2d_out => mono_2d
      );

  my_filter0_kernel : entity work.morph_kernel
    generic map (
      ID     => (ID+4),
      KERNEL => KERNEL)
    port map (
      pipe_in    => pipe(1),
      pipe_out   => pipe(2),
      stall_in   => stall(2),
      stall_out  => stall(1),
      mono_2d_in => mono_2d
      );

end myrtl;
