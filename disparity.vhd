library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity disparity is
  generic (
    ID     : integer range 0 to 63 := 0;
    KERNEL : natural range 1 to 5  := 5
    );
  port (
    pipe_in   : in  pipe_t;
    pipe_out  : out pipe_t;
    stall_in  : in  std_logic;
    stall_out : out std_logic;
    mono_2d_l : in  mono_2d_t;
    mono_2d_r : in  mono_2d_t
    );
end disparity;

architecture impl of disparity is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;
  signal src_valid  : std_logic;
  signal issue      : std_logic;
  signal stall      : std_logic;

  type mono_2d_delay_t is array (0 to 7) of mono_2d_t;

  type reg_t is record
--    cols : natural range 0 to WIDTH-1;
--    rows : natural range 0 to HEIGHT-1;
    delay : mono_2d_delay_t;
  end record;

  signal r      : reg_t;
  signal r_next : reg_t;

  procedure init (variable v : inout reg_t) is
  begin
--    v.cols := 0;
--    v.rows := 0;
    v.delay := (others => (others => (others => '0')));
  end init;

  -- purpose: hamming distance calculation
  function hamming (
    signal l : mono_2d_t;
    signal r : mono_2d_t)
    return natural is
    variable sum : natural range 0 to KERNEL*KERNEL-1 := 0;
  begin  -- hamming
    sum := 0;
    for i in 0 to KERNEL*KERNEL-1 loop
      if l(i) = r(i) then
        sum := sum + 0;
      else
        sum := sum + 1;
      end if;
    end loop;  -- i
    return sum;
  end hamming;
begin
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);

  process(pipe_in, rst, src_valid, mono_2d_l, mono_2d_r)
    variable minimum_index : natural range 0 to (KERNEL*KERNEL);
    variable minimum       : natural range 0 to (KERNEL*KERNEL);
    variable current       : natural range 0 to (KERNEL*KERNEL);
    variable v             : reg_t;
    variable sum : natural range 0 to KERNEL*KERNEL := 0;
  begin  -- process
    stage_next <= pipe_in.stage;
    v          := r;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------
    for b in 0 to 6 loop
      v.delay(b+1) := r.delay(b);
    end loop;  -- b
    v.delay(0) := mono_2d_r;

    minimum       := KERNEL*KERNEL;
    minimum_index := 7;

    current := hamming(mono_2d_l, mono_2d_r);
    if current < minimum then
      minimum       := current;
      minimum_index := 0;
    end if;

    for i in 0 to 7 loop

      sum := 0;
      for j in 0 to KERNEL*KERNEL-1 loop
        if mono_2d_l(j) = r.delay(i)(j) then
          sum := sum + 0;
        else
          sum := sum + 1;
        end if;
      end loop;  -- i

      current := sum;
      if current < minimum then
        minimum       := current;
        minimum_index := i+1;
      end if;
    end loop;

    stage_next.data_8 <= std_logic_vector(to_unsigned(minimum_index, 3) & "00000");

-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_DISPARITY;
    end if;
    if rst = '1' then
      stage_next <= NULL_STAGE;
    end if;
-------------------------------------------------------------------------------
-- Next
-------------------------------------------------------------------------------    
    r_next <= v;    
  end process;

  proc_clk : process(clk, rst, stall, pipe_in, stage_next)
  begin
    if rising_edge(clk) and (stall = '0' or rst = '1') then
      if (pipe_in.cfg(ID).enable = '1') then
        stage <= stage_next;
      else
        stage <= pipe_in.stage;
      end if;
      r <= r_next;
    end if;
  end process;

end impl;


