library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity win_test_8 is
  generic (
    ID     : integer range 0 to 63 := 0;
    KERNEL : natural range 1 to 5  := 5
    );
  port (
    pipe_in     : in  pipe_t;
    pipe_out    : out pipe_t;
    stall_in    : in  std_logic;
    stall_out   : out std_logic;
    gray8_2d_in : in  gray8_2d_t
    );
end win_test_8;

architecture impl of win_test_8 is

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

  process (pipe_in, src_valid, rst, gray8_2d_in)
    variable sum : natural range 0 to (KERNEL*KERNEL*(2**gray8_t'length));
    variable u   : unsigned(23 downto 0);
  begin  -- process
    stage_next <= pipe_in.stage;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------
    sum        := 0;
    ---------------------------------------------------------------------------
    -- Square
    ---------------------------------------------------------------------------
    --for i in 0 to (KERNEL-1) loop
    --  for j in 0 to (KERNEL-1) loop
    --    sum := sum + to_integer(unsigned(gray8_2d_in(i)(j)));
    --  end loop;
    --end loop;
    -------------------------------------------------------------------------------
    -- Octagon
    -------------------------------------------------------------------------------
    sum        := to_integer(unsigned(gray8_2d_in(0)(1))) +
                  to_integer(unsigned(gray8_2d_in(0)(2))) +
                  to_integer(unsigned(gray8_2d_in(0)(3))) +

                  to_integer(unsigned(gray8_2d_in(1)(0))) +
                  to_integer(unsigned(gray8_2d_in(1)(1))) +
                  to_integer(unsigned(gray8_2d_in(1)(2))) +
                  to_integer(unsigned(gray8_2d_in(1)(3))) +
                  to_integer(unsigned(gray8_2d_in(1)(4))) +

                  --to_integer(unsigned(gray8_2d_in(2)(0))) +
                  --to_integer(unsigned(gray8_2d_in(2)(1))) +
                  --to_integer(unsigned(gray8_2d_in(2)(3))) +
                  --to_integer(unsigned(gray8_2d_in(2)(4))) +

                  to_integer(unsigned(gray8_2d_in(3)(0))) +
                  to_integer(unsigned(gray8_2d_in(3)(1))) +
                  to_integer(unsigned(gray8_2d_in(3)(2))) +
                  to_integer(unsigned(gray8_2d_in(3)(3))) +
                  to_integer(unsigned(gray8_2d_in(3)(4))) +

                  to_integer(unsigned(gray8_2d_in(4)(1))) +
                  to_integer(unsigned(gray8_2d_in(4)(2))) +
                  to_integer(unsigned(gray8_2d_in(4)(3)));
    
    u := to_unsigned(sum, 24);

    stage_next.data_8 <= std_logic_vector(u(7+4 downto 0+4));

    stage_next.data_8 <= gray8_2d_in(2)(2);
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------    
--    if (sum > 0) then
--      stage_next.data_1 <= (others => '1');
--      stage_next.data_8   <= (others => '1');
--      stage_next.data_565 <= (others => '1');
--      stage_next.data_888 <= (others => '1');
--  else
--      stage_next.data_1 <= (others => '0');
--      stage_next.data_8   <= (others => '0');
--      stage_next.data_565 <= (others => '0');
--      stage_next.data_888 <= (others => '0');
--  end if;
-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_WIN_TEST_8;
    end if;
    if rst = '1' then
      stage_next <= NULL_STAGE;
    end if;
  end process;

  proc_clk : process(clk, rst, stall, pipe_in, stage_next)
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


