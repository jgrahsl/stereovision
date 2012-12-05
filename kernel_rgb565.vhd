library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity kernel_rgb565 is
  generic (
    ID     : integer range 0 to 63 := 0;
    FORK   : natural range 0 to 1  := 0;
    KERNEL : natural range 1 to 5  := 5
    );
  port (
    pipe_in    : in    pipe_t;
    pipe_out   : out   pipe_t;
    pipe_out_2 : out   pipe_t;
    stall_in   : in    std_logic;
    stall_in_2 : in    std_logic := '0';
    stall_out  : out   std_logic;
    rgb565_2d_in : in  rgb565_2d_t
    );
end kernel_rgb565;

architecture impl of kernel_rgb565 is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;
  signal stage_2      : stage_t;
  signal stage_2_next : stage_t;
  signal src_valid  : std_logic;
  signal issue      : std_logic;
  signal stall      : std_logic;

begin
  issue <= '0';

  fork_gen : if FORK = 0 generate
    connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);
  end generate fork_gen;

  fork_gen_else : if FORK = 1 generate
    connect_pipe_fork(clk, rst, pipe_in, pipe_out, pipe_out_2, stall_in, stall_in_2 , stall_out, stage, stage_2, src_valid, issue, stall);
  end generate fork_gen_else;

  process(pipe_in, rgb565_2d_in, rst, src_valid)
    variable win  : rgb565_2d_t;
    variable sum1 : natural range 0 to (KERNEL*KERNEL)*256;
    variable sum2 : natural range 0 to (KERNEL*KERNEL)*256;
  begin  -- process
    stage_next <= pipe_in.stage;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------
    win        := rgb565_2d_in;
    sum1       := 0;
    sum2       := 0;
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

    sum1 := to_integer(unsigned(win(0*3+0)(15 downto 8))) +
            to_integer(unsigned(win(0*3+1)(15 downto 8))) +
            to_integer(unsigned(win(0*3+2)(15 downto 8))) +

            to_integer(unsigned(win(1*3+0)(15 downto 8))) +
            to_integer(unsigned(win(1*3+1)(15 downto 8))) +            
            to_integer(unsigned(win(1*3+2)(15 downto 8))) +

            to_integer(unsigned(win(2*3+0)(15 downto 8))) +
            to_integer(unsigned(win(2*3+1)(15 downto 8))) +
            to_integer(unsigned(win(2*3+2)(15 downto 8)));

    sum2 := to_integer(unsigned(win(0*3+0)(7 downto 0))) +
            to_integer(unsigned(win(0*3+1)(7 downto 0))) +
            to_integer(unsigned(win(0*3+2)(7 downto 0))) +

            to_integer(unsigned(win(1*3+0)(7 downto 0))) +
            to_integer(unsigned(win(1*3+1)(7 downto 0))) +                        
            to_integer(unsigned(win(1*3+2)(7 downto 0))) +

            to_integer(unsigned(win(2*3+0)(7 downto 0))) +
            to_integer(unsigned(win(2*3+1)(7 downto 0))) +
            to_integer(unsigned(win(2*3+2)(7 downto 0)));

-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------    
--    if (sum/21) > 162 and (sum/21) < 182 then
----      stage_next.data_8   <= std_logic_vector(to_unsigned(sum/16,8));
--      stage_next.data_8   <= (others => '1');
--      stage_next.data_1   <= (others => '1');
--    else
--      stage_next.data_8   <= (others => '0');
--      stage_next.data_1   <= (others => '0');      
--    end if;
    stage_next.data_8   <= std_logic_vector(to_unsigned(sum1/9,8));    
    stage_next.data_565 <= std_logic_vector(to_unsigned(sum1/9, 8)) & std_logic_vector(to_unsigned(sum2/9, 8));
-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_MORPH;
    end if;
    if rst = '1' then
      stage_next <= NULL_STAGE;
    end if;

    stage_2_next <= stage_next;
    stage_2_next.data_8 <= std_logic_vector(to_unsigned(sum2/9,8));    
  end process;

  proc_clk : process(pipe_in, clk, rst, stall)
  begin
    if rising_edge(clk) and (stall = '0' or rst = '1') then
      if (pipe_in.cfg(ID).enable = '1') then
        stage <= stage_next;
        stage_2 <= stage_2_next;        
      else
        stage <= pipe_in.stage;
        stage_2 <= pipe_in.stage;        
      end if;
    end if;
  end process;

end impl;


