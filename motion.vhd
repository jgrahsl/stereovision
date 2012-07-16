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
    vout_data : out std_logic_vector(7 downto 0)
    );
end motion;

architecture impl of motion is

type nullfilter_t is record
  data  : std_logic_vector(7 downto 0);
  vin   : stream_t;
end record;

signal r : nullfilter_t;
signal r_next : nullfilter_t;

-------------------------------------------------------------------------------
-- Implementation
-------------------------------------------------------------------------------  
begin  -- impl

  vout <= r.vin;
  vout_data <= r.data;

  process (r, vin, vin_data)
    variable diff : std_logic_vector(7 downto 0);
  begin 
	r_next.vin <= vin;
   r_next.vin.aux <= vin.aux;
   diff := (others => '0');

   
   if unsigned(vin_data) < unsigned(vin.aux(7 downto 0)) then
     if (vin.aux(31) = '0') and (unsigned(vin.aux(7 downto 0)) > 0) then
       r_next.vin.aux(7 downto 0) <= std_logic_vector(unsigned(vin.aux(7 downto 0)) - 1);
     end if;
     diff := std_logic_vector((unsigned(vin.aux(7 downto 0)) - unsigned(vin_data) - 1));
   elsif unsigned(vin_data) > unsigned(vin.aux(7 downto 0)) then
     if (vin.aux(31) = '0') and (unsigned(vin.aux(7 downto 0)) < 255) then
       r_next.vin.aux(7 downto 0) <= std_logic_vector(unsigned(vin.aux(7 downto 0)) + 1);
     end if;
     diff := std_logic_vector((unsigned(vin_data) - unsigned(vin.aux(7 downto 0)) - 1));
   end if;

   r_next.vin.aux(31) <= '0';
   r_next.data <= (others => '0');            
   if (unsigned(diff)&"00") < unsigned(vin.aux(18 downto 8)) then
     if unsigned(vin.aux(18 downto 8)) > 0 then
       r_next.vin.aux(18 downto 8) <= std_logic_vector(unsigned(vin.aux(18 downto 8)) - 1);
     end if;
     r_next.data <= (others => '0');
     r_next.vin.aux(31) <= '0';     
   elsif (unsigned(diff)&"00") > unsigned(vin.aux(18 downto 8)) then
     if unsigned(vin.aux(18 downto 8)) < (2**11-1) then
       r_next.vin.aux(18 downto 8) <= std_logic_vector(unsigned(vin.aux(18 downto 8)) + 1);
     end if;
     r_next.data <= (others => '1');
     r_next.vin.aux(31) <= '1';      
   end if;

  end process;

  proc_clk : process(clk, rst)
  begin
    if rst = '1' then
      r.vin.valid <= '0';
      r.vin.init <= '0';
    else 
		if rising_edge(clk) then
			r <= r_next;
		end if;
    end if;
  end process;

end impl;
