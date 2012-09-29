library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity color_mux is
  generic (
    ID   : integer range 0 to 63 := 0;
    MODE : natural range 1 to 4  := 1
    );
  port (
    pipe_in   : in  pipe_t;
    pipe_out  : out pipe_t;
    stall_in  : in  std_logic;
    stall_out : out std_logic);
end color_mux;

architecture impl of color_mux is

-------------------------------------------------------------------------------
-- Pipe
-------------------------------------------------------------------------------
  
  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;
  signal src_valid  : std_logic;
  signal issue      : std_logic;
  signal stall      : std_logic;

-------------------------------------------------------------------------------
-- Register
-------------------------------------------------------------------------------

begin
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);

  process (pipe_in, rst, src_valid)
  begin
    stage_next <= pipe_in.stage;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------
    if MODE = 1 then
      if pipe_in.stage.data_1 = "1" then
        stage_next.data_8   <= (others => '1');
        stage_next.data_565 <= (others => '1');
        stage_next.data_888 <= (others => '1');
      else
        stage_next.data_8   <= (others => '0');
        stage_next.data_565 <= (others => '0');
        stage_next.data_888 <= (others => '0');
      end if;
    end if;

    if MODE = 2 then
      stage_next.data_1   <= pipe_in.stage.data_8(7 downto 7);
      stage_next.data_565 <= pipe_in.stage.data_8(7 downto 3) & pipe_in.stage.data_8(7 downto 2) & pipe_in.stage.data_8(7 downto 3);
      stage_next.data_888 <= pipe_in.stage.data_8 & pipe_in.stage.data_8 & pipe_in.stage.data_8;
    end if;

-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_COLMUX;
    end if;
    if rst = '1' then
      stage_next <= NULL_STAGE;
    end if;
-------------------------------------------------------------------------------
-- Next
-------------------------------------------------------------------------------    
  end process;

  proc_clk : process(pipe_in, clk, rst, stall, stage_next)
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
