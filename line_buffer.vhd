library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity cyclic_bit_buffer is
  generic (
    ID        : integer range 0 to 63   := 0;
    NUM_LINES : natural range 1 to 5    := 3;
    WIDTH     : natural range 1 to 2048 := 2048;
    HEIGHT    : natural range 1 to 2048 := 2048);
    port (
      pipe_in  : in  pipe_t;
      pipe_out : out pipe_t;

      mono_1d_out : out mono_1d_t
      );
end cyclic_bit_buffer;

architecture impl of cyclic_bit_buffer is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;

  type reg_t is record
    cols : natural range 0 to WIDTH;
    rows : natural range 0 to HEIGHT;
    sel  : natural range 0 to (NUM_LINES-1);
  end record;

  procedure init (variable v : inout reg_t) is
  begin
    v.sel  := 0;
    v.cols := 0;
    v.rows := 0;
  end init;

--

  signal adr  : std_logic_vector(10 downto 0);
  type   q_t is array (0 to (NUM_LINES-1)) of mono_t;
  signal q    : q_t;
  signal wren : std_logic_vector((NUM_LINES-1) downto 0);

  signal r_r : reg_t;
  signal r : reg_t;
  signal r_next : reg_t;
  
begin
  clk <= pipe_in.ctrl.clk;
  rst <= pipe_in.ctrl.rst;

  pipe_out.ctrl  <= pipe_in.ctrl;
  pipe_out.cfg   <= pipe_in.cfg;
  pipe_out.stage <= stage;

--

  adr <= std_logic_vector(to_unsigned(r.cols, 11));
  rams : for i in 0 to (NUM_LINES-1) generate
    kernel_rams : entity work.bit_ram
      generic map (
        ADDR_BITS  => 11,
        WIDTH_BITS => 1)
      port map (
        addra => adr,
        clka  => clk,                   -- [in]
        dina  => pipe_in.stage.data_1,  -- [in]
        wea   => wren(i downto i),      -- [in]
        douta => q(i));                 -- [out]    
  end generate rams;

  wr_enables : for i in 0 to (NUM_LINES-1) generate
    wren(i) <= '1' when pipe_in.stage.valid = '1' and r.sel = i else '0';
  end generate wr_enables;

  process(pipe_in)
    variable v : reg_t;
  begin  -- process
    stage_next <= pipe_in.stage;
    v          := r;
-------------------------------------------------------------------------------
-- Counters
-------------------------------------------------------------------------------
    if pipe_in.stage.valid = '1' then
      if r.cols = (WIDTH-1) then
        v.cols := 0;

        if (r.rows = (HEIGHT-1)) then
          v.rows := 0;
          v.sel  := 0;
        else
          v.rows := r.rows + 1;
        end if;

        if r.sel < (NUM_LINES-1) then
          v.sel := r.sel + 1;
        else
          v.sel := 0;
        end if;
      else
        v.cols := v.cols + 1;
      end if;
    end if;
-------------------------------------------------------------------------------
-- Generate data from pipeline
-------------------------------------------------------------------------------
    mono_1d_out <= (others => (others => '0'));

    case NUM_LINES is
      when 3 =>
        if r_r.rows = 0 then
          mono_1d_out(1) <= (others => '0');
          mono_1d_out(2) <= (others => '0');
        elsif r_r.rows = 1 then
          mono_1d_out(1) <= q(0);
          mono_1d_out(2) <= (others => '0');
        elsif r_r.rows = 2 then
          mono_1d_out(1) <= q(1);
          mono_1d_out(2) <= q(0);
        else
          if r_r.sel = 0 then
            mono_1d_out(1) <= q(2); mono_1d_out(2) <= q(1);
          elsif r_r.sel = 1 then
            mono_1d_out(1) <= q(0); mono_1d_out(2) <= q(2);
          elsif r_r.sel = 2 then
            mono_1d_out(1) <= q(1); mono_1d_out(2) <= q(0);
          end if;
        end if;
      when 5 =>
        if r_r.rows = 0 then
          mono_1d_out(1) <= (others => '0');
          mono_1d_out(2) <= (others => '0');
          mono_1d_out(3) <= (others => '0');
          mono_1d_out(4) <= (others => '0');
        elsif r_r.rows = 1 then
          mono_1d_out(1) <= q(0);
          mono_1d_out(2) <= (others => '0');
          mono_1d_out(3) <= (others => '0');
          mono_1d_out(4) <= (others => '0');
        elsif r_r.rows = 2 then
          mono_1d_out(1) <= q(1);
          mono_1d_out(2) <= q(0);
          mono_1d_out(3) <= (others => '0');
          mono_1d_out(4) <= (others => '0');
        elsif r_r.rows = 3 then
          mono_1d_out(1) <= q(2);
          mono_1d_out(2) <= q(1);
          mono_1d_out(3) <= q(0);
          mono_1d_out(4) <= (others => '0');
        else
          if r_r.sel = 0 then
            mono_1d_out(1) <= q(4); mono_1d_out(2) <= q(3); mono_1d_out(3) <= q(2); mono_1d_out(4) <= q(1);
          elsif r_r.sel = 1 then
            mono_1d_out(1) <= q(0); mono_1d_out(2) <= q(4); mono_1d_out(3) <= q(3); mono_1d_out(4) <= q(2);
          elsif r_r.sel = 2 then
            mono_1d_out(1) <= q(1); mono_1d_out(2) <= q(0); mono_1d_out(3) <= q(4); mono_1d_out(4) <= q(3);
          elsif r_r.sel = 3 then
            mono_1d_out(1) <= q(2); mono_1d_out(2) <= q(1); mono_1d_out(3) <= q(0); mono_1d_out(4) <= q(4);
          elsif r_r.sel = 4 then
            mono_1d_out(1) <= q(3); mono_1d_out(2) <= q(2); mono_1d_out(3) <= q(1); mono_1d_out(4) <= q(0);
          end if;
        end if;
      when others => null;
    end case;

    mono_1d_out(0) <= stage.data_1;
    if pipe_in.stage.data_1 = "1" then
      stage_next.data_1   <= (others => '1');
      stage_next.data_8   <= (others => '1');
      stage_next.data_565 <= (others => '1');
      stage_next.data_888 <= (others => '1');
    else
      stage_next.data_1   <= (others => '0');
      stage_next.data_8   <= (others => '0');
      stage_next.data_565 <= (others => '0');
      stage_next.data_888 <= (others => '0');
    end if;

-------------------------------------------------------------------------------
-- VIN.INIT
-------------------------------------------------------------------------------
    if rst = '1' then
      init(v);
    end if;

    r_next <= v;
  end process;

  proc_clk : process(pipe_in)
  begin
    if rising_edge(clk) then
      if (pipe_in.cfg(ID).enable = '1') then
        stage <= stage_next;
      else
        stage <= pipe_in.stage;
      end if;

      r_r <= r;
      r   <= r_next;
    end if;
end process;

end impl;
