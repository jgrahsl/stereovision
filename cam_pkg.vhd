library ieee;
use ieee.std_logic_1164.all;

package cam_pkg is

-- vin_data(1)(0) 1 col delay
-- vin_data(0)(1) 1 row delay
  subtype bit_t is std_logic_vector(0 downto 0);
  subtype bayer_t is std_logic_vector(7 downto 0);
  subtype rgb_t is std_logic_vector(31 downto 0);  
  subtype lb_adr_t is std_logic_vector(10 downto 0);
  
  type stream_t is record
    valid : std_logic;    
    init : std_logic;
    aux : std_logic_vector(31 downto 0);
  end record;

  type window_t is array (0 to 4) of bayer_t;
  type window2d_t is array (0 to 4) of window_t;

  type bit_window_t is array (0 to 4) of bit_t;
  type bit_window2d_t is array (0 to 4) of bit_window_t;

  type cam_in_type is record
                   pclk    : std_logic;
                   d       : std_logic_vector(11 downto 0);
                   fval    : std_logic;
                   lval    : std_logic;
                   strobe  : std_logic;
  end record;

  type cam_debug_type is record
                   fval    : std_logic;
                   lval    : std_logic;
                   state : std_logic_vector(7 downto 0);
  end record;
  
  
  type cam_out_type is record
                     trigger : std_logic;
                     nrst    : std_logic;
  end record;
  type fbctl_debug_t is record
    vin: stream_t;
    vin_data_8 : std_logic_vector(7 downto 0);
    vin_data_888 : std_logic_vector(23 downto 0);    

    skin_vout: stream_t;
    skin_vout_data_1 : std_logic_vector(0 downto 0);   

    motion_vout: stream_t;
    motion_vout_data_8 : std_logic_vector(7 downto 0);   
    
    vout: stream_t;
    vout_data_1 : std_logic_vector(0 downto 0);   
  end record;
  
end cam_pkg;
