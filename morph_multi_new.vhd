library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity morph_multi is

  generic (
    KERNEL : natural range 0 to 5    := 5;
    THRESH : natural range 0 to 25   := 25;
    WIDTH  : natural range 0 to 2048 := 2048;
    HEIGHT : natural range 0 to 2048 := 2048);
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    vin       : in  stream_t;
    vin_data  : in  bit_t;
    vout      : out stream_t;
    vout_data : out bit_t);

end morph_multi;

architecture myrtl of morph_multi is


  signal filter0_buff_vout   : stream_t;
  signal filter0_buff_window : bit_window_t;
  signal filter0_win_vout    : stream_t;
  signal filter0_win_window  : bit_window2d_t;
  signal filter0_kern_vout    : stream_t;
  signal filter0_kern_bit  : bit_t;

  signal filter1_buff_vout   : stream_t;
  signal filter1_buff_window : bit_window_t;
  signal filter1_win_vout    : stream_t;
  signal filter1_win_window  : bit_window2d_t;
  signal filter1_kern_vout    : stream_t;
  signal filter1_kern_bit  : bit_t;


  signal filter2_buff_vout   : stream_t;
  signal filter2_buff_window : bit_window_t;
  signal filter2_win_vout    : stream_t;
  signal filter2_win_window  : bit_window2d_t;
  signal filter2_kern_vout    : stream_t;
  signal filter2_kern_bit  : bit_t;

  signal filter3_buff_vout   : stream_t;
  signal filter3_buff_window : bit_window_t;
  signal filter3_win_vout    : stream_t;
  signal filter3_win_window  : bit_window2d_t;
  
begin  -- myrtl


  my_filter0_buffer : entity work.cyclic_bit_buffer
    generic map (
      NUM_LINES => KERNEL,
      HEIGHT    => HEIGHT,
      WIDTH     => WIDTH)
    port map (
      clk         => clk,                   -- [in]
      rst         => reset,                 -- [in]
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
      rst         => reset,                -- [in]
      vin         => filter0_buff_vout,    -- [in]
      vin_window  => filter0_buff_window,  --
      vout        => filter0_win_vout,     -- [out]
      vout_window => filter0_win_window);  -- [out]

  my_filter0_kernel : entity work.morphologic_kernel
    generic map (
      KERNEL => KERNEL,
      THRESH => THRESH)
    port map (
      clk        => clk,                 -- [in]
      rst        => reset,               -- [in]
      vin        => filter0_win_vout,    -- [in]
      vin_window => filter0_win_window,  -- [in]
      vout       => filter0_kern_vout,                -- [out]
      vout_data  => filter0_kern_bit);          -- [out]

-------------------------------------------------------------------------------
-- 1
-------------------------------------------------------------------------------
  my_filter1_buffer : entity work.cyclic_bit_buffer
    generic map (
      NUM_LINES => KERNEL,
      HEIGHT    => HEIGHT,
      WIDTH     => WIDTH)
    port map (
      clk         => clk,                   -- [in]
      rst         => reset,                 -- [in]
      vin         => filter0_kern_vout,                   -- [in]
      vin_data    => filter0_kern_bit,              -- [in]
      vout        => filter1_buff_vout,     -- [out]
      vout_window => filter1_buff_window);  -- [out]

  my_filter1_window : entity work.bit_window
    generic map (
      NUM_COLS => KERNEL,
      HEIGHT   => HEIGHT,
      WIDTH    => WIDTH)
    port map (
      clk         => clk,                  -- [in]
      rst         => reset,                -- [in]
      vin         => filter1_buff_vout,    -- [in]
      vin_window  => filter1_buff_window,  --
      vout        => filter1_win_vout,     -- [out]
      vout_window => filter1_win_window);  -- [out]

  my_filter1_kernel : entity work.morphologic_kernel
    generic map (
      KERNEL => KERNEL,
      THRESH => THRESH)
    port map (
      clk        => clk,                 -- [in]
      rst        => reset,               -- [in]
      vin        => filter1_win_vout,    -- [in]
      vin_window => filter1_win_window,  -- [in]
      vout       => filter1_kern_vout,                -- [out]
      vout_data  => filter1_kern_bit);          -- [out]
-------------------------------------------------------------------------------
-- 2
-------------------------------------------------------------------------------
  my_filter2_buffer : entity work.cyclic_bit_buffer
    generic map (
      NUM_LINES => KERNEL,
      HEIGHT    => HEIGHT,
      WIDTH     => WIDTH)
    port map (
      clk         => clk,                   -- [in]
      rst         => reset,                 -- [in]
      vin         => filter1_kern_vout,                   -- [in]
      vin_data    => filter1_kern_bit,              -- [in]
      vout        => filter2_buff_vout,     -- [out]
      vout_window => filter2_buff_window);  -- [out]

  my_filter2_window : entity work.bit_window
    generic map (
      NUM_COLS => KERNEL,
      HEIGHT   => HEIGHT,
      WIDTH    => WIDTH)
    port map (
      clk         => clk,                  -- [in]
      rst         => reset,                -- [in]
      vin         => filter2_buff_vout,    -- [in]
      vin_window  => filter2_buff_window,  --
      vout        => filter2_win_vout,     -- [out]
      vout_window => filter2_win_window);  -- [out]

  my_filter2_kernel : entity work.morphologic_kernel
    generic map (
      KERNEL => KERNEL,
      THRESH => THRESH)
    port map (
      clk        => clk,                 -- [in]
      rst        => reset,               -- [in]
      vin        => filter2_win_vout,    -- [in]
      vin_window => filter2_win_window,  -- [in]
      vout       => filter2_kern_vout,                -- [out]
      vout_data  => filter2_kern_bit);          -- [out]
-------------------------------------------------------------------------------
-- 3
-------------------------------------------------------------------------------
  my_filter3_buffer : entity work.cyclic_bit_buffer
    generic map (
      NUM_LINES => KERNEL,
      HEIGHT    => HEIGHT,
      WIDTH     => WIDTH)
    port map (
      clk         => clk,                   -- [in]
      rst         => reset,                 -- [in]
      vin         => filter2_kern_vout,                   -- [in]
      vin_data    => filter2_kern_bit,              -- [in]
      vout        => filter3_buff_vout,     -- [out]
      vout_window => filter3_buff_window);  -- [out]

  my_filter3_window : entity work.bit_window
    generic map (
      NUM_COLS => KERNEL,
      HEIGHT   => HEIGHT,
      WIDTH    => WIDTH)
    port map (
      clk         => clk,                  -- [in]
      rst         => reset,                -- [in]
      vin         => filter3_buff_vout,    -- [in]
      vin_window  => filter3_buff_window,  --
      vout        => filter3_win_vout,     -- [out]
      vout_window => filter3_win_window);  -- [out]

  my_filter3_kernel : entity work.morphologic_kernel
    generic map (
      KERNEL => KERNEL,
      THRESH => THRESH)
    port map (
      clk        => clk,                 -- [in]
      rst        => reset,               -- [in]
      vin        => filter3_win_vout,    -- [in]
      vin_window => filter3_win_window,  -- [in]
      vout       => vout,                -- [out]
      vout_data  => vout_data);          -- [out]

end myrtl;
