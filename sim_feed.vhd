library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity sim_feed is
  generic (
    ID : integer range 0 to 63 := 0);
  port (
    pipe_in  : in  pipe_t;
    pipe_out : out pipe_t;

    p0_fifo : inout sim_fifo_t);
end sim_feed;

architecture impl of sim_feed is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t; 
  signal src_valid  : std_logic;
  signal issue      : std_logic;
  signal stall      : std_logic;

  type reg_t is record
    temp : std_logic;
  end record;
  signal r                   :       reg_t;
  signal r_next              :       reg_t;
  procedure init (variable v : inout reg_t) is
  begin
    v.temp := '1';
  end init;

  signal avail         : std_logic;
  signal selected_word : std_logic_vector(15 downto 0);
begin
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stage, src_valid, issue, stall);

  p0_fifo.clk <= clk;

  -- Handshake loop
  avail <= '1' when p0_fifo.stall = '0' and pipe_in.cfg(ID).enable = '1' else '0';
  p0_fifo.en  <= avail and not stall and not rst;   -- external signal needs to be blocked
                                                    -- by stall
  process (pipe_in)
    variable v          : reg_t;
    variable brightness : unsigned(7 downto 0);
  begin
    stage_next <= pipe_in.stage;
    v          := r;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------    

    stage_next.valid <= avail;          -- reg does not need to be blocked by stall
    stage_next.init  <= '0';
    stage_next.aux   <= (others => '0');

    stage_next.data_1   <= p0_fifo.data(0 downto 0);
    stage_next.data_8   <= p0_fifo.data((8+1)-1 downto (1));
    stage_next.data_565 <= p0_fifo.data((16+8+1)-1 downto (8+1));
    stage_next.data_888 <= p0_fifo.data((24+16+8+1)-1 downto (16+8+1));
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_SIMFEED;
    end if;
    if rst = '1' then
      stage_next <= NULL_STAGE;
      init(v);
    end if;
    r_next <= v;
  end process;

  proc_clk : process(clk, stall, pipe_in, stage_next, r_next)
  begin
    if rising_edge(clk) and stall = '0' then
      if (pipe_in.cfg(ID).enable = '1') then
        stage <= stage_next;
      else
        stage <= pipe_in.stage;
      end if;
      r <= r_next;
    end if;
  end process;

end impl;
