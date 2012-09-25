library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity morph_set is

  generic (
    ID     : integer range 0 to (MAX_PIPE-1) := 0;
    KERNEL : natural range 0 to 5            := 5;
    WIDTH  : natural range 0 to 2048         := 2048;
    HEIGHT : natural range 0 to 2048         := 2048);
  port (
    pipe_in   : in pipe_t;
    pipe_out  : out pipe_t;
    stall_in  : in    std_logic;
    stall_out : out   std_logic
    );  

end morph_set;

architecture myrtl of morph_set is

  signal pipe  : pipe_set_t;
  signal stall : std_logic_vector(MAX_PIPE-1 downto 0);
  
begin  -- myrtl

  pipe(0)  <= pipe_in;
  pipe_out <= pipe(3);

  stall_out <= stall(0);
  stall(3)  <= stall_in;
  
  my_morph_1 : entity work.morph
    generic map (
      ID     => ID,
      KERNEL => KERNEL,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      pipe_in   => pipe(0),             -- [in]
      pipe_out  => pipe(1),
      stall_in  => stall(1),
      stall_out => stall(0)
      );                                -- [out]
  my_morph_2 : entity work.morph
    generic map (
      ID     => (ID+5),
      KERNEL => KERNEL,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      pipe_in   => pipe(1),             -- [in]
      pipe_out  => pipe(2),
      stall_in  => stall(2),
      stall_out => stall(1)
      );                                -- [out]
  my_morph_3 : entity work.morph
    generic map (
      ID     => (ID+10),
      KERNEL => KERNEL,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      pipe_in   => pipe(2),             -- [in]
      pipe_out  => pipe(3),
      stall_in  => stall(3),
      stall_out => stall(2)
      );                                -- [out]
  --my_morph_4 : entity work.morph
  --  generic map (
  --    ID     => (ID+15),
  --    KERNEL => KERNEL,
  --    WIDTH  => WIDTH,
  --    HEIGHT => HEIGHT)
  --  port map (
  --    pipe_in   => pipe(3),             -- [in]
  --    pipe_out  => pipe(4),
  --    stall_in  => stall(4),
  --    stall_out => stall(3)
  --    );                                -- [out]

end myrtl;
