library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity kernel_8 is
  generic (
    ID     : integer range 0 to 63 := 0;
    KERNEL : natural range 1 to 5  := 5
    );
  port (
    pipe_in    : in  pipe_t;
    pipe_out   : out pipe_t;
    stall_in   : in  std_logic;
    stall_out  : out std_logic;
    gray8_2d_in : in  gray8_2d_t
    );
end kernel_8;

architecture impl of kernel_8 is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;
  signal src_valid  : std_logic;
  signal issue      : std_logic;
  signal stall      : std_logic;

begin
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);

  process(pipe_in, gray8_2d_in, rst, src_valid)
    variable win : gray8_2d_t;
    variable sum : natural range 0 to (KERNEL*KERNEL)*256;
  begin  -- process
    stage_next <= pipe_in.stage;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------
    win        := gray8_2d_in;
    sum        := 0;
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
    sum        := to_integer(unsigned(win(0*5+1))) +
                  to_integer(unsigned(win(0*5+2))) +
                  to_integer(unsigned(win(0*5+3))) +

                  to_integer(unsigned(win(1*5+0))) +
                  to_integer(unsigned(win(1*5+1))) +
                  to_integer(unsigned(win(1*5+2))) +                  
                  to_integer(unsigned(win(1*5+3))) +
                  to_integer(unsigned(win(1*5+4))) +

                  to_integer(unsigned(win(2*5+0))) +
                  to_integer(unsigned(win(2*5+1))) +
                  to_integer(unsigned(win(2*5+2))) +                  
                  to_integer(unsigned(win(2*5+3))) +
                  to_integer(unsigned(win(2*5+4))) +

                  to_integer(unsigned(win(3*5+0))) +
                  to_integer(unsigned(win(3*5+1))) +
                  to_integer(unsigned(win(3*5+2))) +                  
                  to_integer(unsigned(win(3*5+3))) +
                  to_integer(unsigned(win(3*5+4))) +

                  to_integer(unsigned(win(4*5+1))) +
                  to_integer(unsigned(win(4*5+2))) +                  
                  to_integer(unsigned(win(4*5+3)));
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------    
    if (sum/21) > 162 and (sum/21) < 182 then
--      stage_next.data_8   <= std_logic_vector(to_unsigned(sum/16,8));
      stage_next.data_8   <= (others => '1');
      stage_next.data_1   <= (others => '1');
    else
      stage_next.data_8   <= (others => '0');
      stage_next.data_1   <= (others => '0');      
    end if;

-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_MORPH;
    end if;
    if rst = '1' then
      stage_next <= NULL_STAGE;
    end if;
  end process;

  proc_clk : process(pipe_in, clk, rst, stall)
  begin
    if rising_edge(clk) and (stall = '0' or rst = '1') then
      if (pipe_in.cfg(ID).enable = '1') then
        stage <= stage_next;
      else
        stage <= pipe_in.stage;
      end if;
    end if;
  end process;

end impl;


