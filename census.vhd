library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity census is
  generic (
    ID     : integer range 0 to 63 := 0;
    KERNEL : natural               := 5
    );
  port (
    pipe_in      : in  pipe_t;
    pipe_out     : out pipe_t;
    stall_in     : in  std_logic;
    stall_out    : out std_logic;
    rgb565_2d_in : in  rgb565_2d_t;
    mono_2d_l    : out mono_2d_t;
    mono_2d_r    : out mono_2d_t
    );
end census;

architecture impl of census is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;
  signal src_valid  : std_logic;
  signal issue      : std_logic;
  signal stall      : std_logic;

  signal mono_2d_l_next : mono_2d_t;
  signal mono_2d_r_next : mono_2d_t;

  constant HALF_KERNEL : natural := ((KERNEL-1)/2);
begin
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);

  process (pipe_in, src_valid, rst, rgb565_2d_in)
  begin  -- process
    stage_next     <= pipe_in.stage;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------
    mono_2d_l_next <= (others => "0");
    for i in 0 to KERNEL-1 loop
      for j in 0 to KERNEL-1 loop
        if rgb565_2d_in(i+j*KERNEL)(15 downto 8) > rgb565_2d_in(HALF_KERNEL+HALF_KERNEL*KERNEL)(15 downto 8) then
          mono_2d_l_next(i+j*KERNEL) <= "1";
        end if;
      end loop;  -- j
    end loop;  -- i

    mono_2d_r_next <= (others => "0");
    for i in 0 to KERNEL-1 loop
      for j in 0 to KERNEL-1 loop
        if rgb565_2d_in(i+j*KERNEL)(7 downto 0) > rgb565_2d_in(HALF_KERNEL+HALF_KERNEL*KERNEL)(7 downto 0) then
          mono_2d_r_next(i+j*KERNEL) <= "1";
        end if;
      end loop;  -- j
    end loop;  -- i
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------    
-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_CENSUS;
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
      mono_2d_l <= mono_2d_l_next;
      mono_2d_r <= mono_2d_r_next;
    end if;
  end process;

end impl;


