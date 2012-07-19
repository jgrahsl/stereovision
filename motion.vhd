library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity motion is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    vin       : in  stream_t;
    vin_data  : in  std_logic_vector(7 downto 0);
    vout      : out stream_t;
    vout_data : out std_logic_vector(7 downto 0);
    cfg: in motion_cfg_t
    );
end motion;

architecture impl of motion is

  type nullfilter_t is record
    data : std_logic_vector(7 downto 0);
    vin  : stream_t;
  end record;

  signal r      : nullfilter_t;
  signal r_next : nullfilter_t;

-------------------------------------------------------------------------------
-- Implementation
-------------------------------------------------------------------------------  
begin  -- impl

  vout      <= r.vin;
  vout_data <= r.data;

  process (r, vin, vin_data)
    variable diff  : unsigned(7 downto 0);
    variable m     : unsigned(7 downto 0);
    variable v     : unsigned(15 downto 0);
    variable i     : unsigned(7 downto 0);
    variable d     : unsigned(0 downto 0);
    variable d_old : unsigned(0 downto 0);
    variable vmin  : unsigned(v'high downto v'low);
    variable vmax  : unsigned(v'high downto v'low);
  begin
    r_next.vin     <= vin;
    r_next.vin.aux <= vin.aux;
    r_next.data    <= (others => '0');

    diff := (others => '0');
    m    := unsigned(vin.aux((0+m'high) downto 0));
    v    := unsigned(vin.aux((15+v'high) downto 15));
    d    := unsigned(vin.aux(31 downto 31));
    i    := unsigned(vin_data);
    vmax := unsigned(cfg.vmax);
    vmin := unsigned(cfg.vmin);
--    vmax := to_unsigned(1023, v'length);
--    vmin := to_unsigned(2, v'length);
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
    if d = 0 then
      if i < m then
        m := m - 1;
      elsif i > m then
        m := m + 1;
      end if;
    end if;

    if i < m then
      diff := m - i;
    elsif i > m then
      diff := i - m;
    end if;

    if v < (diff&"000") then
--      if v < vmax then
        v := v + 1;
--      end if;
    elsif v > (diff&"000") then
--      if v > vmin then
        v := v - 1;
--      end if;
    end if;

    if v < vmin then
      v := vmin;
    end if;

    if v > vmax then
      v := vmax;
    end if;   
    
    if diff < v then
      d := "0";
    else
      d := "1";
    end if;
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------   
    r_next.vin.aux((0+m'high) downto 0)   <= std_logic_vector(m);
    r_next.vin.aux((15+v'high) downto 15) <= std_logic_vector(v);
    r_next.vin.aux(31 downto 31)          <= std_logic_vector(d);

    if vin.valid = '1' then
      if d = 0 then
        r_next.data <= (others => '0');
      else
        r_next.data <= (others => '1');
      end if;
    else
      r_next.data <= X"AA";
    end if;

  end process;

  proc_clk : process(clk, rst)
  begin
    if rst = '1' then
      r.vin.valid <= '0';
      r.vin.init  <= '0';
    else
      if rising_edge(clk) then
        r <= r_next;
      end if;
    end if;
  end process;

end impl;
