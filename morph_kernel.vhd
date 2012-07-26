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
    mono_2d_in : in  mono_2d_t
    );
end morph_kernel;

architecture impl of morph_kernel is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;

begin
  clk <= pipe_in.ctrl.clk;
  rst <= pipe_in.ctrl.rst;

  pipe_out.ctrl  <= pipe_in.ctrl;
  pipe_out.cfg   <= pipe_in.cfg;
  pipe_out.stage <= stage;

  process(pipe_in, mono_2d_in)
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
    sum        := to_integer(unsigned(win(0)(1))) +
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
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------    
    if (sum >= (to_integer(unsigned(pipe_in.cfg(ID).p(0))))) then
      stage_next.data_1   <= (others => '1');
--      stage_next.data_8   <= (others => '1');
--      stage_next.data_565 <= (others => '1');
--      stage_next.data_888 <= (others => '1');
    else
      stage_next.data_1   <= (others => '0');
--      stage_next.data_8   <= (others => '0');
--      stage_next.data_565 <= (others => '0');
--      stage_next.data_888 <= (others => '0');
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

  proc_clk : process(pipe_in)
  begin
    if rising_edge(clk) then
      if (pipe_in.cfg(ID).enable = '1') then
        stage <= stage_next;
      else
        stage <= pipe_in.stage;
      end if;
    end if;
  end process;

end impl;


