library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity bit_window is
  generic (
    NUM_COLS : natural range 0 to 5    := 5;
    WIDTH    : natural range 1 to 2048 := 2048;
    HEIGHT   : natural range 1 to 2048 := 2048);
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    vin         : in  stream_t;
    vin_window  : in  bit_window_t;
    vout        : out stream_t;
    vout_window : out bit_window2d_t
    );
end bit_window;

architecture impl of bit_window is
-------------------------------------------------------------------------------
-- Registers and init
-------------------------------------------------------------------------------
  type reg_t is record
    cols : natural range 0 to WIDTH;
    rows : natural range 0 to HEIGHT;
  end record;
  signal r                   :       reg_t;
  signal rin                 :       reg_t;
  procedure init (variable v : inout reg_t) is
  begin
    v.cols := 0;
    v.rows := 0;
  end init;

-------------------------------------------------------------------------------
-- Signals
-------------------------------------------------------------------------------
--  type   adr_vector_t is array (0 to NUM_LINES) of lb_adr_t;
  signal q      : bit_window2d_t;
  signal next_q : bit_window2d_t;
  signal vin_r  : stream_t;
  
begin

  process(rst, r, vin, vin_r, vin_window, q)
    variable v : reg_t;
  begin  -- process
    v      := r;
    next_q <= q;
-------------------------------------------------------------------------------
-- Counters
-------------------------------------------------------------------------------
    if vin.valid = '1' then
      for i in 0 to (NUM_COLS-2) loop
        next_q(i+1) <= q(i);
      end loop;  -- i

      if r.cols = (WIDTH-1) then
        v.cols := 0;
        next_q <= (others => (others => (others => '1')));
      else
        v.cols := v.cols + 1;
      end if;

      next_q(0) <= vin_window;
    end if;
-------------------------------------------------------------------------------
-- VIN.INIT
-------------------------------------------------------------------------------
    if vin.init = '1' or rst = '1' then
      init(v);
      next_q <= (others => (others => (others => '1')));
    end if;

    rin         <= v;
    vout        <= vin_r;
    vout_window <= q;
  end process;

  process (clk, r, rin)
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      r     <= rin;
      q     <= next_q;
      vin_r <= vin;
    end if;
  end process;

end impl;
