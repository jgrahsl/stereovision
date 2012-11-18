#!/usr/bin/python
import sys

comma = 4
deci = 6
kernel = 9
gridx = 3
gridy = 3



skip_l = (2**gridx)-1
skip_c = (2**gridy)-1
df = "{:0" + str(deci) + "b}"
cf = "{:0" + str(comma) + "b}"

fx = open("mx1.csv","r")
fy = open("my1.csv","r")

def crop(v):
    if v > ((kernel-1)/2):
        v = ((kernel-1)/2)
    if v < (-(kernel-1)/2):
        v = -((kernel-1)/2)

    return v

def bias(v):
    v = v + ((kernel-1)/2)
    return v

cx = fx.readline().strip()
cy = fy.readline().strip()

line = 0
col = 0
skipl = 0
skipc = 0



print """
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.cam_pkg.all;

entity romdata is
  generic (ADR_BITS  : integer;
           DATA_BITS : integer);             -- for compatibility
  port (
    clk : in  std_logic;
    a   : in  std_logic_vector(ADR_BITS-1 downto 0);
    q   : out std_logic_vector(DATA_BITS-1 downto 0));
end romdata;

architecture rtl of romdata is
    ATTRIBUTE ram_extract: string;
    ATTRIBUTE ram_extract OF q: SIGNAL IS "yes";
    ATTRIBUTE ram_style: string;
    ATTRIBUTE ram_style OF q: SIGNAL IS "block";
  
  signal areg : std_logic_vector((GRIDX_BITS+GRIDY_BITS-1) downto 0);  -- GRIDX+GRIDY-1
begin

  process(clk)
  begin
    if rising_edge(clk) then
      areg <= a(areg'high downto areg'low);
    end if;
  end process;

  process(areg)
  begin
    case areg is
      -- GRIDY+GRIDX --    REFY+REFX
"""
while cx != "" and cy != "":
    if skipl == 0:
        lx  = cx.split(",")
        ly  = cy.split(",")

        for i in range(len(lx)):

            if skipc == 0:
        
                x = lx[i].rstrip(",")
                x = float(x)
                x = crop(x)       
                x = bias(x)
        
                c = x-int(x)
                d = x - c
                xs = df.format(int(d)) + cf.format(int(c*(2**comma)))

                y = ly[i].rstrip(",")
                y = float(y)
                y = crop(y)       
                y = bias(y)
            
                c = y-int(y)
                d = y - c
                ys = df.format(int(d)) + cf.format(int(c*(2**comma)))

                print "when \"" + "{:06b}".format(line) + "{:06b}".format(col) + "\" => q <= \"" + ys+""+xs + "\";"
#            #           sys.stdin.readline()
                col = col + 1 

            skipc = skipc + 1
            if skipc > skip_c:
                skipc = 0

        line = line + 1
        col = 0


    skipl = skipl + 1
    if skipl > skip_l:
        skipl = 0
    cx = fx.readline().strip()
    cy = fy.readline().strip()

print """
      when others => q <=   "00000000000000000000";
    end case;
  end process;

end rtl;
"""
