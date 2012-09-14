library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity mcb_feed is
  generic (
    ID : integer range 0 to 63 := 0);
  port (
    pipe_in  : in  pipe_t;
    pipe_out : out pipe_t;

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
  end record;
  signal r                   :       reg_t;
  signal r_next              :       reg_t;
  procedure init (variable v : inout reg_t) is
  begin
    v.sel_is_high := '1';
  end init;

  signal avail         : std_logic;
  signal selected_word : std_logic_vector(15 downto 0);
begin
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stage, src_valid, issue, stall);

  avail <= '1' when p0_fifo.stall = '0' and p1_fifo.stall = '0' and pipe_in.cfg(ID).enable = '1' else '0';

  p0_fifo.en  <= avail and not r.sel_is_high and not stall;
  p0_fifo.clk <= clk;

  p1_fifo.en  <= avail and not stall;
  p1_fifo.clk <= clk;

  selected_word <= p0_fifo.data(31 downto 16) when r.sel_is_high = '0' else
                   p0_fifo.data(15 downto 0);

  process (pipe_in)
    variable v          : reg_t;
    variable brightness : unsigned(7 downto 0);
  begin
    stage_next <= pipe_in.stage;
    v          := r;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------    

    stage_next.valid <= avail;
    stage_next.init  <= '0';
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

  proc_clk : process(pipe_in)
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
