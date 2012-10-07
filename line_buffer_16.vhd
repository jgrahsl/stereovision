library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity line_buffer_16 is
  generic (
    ID        : integer range 0 to 63   := 0;
    NUM_LINES : natural                 := 3;
    WIDTH     : natural range 1 to 2048 := 2048;
    HEIGHT    : natural range 1 to 2048 := 2048);
  port (
    pipe_in       : in  pipe_t;
    pipe_out      : out pipe_t;
    stall_in      : in  std_logic;
    stall_out     : out std_logic;
    rgb565_1d_out : out rgb565_1d_t
    );
end line_buffer_16;

architecture impl of line_buffer_16 is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;
  signal src_valid  : std_logic;
  signal issue      : std_logic;
  signal stall      : std_logic;

  type reg_t is record
    cols : natural range 0 to WIDTH;
    rows : natural range 0 to HEIGHT;
    sel  : natural range 0 to (NUM_LINES-1);
  end record;

  signal adr     : std_logic_vector(10 downto 0);
  type   q_t is array (0 to (NUM_LINES-1)) of rgb565_t;
  signal q       : q_t;
  signal qd      : q_t;
  signal qi      : q_t;
  signal stalled : std_logic := '0';
  signal wren    : std_logic_vector((NUM_LINES-1) downto 0);

  signal r_r    : reg_t;
  signal r      : reg_t;
  signal r_next : reg_t;

  procedure init (variable v : inout reg_t) is
  begin
    v.sel  := 0;
    v.cols := 0;
    v.rows := 0;
  end init;
  
