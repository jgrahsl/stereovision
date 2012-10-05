library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity morph_kernel is
  generic (
    ID     : integer range 0 to 63 := 0;
    KERNEL : natural range 1 to 5  := 5
    );
  port (
    pipe_in    : in  pipe_t;
    pipe_out   : out pipe_t;
    stall_in   : in  std_logic;
    stall_out  : out std_logic;
    mono_2d_in : in  mono_2d_t
    );
end morph_kernel;

architecture impl of morph_kernel is

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

  process(pipe_in, mono_2d_in, rst, src_valid)
    variable win : mono_2d_t;
    variable sum : natural range 0 to (KERNEL*KERNEL);
  begin  -- process
    stage_next <= pipe_in.stage;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------
    win        := mono_2d_in;
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
    if (sum >= (to_integer(unsigned(pipe_in.cfg(ID).p(0))))) then
      stage_next.data_1 <= (others => '1');
--      stage_next.data_8   <= (others => '1');
--      stage_next.data_565 <= (others => '1');
--      stage_next.data_888 <= (others => '1');
    else
      stage_next.data_1 <= (others => '0');
--      stage_next.data_8   <= (others => '0');
--      stage_next.data_565 <= (others => '0');
--      stage_next.data_888 <= (others => '0');
    end if;

    if (pipe_in.cfg(ID).p(1)(0) = '1') then 
      stage_next.data_1 <= (others => '0');    
      if win(2*5+2) = "1" then
        stage_next.data_1 <= (others => '1');      
      end if;
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


