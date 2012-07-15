library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity skinfilter is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    vin       : in  stream_t;
    vin_data  : in  std_logic_vector(23 downto 0);
    vout      : out stream_t;
    vout_data : out std_logic_vector(0 downto 0)
    );
end skinfilter;

architecture impl of skinfilter is

type skinfilter_t is record
  skin  : std_logic_vector(0 downto 0);
  vin   : stream_t;
  vout  : stream_t;
end record;

signal r : skinfilter_t;
signal r_next : skinfilter_t;

-------------------------------------------------------------------------------
-- Implementation
-------------------------------------------------------------------------------  
begin  -- impl

  -- Output
  vout <= r.vin;
  vout_data <= r.skin;

  process (r, vin, vin_data)
    variable  colr     : std_logic_vector(15 downto 0);
    variable  colg     : std_logic_vector(15 downto 0);
    variable  colb     : std_logic_vector(15 downto 0);

    variable Y : signed(31 downto 0);
    variable Cb : signed(31 downto 0);
    variable Cr : signed(31 downto 0);

    constant COEFF_Y_R : signed(23 downto 0) := to_signed(19595, 24);
    constant COEFF_Y_G : signed(23 downto 0) := to_signed(38470, 24);
    constant COEFF_Y_B : signed(23 downto 0) := to_signed(7471, 24);
    constant COEFF_CB_R : signed(23 downto 0) := to_signed(-11058, 24);
    constant COEFF_CB_G : signed(23 downto 0) := to_signed(21710, 24);
    constant COEFF_CB_B : signed(23 downto 0) := to_signed(32768, 24);
    constant COEFF_CR_R : signed(23 downto 0) := to_signed(32768, 24);
    constant COEFF_CR_G : signed(23 downto 0) := to_signed(27439, 24);
    constant COEFF_CR_B : signed(23 downto 0) := to_signed(5329, 24);

    constant COEFF_Y_LOW : signed(31 downto 0) := to_signed(  5000000, 32);
    constant COEFF_Y_HIGH : signed(31 downto 0) := to_signed(12000000, 32);
    constant COEFF_CB_LOW : signed(31 downto 0) := to_signed(-2516582, 32);
    constant COEFF_CB_HIGH : signed(31 downto 0) := to_signed(838861, 32);
    constant COEFF_CR_LOW : signed(31 downto 0) := to_signed(838861, 32);
    constant COEFF_CR_HIGH : signed(31 downto 0) := to_signed(3355443, 32);
  begin
 
	r_next <= r;
	r_next.vin <= vin;
	colr := "00000000" & vin_data(23 downto 16);
	colg := "00000000" & vin_data(15 downto  8);
	colb := "00000000" & vin_data( 7 downto  0);

	if (vin.valid = '1') then
      Y  := resize(COEFF_Y_R * signed(colr) + COEFF_Y_G * signed(colg) + COEFF_Y_B * signed(colb), 32);
      Cb := resize(COEFF_CB_R * signed(colr) - COEFF_CB_G * signed(colg) + COEFF_CB_B * signed(colb), 32);
      Cr := resize(COEFF_CR_R * signed(colr) - COEFF_CR_G * signed(colg) - COEFF_CR_B * signed(colb), 32);

      if   ( Y >= COEFF_Y_LOW)  and ( Y <= COEFF_Y_HIGH)
       and (Cb >= COEFF_CB_LOW) and (Cb <= COEFF_CB_HIGH)
       and (Cr >= COEFF_CR_LOW) and (Cr <= COEFF_CR_HIGH) then
              r_next.skin <= "1";
	    else
              r_next.skin <= "0";
      end if; 
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
