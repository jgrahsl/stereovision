library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity morphologic_kernel is
  generic (
    KERNEL : natural range 1 to 5  := 5;
    THRESH : natural range 0 to 25 := 12
    );
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    vin        : in  stream_t;
    vin_window : in  bit_window2d_t;
    vout       : out stream_t;
    vout_data  : out bit_t);
end morphologic_kernel;

architecture impl of morphologic_kernel is
  type reg_t is record
    vout : stream_t;
    q    : bit_t;
  end record;

  procedure init (variable v : inout reg_t) is
  begin
    v.vout.init  := '0';
    v.vout.valid := '0';
    v.q          := (others => '0');
  end init;

  signal r      : reg_t;
  signal r2      : reg_t;  
  signal r_next : reg_t;

begin

  -- Outputs
  vout      <= r.vout;
  vout_data <= r.q;

  process(rst, r, vin, vin_window)
    variable v   : reg_t;
    variable win : bit_window2d_t;
    variable sum : natural range 0 to (KERNEL*KERNEL);
  begin  -- process

    v      := r;
    v.vout := vin;

    win := vin_window;
    sum := 0;

    ---------------------------------------------------------------------------
    -- Square
    ---------------------------------------------------------------------------
    --for i in 0 to (KERNEL-1) loop
    --  for j in 0 to (KERNEL-1) loop
    --    sum := sum + to_integer(unsigned(win(i)(j)));
    --  end loop;
    --end loop;

    -------------------------------------------------------------------------------
    -- Octagon
    -------------------------------------------------------------------------------
    sum := to_integer(unsigned(win(0)(1))) +
           to_integer(unsigned(win(0)(2))) +
           to_integer(unsigned(win(0)(3))) +

           to_integer(unsigned(win(1)(0))) +           
           to_integer(unsigned(win(1)(1))) +
           to_integer(unsigned(win(1)(2))) +
           to_integer(unsigned(win(1)(3))) +
           to_integer(unsigned(win(1)(4))) +           

           to_integer(unsigned(win(2)(0))) +           
           to_integer(unsigned(win(2)(1))) +
           to_integer(unsigned(win(2)(2))) +
           to_integer(unsigned(win(2)(3))) +
           to_integer(unsigned(win(2)(4))) +           

           to_integer(unsigned(win(3)(0))) +           
           to_integer(unsigned(win(3)(1))) +
           to_integer(unsigned(win(3)(2))) +
           to_integer(unsigned(win(3)(3))) +
           to_integer(unsigned(win(3)(4))) +           

           to_integer(unsigned(win(4)(1))) +
           to_integer(unsigned(win(4)(2))) +
           to_integer(unsigned(win(4)(3)));                     
    
    if (sum >= (THRESH)) then
      v.q := "1";
    else
      v.q := "0";
    end if;

--    v.q := win(2)(0);
    
    if rst = '1' then
      init(v);
    end if;

    r_next <= v;

  end process;

  process (clk)
  begin  -- process
    if rising_edge(clk) then            -- rising clock edge
      r <= r_next;
      r2 <= r;
    end if;
  end process;

end impl;


