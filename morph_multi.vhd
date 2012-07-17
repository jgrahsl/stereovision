library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity morph_multi is

  generic (
    KERNEL : natural range 0 to 5    := 5;
    THRESH1 : natural range 0 to 25   := 25;
    THRESH2 : natural range 0 to 25   := 25;    
    WIDTH  : natural range 0 to 2048 := 2048;
    HEIGHT : natural range 0 to 2048 := 2048;
    NUM : natural range 0 to 4 := 4
    );
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    vin       : in  stream_t;
    vin_data  : in  bit_t;
    vout      : out stream_t;
    vout_data : out bit_t);

end morph_multi;

architecture myrtl of morph_multi is

  signal morph_vout : stream_t;
  signal morph_data : bit_t;

  signal morph2_vout        : stream_t;
  signal morph2_vout_data_1 : std_logic_vector(0 downto 0);

  signal morph3_vout        : stream_t;
  signal morph3_vout_data_1 : std_logic_vector(0 downto 0);

  signal morph4_vout        : stream_t;
  signal morph4_vout_data_1 : std_logic_vector(0 downto 0);
  
begin  -- myrtl

  vout <= vin when NUM = 0 else
          morph_vout when NUM = 1 else
          morph2_vout when NUM = 2 else
          morph3_vout when NUM = 3 else
          morph4_vout;
          
  vout_data <= vin_data when NUM = 0 else
          morph_data when NUM = 1 else
          morph2_vout_data_1 when NUM = 2 else
          morph3_vout_data_1 when NUM = 3 else
          morph4_vout_data_1;
          
  
  my_morph : entity work.morph
    generic map (
      KERNEL => KERNEL,
      THRESH => THRESH1,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      clk       => clk,                 -- [in]
      rst       => rst,                 -- [in]
      vin       => vin,                 -- [in]
      vin_data  => vin_data,            -- [in]
      vout      => morph_vout,          -- [out]
      vout_data => morph_data);         -- [out]

  my_morph2 : entity work.morph
    generic map (
      KERNEL => KERNEL,
      THRESH => THRESH2,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      clk       => clk,                  -- [in]
      rst       => rst,                  -- [in]
      vin       => morph_vout,           -- [in]
      vin_data  => morph_data,           -- [in]
      vout      => morph2_vout,          -- [out]
      vout_data => morph2_vout_data_1);  -- [out]

  my_morph3 : entity work.morph
    generic map (
      KERNEL => KERNEL,
      THRESH => THRESH1,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      clk       => clk,                  -- [in]
      rst       => rst,                  -- [in]
      vin       => morph2_vout,          -- [in]
      vin_data  => morph2_vout_data_1,   -- [in]
      vout      => morph3_vout,          -- [out]
      vout_data => morph3_vout_data_1);  -- [out]

  my_morph4 : entity work.morph
    generic map (
      KERNEL => KERNEL,
      THRESH => THRESH2,
      WIDTH  => WIDTH,
      HEIGHT => HEIGHT)
    port map (
      clk       => clk,                 -- [in]
      rst       => rst,                 -- [in]
      vin       => morph3_vout,         -- [in]
      vin_data  => morph3_vout_data_1,  -- [in]
      vout      => morph4_vout,                -- [out]
      vout_data => morph4_vout_data_1);          -- [out]
  

end myrtl;