begin
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stall_in, stall_out, stage, src_valid, issue, stall);

  rams : for i in 0 to (NUM_LINES-1) generate
    kernel_rams : entity work.bit_ram
      generic map (
        ADDR_BITS  => 11,
        WIDTH_BITS => rgb565_t'length)
      port map (
        addra => adr,
        clka  => clk,                     -- [in]
        dina  => pipe_in.stage.data_565,  -- [in]
        wea   => wren(i downto i),        -- [in]
        douta => qi(i));                  -- [out]    
  end generate rams;

  wr_enables : for i in 0 to (NUM_LINES-1) generate
    wren(i) <= '1' when src_valid = '1' and r.sel = i else '0';
  end generate wr_enables;

  process(pipe_in, stage, r, r_r, src_valid, rst, q)
    variable v : reg_t;
  begin  -- process
    stage_next <= pipe_in.stage;
    v          := r;
-------------------------------------------------------------------------------
-- Counters
-------------------------------------------------------------------------------
    if src_valid = '1' then
      if r.cols = (WIDTH-1) then
        v.cols := 0;

        if r.sel < (NUM_LINES-1) then
          v.sel := r.sel + 1;
        else
          v.sel := 0;
        end if;

        if (r.rows = (HEIGHT-1)) then
          v.rows := 0;
          v.sel  := 0;
        else
          v.rows := r.rows + 1;
        end if;
      else
        v.cols := v.cols + 1;
      end if;
    end if;
-------------------------------------------------------------------------------
-- Generate data from pipeline
-------------------------------------------------------------------------------
    rgb565_1d_out <= (others => (others => '0'));

    for i in 0 to NUM_LINES-1 loop
      rgb565_1d_out(i) <= (others => '0');
    end loop;  -- i        

    case NUM_LINES is
      when 3 =>
        if r_r.rows = 0 then
          rgb565_1d_out(1) <= (others => '0');
          rgb565_1d_out(2) <= (others => '0');
        elsif r_r.rows = 1 then
          rgb565_1d_out(1) <= q(0);
          rgb565_1d_out(2) <= (others => '0');
        elsif r_r.rows = 2 then
          rgb565_1d_out(1) <= q(1);
          rgb565_1d_out(2) <= q(0);
        else
          if r_r.sel = 0 then
            rgb565_1d_out(1) <= q(2); rgb565_1d_out(2) <= q(1);
          elsif r_r.sel = 1 then
            rgb565_1d_out(1) <= q(0); rgb565_1d_out(2) <= q(2);
          elsif r_r.sel = 2 then
            rgb565_1d_out(1) <= q(1); rgb565_1d_out(2) <= q(0);
          end if;
        end if;
      when 5 =>
        if r_r.rows = 1 then
          gray8_1d_out(1) <= q(0);
        elsif r_r.rows = 2 then
          gray8_1d_out(1) <= q(1);
          gray8_1d_out(2) <= q(0);
        elsif r_r.rows = 3 then
          gray8_1d_out(1) <= q(2);
          gray8_1d_out(2) <= q(1);
          gray8_1d_out(3) <= q(0);        
        else
          if r_r.sel = 0 then
            rgb565_1d_out(1) <= q(4); rgb565_1d_out(2) <= q(3); rgb565_1d_out(3) <= q(2); rgb565_1d_out(4) <= q(1);
          elsif r_r.sel = 1 then
            rgb565_1d_out(1) <= q(0); rgb565_1d_out(2) <= q(4); rgb565_1d_out(3) <= q(3); rgb565_1d_out(4) <= q(2);
          elsif r_r.sel = 2 then
            rgb565_1d_out(1) <= q(1); rgb565_1d_out(2) <= q(0); rgb565_1d_out(3) <= q(4); rgb565_1d_out(4) <= q(3);
          elsif r_r.sel = 3 then
            rgb565_1d_out(1) <= q(2); rgb565_1d_out(2) <= q(1); rgb565_1d_out(3) <= q(0); rgb565_1d_out(4) <= q(4);
          elsif r_r.sel = 4 then
            rgb565_1d_out(1) <= q(3); rgb565_1d_out(2) <= q(2); rgb565_1d_out(3) <= q(1); rgb565_1d_out(4) <= q(0);
          end if;
        end if;

      when 9 =>
        if r_r.rows = 1 then
          gray8_1d_out(1) <= q(0);
        elsif r_r.rows = 2 then
          gray8_1d_out(1) <= q(1);
          gray8_1d_out(2) <= q(0);
        elsif r_r.rows = 3 then
          gray8_1d_out(1) <= q(2);
          gray8_1d_out(2) <= q(1);
          gray8_1d_out(3) <= q(0);        
        elsif r_r.rows = 4 then
          gray8_1d_out(1) <= q(3);
          gray8_1d_out(2) <= q(2);
          gray8_1d_out(3) <= q(1);
          gray8_1d_out(4) <= q(0);                  
        elsif r_r.rows = 5 then
          gray8_1d_out(1) <= q(4);
          gray8_1d_out(2) <= q(3);
          gray8_1d_out(3) <= q(2);
          gray8_1d_out(4) <= q(1);
          gray8_1d_out(5) <= q(0);                            
        elsif r_r.rows = 6 then
          gray8_1d_out(1) <= q(5);
          gray8_1d_out(2) <= q(4);
          gray8_1d_out(3) <= q(3);
          gray8_1d_out(4) <= q(2);
          gray8_1d_out(5) <= q(1);
          gray8_1d_out(6) <= q(0);                            
        elsif r_r.rows = 7 then
          gray8_1d_out(1) <= q(6);
          gray8_1d_out(2) <= q(5);
          gray8_1d_out(3) <= q(4);
          gray8_1d_out(4) <= q(3);
          gray8_1d_out(5) <= q(2);                  
          gray8_1d_out(6) <= q(1);                  
          gray8_1d_out(7) <= q(0);                            
        elsif r_r.rows = 8 then
          gray8_1d_out(1) <= q(7);
          gray8_1d_out(2) <= q(6);
          gray8_1d_out(3) <= q(5);
          gray8_1d_out(4) <= q(4);
          gray8_1d_out(5) <= q(3);
          gray8_1d_out(6) <= q(2);
          gray8_1d_out(7) <= q(1);
          gray8_1d_out(8) <= q(0);                            
        else
          if r_r.sel = 0 then
            rgb565_1d_out(1) <= q(8); rgb565_1d_out(2) <= q(7); rgb565_1d_out(3) <= q(6); rgb565_1d_out(4) <= q(5); rgb565_1d_out(5) <= q(4); rgb565_1d_out(6) <= q(3); rgb565_1d_out(7) <= q(2); rgb565_1d_out(8) <= q(1);
          elsif r_r.sel = 1 then
            rgb565_1d_out(1) <= q(0); rgb565_1d_out(2) <= q(8); rgb565_1d_out(3) <= q(7); rgb565_1d_out(4) <= q(6); rgb565_1d_out(5) <= q(5); rgb565_1d_out(6) <= q(4); rgb565_1d_out(7) <= q(3); rgb565_1d_out(8) <= q(2);
          elsif r_r.sel = 2 then
            rgb565_1d_out(1) <= q(1); rgb565_1d_out(2) <= q(0); rgb565_1d_out(3) <= q(8); rgb565_1d_out(4) <= q(7); rgb565_1d_out(5) <= q(6); rgb565_1d_out(6) <= q(5); rgb565_1d_out(7) <= q(4); rgb565_1d_out(8) <= q(3);
          elsif r_r.sel = 3 then
            rgb565_1d_out(1) <= q(2); rgb565_1d_out(2) <= q(1); rgb565_1d_out(3) <= q(0); rgb565_1d_out(4) <= q(8); rgb565_1d_out(5) <= q(7); rgb565_1d_out(6) <= q(6); rgb565_1d_out(7) <= q(5); rgb565_1d_out(8) <= q(4);
          elsif r_r.sel = 4 then
            rgb565_1d_out(1) <= q(3); rgb565_1d_out(2) <= q(2); rgb565_1d_out(3) <= q(1); rgb565_1d_out(4) <= q(0); rgb565_1d_out(5) <= q(8); rgb565_1d_out(6) <= q(7); rgb565_1d_out(7) <= q(6); rgb565_1d_out(8) <= q(5);
          elsif r_r.sel = 5 then
            rgb565_1d_out(1) <= q(4); rgb565_1d_out(2) <= q(3); rgb565_1d_out(3) <= q(2); rgb565_1d_out(4) <= q(1); rgb565_1d_out(5) <= q(0); rgb565_1d_out(6) <= q(8); rgb565_1d_out(7) <= q(7); rgb565_1d_out(8) <= q(6);
          elsif r_r.sel = 6 then
            rgb565_1d_out(1) <= q(5); rgb565_1d_out(2) <= q(4); rgb565_1d_out(3) <= q(3); rgb565_1d_out(4) <= q(2); rgb565_1d_out(5) <= q(1); rgb565_1d_out(6) <= q(0); rgb565_1d_out(7) <= q(8); rgb565_1d_out(8) <= q(7);
          elsif r_r.sel = 7 then
            rgb565_1d_out(1) <= q(6); rgb565_1d_out(2) <= q(5); rgb565_1d_out(3) <= q(4); rgb565_1d_out(4) <= q(3); rgb565_1d_out(5) <= q(2); rgb565_1d_out(6) <= q(1); rgb565_1d_out(7) <= q(0); rgb565_1d_out(8) <= q(8);
          elsif r_r.sel = 8 then
            rgb565_1d_out(1) <= q(7); rgb565_1d_out(2) <= q(6); rgb565_1d_out(3) <= q(5); rgb565_1d_out(4) <= q(4); rgb565_1d_out(5) <= q(3); rgb565_1d_out(6) <= q(2); rgb565_1d_out(7) <= q(1); rgb565_1d_out(8) <= q(0);
          end if;
        end if;

      when 13 =>
        if r_r.rows < NUM_LINES-1 then
          for i in 1 to r_r.rows loop
            rgb565_1d_out(i) <= q(r_r.rows-i);
          end loop;
        else
          if r_r.sel = 0 then
            rgb565_1d_out(1) <= q(12); rgb565_1d_out(2) <= q(11); rgb565_1d_out(3) <= q(10); rgb565_1d_out(4) <= q(9); rgb565_1d_out(5) <= q(8); rgb565_1d_out(6) <= q(7); rgb565_1d_out(7) <= q(6); rgb565_1d_out(8) <= q(5); rgb565_1d_out(9) <= q(4); rgb565_1d_out(10) <= q(3); rgb565_1d_out(11) <= q(2); rgb565_1d_out(12) <= q(1);
          elsif r_r.sel = 1 then
            rgb565_1d_out(1) <= q(0); rgb565_1d_out(2) <= q(12); rgb565_1d_out(3) <= q(11); rgb565_1d_out(4) <= q(10); rgb565_1d_out(5) <= q(9); rgb565_1d_out(6) <= q(8); rgb565_1d_out(7) <= q(7); rgb565_1d_out(8) <= q(6); rgb565_1d_out(9) <= q(5); rgb565_1d_out(10) <= q(4); rgb565_1d_out(11) <= q(3); rgb565_1d_out(12) <= q(2);
          elsif r_r.sel = 2 then
            rgb565_1d_out(1) <= q(1); rgb565_1d_out(2) <= q(0); rgb565_1d_out(3) <= q(12); rgb565_1d_out(4) <= q(11); rgb565_1d_out(5) <= q(10); rgb565_1d_out(6) <= q(9); rgb565_1d_out(7) <= q(8); rgb565_1d_out(8) <= q(7); rgb565_1d_out(9) <= q(6); rgb565_1d_out(10) <= q(5); rgb565_1d_out(11) <= q(4); rgb565_1d_out(12) <= q(3);
          elsif r_r.sel = 3 then
            rgb565_1d_out(1) <= q(2); rgb565_1d_out(2) <= q(1); rgb565_1d_out(3) <= q(0); rgb565_1d_out(4) <= q(12); rgb565_1d_out(5) <= q(11); rgb565_1d_out(6) <= q(10); rgb565_1d_out(7) <= q(9); rgb565_1d_out(8) <= q(8); rgb565_1d_out(9) <= q(7); rgb565_1d_out(10) <= q(6); rgb565_1d_out(11) <= q(5); rgb565_1d_out(12) <= q(4);
          elsif r_r.sel = 4 then
            rgb565_1d_out(1) <= q(3); rgb565_1d_out(2) <= q(2); rgb565_1d_out(3) <= q(1); rgb565_1d_out(4) <= q(0); rgb565_1d_out(5) <= q(12); rgb565_1d_out(6) <= q(11); rgb565_1d_out(7) <= q(10); rgb565_1d_out(8) <= q(9); rgb565_1d_out(9) <= q(8); rgb565_1d_out(10) <= q(7); rgb565_1d_out(11) <= q(6); rgb565_1d_out(12) <= q(5);
          elsif r_r.sel = 5 then
            rgb565_1d_out(1) <= q(4); rgb565_1d_out(2) <= q(3); rgb565_1d_out(3) <= q(2); rgb565_1d_out(4) <= q(1); rgb565_1d_out(5) <= q(0); rgb565_1d_out(6) <= q(12); rgb565_1d_out(7) <= q(11); rgb565_1d_out(8) <= q(10); rgb565_1d_out(9) <= q(9); rgb565_1d_out(10) <= q(8); rgb565_1d_out(11) <= q(7); rgb565_1d_out(12) <= q(6);
          elsif r_r.sel = 6 then
            rgb565_1d_out(1) <= q(5); rgb565_1d_out(2) <= q(4); rgb565_1d_out(3) <= q(3); rgb565_1d_out(4) <= q(2); rgb565_1d_out(5) <= q(1); rgb565_1d_out(6) <= q(0); rgb565_1d_out(7) <= q(12); rgb565_1d_out(8) <= q(11); rgb565_1d_out(9) <= q(10); rgb565_1d_out(10) <= q(9); rgb565_1d_out(11) <= q(8); rgb565_1d_out(12) <= q(7);
          elsif r_r.sel = 7 then
            rgb565_1d_out(1) <= q(6); rgb565_1d_out(2) <= q(5); rgb565_1d_out(3) <= q(4); rgb565_1d_out(4) <= q(3); rgb565_1d_out(5) <= q(2); rgb565_1d_out(6) <= q(1); rgb565_1d_out(7) <= q(0); rgb565_1d_out(8) <= q(12); rgb565_1d_out(9) <= q(11); rgb565_1d_out(10) <= q(10); rgb565_1d_out(11) <= q(9); rgb565_1d_out(12) <= q(8);
          elsif r_r.sel = 8 then
            rgb565_1d_out(1) <= q(7); rgb565_1d_out(2) <= q(6); rgb565_1d_out(3) <= q(5); rgb565_1d_out(4) <= q(4); rgb565_1d_out(5) <= q(3); rgb565_1d_out(6) <= q(2); rgb565_1d_out(7) <= q(1); rgb565_1d_out(8) <= q(0); rgb565_1d_out(9) <= q(12); rgb565_1d_out(10) <= q(11); rgb565_1d_out(11) <= q(10); rgb565_1d_out(12) <= q(9);
          elsif r_r.sel = 9 then
            rgb565_1d_out(1) <= q(8); rgb565_1d_out(2) <= q(7); rgb565_1d_out(3) <= q(6); rgb565_1d_out(4) <= q(5); rgb565_1d_out(5) <= q(4); rgb565_1d_out(6) <= q(3); rgb565_1d_out(7) <= q(2); rgb565_1d_out(8) <= q(1); rgb565_1d_out(9) <= q(0); rgb565_1d_out(10) <= q(12); rgb565_1d_out(11) <= q(11); rgb565_1d_out(12) <= q(10);
          elsif r_r.sel = 10 then
            rgb565_1d_out(1) <= q(9); rgb565_1d_out(2) <= q(8); rgb565_1d_out(3) <= q(7); rgb565_1d_out(4) <= q(6); rgb565_1d_out(5) <= q(5); rgb565_1d_out(6) <= q(4); rgb565_1d_out(7) <= q(3); rgb565_1d_out(8) <= q(2); rgb565_1d_out(9) <= q(1); rgb565_1d_out(10) <= q(0); rgb565_1d_out(11) <= q(12); rgb565_1d_out(12) <= q(11);
          elsif r_r.sel = 11 then
            rgb565_1d_out(1) <= q(10); rgb565_1d_out(2) <= q(9); rgb565_1d_out(3) <= q(8); rgb565_1d_out(4) <= q(7); rgb565_1d_out(5) <= q(6); rgb565_1d_out(6) <= q(5); rgb565_1d_out(7) <= q(4); rgb565_1d_out(8) <= q(3); rgb565_1d_out(9) <= q(2); rgb565_1d_out(10) <= q(1); rgb565_1d_out(11) <= q(0); rgb565_1d_out(12) <= q(12);
          elsif r_r.sel = 12 then
            rgb565_1d_out(1) <= q(11); rgb565_1d_out(2) <= q(10); rgb565_1d_out(3) <= q(9); rgb565_1d_out(4) <= q(8); rgb565_1d_out(5) <= q(7); rgb565_1d_out(6) <= q(6); rgb565_1d_out(7) <= q(5); rgb565_1d_out(8) <= q(4); rgb565_1d_out(9) <= q(3); rgb565_1d_out(10) <= q(2); rgb565_1d_out(11) <= q(1); rgb565_1d_out(12) <= q(0);
          end if;
        end if;
        
      when others => null;
    end case;

    rgb565_1d_out(0) <= stage.data_565;

-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_LINEBUFFER;
    end if;
    if rst = '1' then
      init(v);
      stage_next <= NULL_STAGE;
    end if;
-------------------------------------------------------------------------------
-- Next
-------------------------------------------------------------------------------
    r_next <= v;
  end process;

  q <= qd when stalled = '1' else
       qi;
  
  proc_clk : process(clk, rst, stall, stalled, src_valid, r_next, stage_next, pipe_in, qd, qi, q)
  begin
    if rising_edge(clk) and (stall = '0' or rst = '1') then
      if (pipe_in.cfg(ID).enable = '1') then
        stage <= stage_next;
      else
        stage <= pipe_in.stage;
      end if;
      r_r <= r;
      r   <= r_next;
    end if;
    if rising_edge(clk) then
      if src_valid = '0' and stalled = '0' then
        stalled <= '1';
        qd      <= q;
      elsif src_valid = '1' and stalled = '1' then
        stalled <= '0';
      end if;
    end if;
  end process;
  adr <= std_logic_vector(to_unsigned(r.cols, 11));

end impl;
