library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity mcb_feed is
  generic (
    ID : integer range 0 to 63 := 0);
  port (
    pipe_in  : inout  pipe_t;
    pipe_out : inout pipe_t;
    stall_in : in std_logic;
    stall_out : out std_logic;
    p0_fifo : inout mcb_fifo_t;
    p1_fifo : inout mcb_fifo_t
    );
end mcb_feed;

architecture impl of mcb_feed is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t; 
  signal src_valid  : std_logic;
  signal issue      : std_logic;
  signal stall      : std_logic;

  type reg_t is record
    sel_is_high : std_logic;
    stop : std_logic;
  end record;
  signal r                   :       reg_t;
  signal r_next              :       reg_t;
  procedure init (variable v : inout reg_t) is
  begin
    v.sel_is_high := '1';
    v.stop := '0';
  end init;

  signal avail         : std_logic;
  signal selected_word : std_logic_vector(15 downto 0);
begin
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);

  avail <= not p0_fifo.stall and not p1_fifo.stall and pipe_in.cfg(ID).enable and pipe_in.cfg(ID).p(0)(0) and not stall;

  p0_fifo.en  <= avail and not r.sel_is_high;
  p0_fifo.clk <= clk;

  p1_fifo.en  <= avail;
  p1_fifo.clk <= clk;

  selected_word <= p0_fifo.data(31 downto 16) when r.sel_is_high = '0' else
                   p0_fifo.data(15 downto 0);

  process (pipe_in, r, rst, avail, p1_fifo, selected_word)
    variable v          : reg_t;
    variable brightness : unsigned(7 downto 0);
  begin
    stage_next <= pipe_in.stage;
    v          := r;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------    

    stage_next.valid <= avail;
--    stage_next.init  <= '0';
    stage_next.aux   <= p1_fifo.data;

    brightness := ("00" & unsigned(selected_word(15 downto 11)) & "0") +
                  ("00" & unsigned(selected_word(10 downto 5))) +
                  ("00" & unsigned(selected_word(4 downto 0)) & "0");

    stage_next.data_1   <= (others => '0');
    stage_next.data_8   <= std_logic_vector(brightness);
    stage_next.data_565 <= selected_word;
    stage_next.data_888 <= selected_word(15 downto 11) & "000" &
                           selected_word(10 downto 5) & "00" &
                           selected_word(4 downto 0) & "000";

    if avail = '1' then
      if v.sel_is_high = '1' then
        v.sel_is_high := '0';
      else
        v.sel_is_high := '1';
      end if;
    end if;
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_MCBFEED;
    end if;
    if rst = '1' then
      stage_next <= NULL_STAGE;
      init(v);
    end if;
    r_next <= v;
  end process;

  proc_clk : process(clk, rst, stall, pipe_in, stage_next, r_next)
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
