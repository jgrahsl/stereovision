library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;


entity morph is

  generic (
    KERNEL : natural range 0 to 5    := 5;
    THRESH : natural range 0 to 25   := 25;
    WIDTH  : natural range 0 to 2048 := 2048;
    HEIGHT : natural range 0 to 2048 := 2048);
  port (
    clk       : in  std_logic;
    rst     : in  std_logic;
    vin       : in  stream_t;
    vin_data  : in  bit_t;
    vout      : out stream_t;
    vout_data : out bit_t);

end morph;

architecture myrtl of morph is

  signal filter0_buff_vout   : stream_t;
  signal filter0_buff_window : bit_window_t;
  signal filter0_win_vout    : stream_t;
  signal filter0_win_window  : bit_window2d_t;
  
begin  -- myrtl


  my_filter0_buffer : entity work.cyclic_bit_buffer
    generic map (
      NUM_LINES => KERNEL,
      HEIGHT    => HEIGHT,
      WIDTH     => WIDTH)
    port map (
      clk         => clk,                   -- [in]
      rst         => rst,                 -- [in]
      vin         => vin,                   -- [in]
      vin_data    => vin_data,              -- [in]
      vout        => filter0_buff_vout,     -- [out]
      vout_window => filter0_buff_window);  -- [out]

  my_filter0_window : entity work.bit_window
    generic map (
      NUM_COLS => KERNEL,
      HEIGHT   => HEIGHT,
      WIDTH    => WIDTH)
    port map (
      clk         => clk,                  -- [in]
      rst         => rst,                -- [in]
      vin         => filter0_buff_vout,    -- [in]
      vin_window  => filter0_buff_window,  --
      vout        => filter0_win_vout,     -- [out]
      vout_window => filter0_win_window);  -- [out]

  --my_filter0_kernel : entity work.morphologic_kernel
  --  generic map (
  --    KERNEL => KERNEL,
  --    THRESH => THRESH)
  --  port map (
  --    clk        => clk,                 -- [in]
  --    rst        => rst,               -- [in]
  --    vin        => filter0_win_vout,    -- [in]
  --    vin_window => filter0_win_window,  -- [in]
  --    vout       => vout,                -- [out]
  --    vout_data  => vout_data);          -- [out]

  my_filter0_kernel : entity work.nullfilter
    port map (
      clk        => clk,                 -- [in]
      rst        => rst,               -- [in]
      vin        => filter0_win_vout,    -- [in]
      vin_data  => filter0_win_window,  -- [in]
      vout       => vout,                -- [out]
      vout_data  => vout_data);          -- [out]
  

  
end myrtl;
