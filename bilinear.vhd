library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity bilinear is
  
  generic (
    REF_BITS : natural := 8;
    FRAC_BITS : natural := 4
    );

  port (
    a : in signed((REF_BITS-1) downto 0);
    b : in signed((REF_BITS-1) downto 0);
    c : in signed((REF_BITS-1) downto 0);
    d : in signed((REF_BITS-1) downto 0);    

    rx : in unsigned((FRAC_BITS-1) downto 0);
    ry : in unsigned((FRAC_BITS-1) downto 0);

    o : out signed((REF_BITS+FRAC_BITS-1) downto 0)
    );

end bilinear;

architecture arch of bilinear is
  
  signal ba   : signed((REF_BITS+1)-1 downto 0);
  signal ca   : signed((REF_BITS+1)-1 downto 0);
  signal dabc : signed((REF_BITS+1)-1 downto 0);

  signal s1 : signed((REF_BITS+1+FRAC_BITS+1-1) downto 0);
  signal s2 : signed((REF_BITS+1+FRAC_BITS+1-1) downto 0);
  signal s3 : signed((REF_BITS+1+FRAC_BITS+1+FRAC_BITS+1-1) downto 0);

  signal signed_rx : signed((FRAC_BITS+1)-1 downto 0);
  signal signed_ry : signed((FRAC_BITS+1)-1 downto 0);    
  signal signed_rxry : signed((FRAC_BITS+1+FRAC_BITS+1)-1 downto 0);

  signal res : signed((REF_BITS+1+FRAC_BITS+1-1) downto 0);
begin  -- arch

  signed_rx <= signed("0" & rx);
  signed_ry <= signed("0" & ry);
  
  signed_rxry <= signed_rx*signed_ry;

  ba <= resize(b,REF_BITS+1) - resize(a,REF_BITS+1);
  ca <= resize(c,REF_BITS+1) - resize(a,REF_BITS+1);

  dabc <= resize(a,REF_BITS+1) - resize(b,REF_BITS+1) - resize(c,REF_BITS+1) + resize(d,REF_BITS+1);

  s1 <= ba*signed_rx;
  s2 <= ca*signed_ry;
  
  s3 <= dabc*signed_rxry;
  
  res <= a&to_signed(0,FRAC_BITS) + s1 +s2 +s3(s3'left-1 downto FRAC_BITS);
  o <= res(res'left-2 downto 0);
end arch;
