library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.cam_pkg.all;

entity cyclic_bit_buffer is
  generic (
    NUM_LINES : natural range 1 to 5    := 3;
    WIDTH     : natural range 1 to 2048 := 2048;
    HEIGHT    : natural range 1 to 2048 := 2048);
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    vin         : in  stream_t;
    vin_data    : in  bit_t;
    vout        : out stream_t;
    vout_window : out bit_window_t
    );
end cyclic_bit_buffer;

architecture impl of cyclic_bit_buffer is
-------------------------------------------------------------------------------
-- Registers and init
-------------------------------------------------------------------------------
  type reg_t is record
    cols : natural range 0 to WIDTH;
    rows : natural range 0 to HEIGHT;
    sel  : natural range 0 to (NUM_LINES-1);
  end record;
  signal r                   :       reg_t;
  signal r_next              :       reg_t;
  procedure init (variable v : inout reg_t) is
  begin
    v.sel  := 0;
    v.cols := 0;
    v.rows := 0;
  end init;

-------------------------------------------------------------------------------
-- Signals
-------------------------------------------------------------------------------
--  type   adr_vector_t is array (0 to NUM_LINES) of lb_adr_t;
  signal adr  : std_logic_vector(10 downto 0);
  type   q_t is array (0 to (NUM_LINES-1)) of bit_t;
  signal q    : q_t;
  signal wren : std_logic_vector((NUM_LINES-1) downto 0);

  signal vin_data_r : bit_t;
  signal vin_r      : stream_t;
  signal r_r        : reg_t;
begin
  adr <= std_logic_vector(to_unsigned(r.cols, 11));
  rams : for i in 0 to (NUM_LINES-1) generate
    kernel_rams : entity work.bit_ram
      generic map (
        ADDR_BITS  => 11,
        WIDTH_BITS => 1)
      port map (
        addra => adr,
        clka  => clk,                   -- [in]
        dina  => vin_data,              -- [in]
        wea   => wren(i downto i),      -- [in]
        douta => q(i));                 -- [out]    
  end generate rams;

  wr_enables : for i in 0 to (NUM_LINES-1) generate
    wren(i) <= '1' when vin.valid = '1' and r.sel = i else '0';
  end generate wr_enables;

  process(rst, r, r_r, vin, vin_r, q, vin_data_r)
    variable v : reg_t;
  begin  -- process
    v := r;
-------------------------------------------------------------------------------
-- VIN.INIT
-------------------------------------------------------------------------------
    if vin.init = '1' then
      v.rows := 0;
      v.cols := 0;
      v.sel  := 0;
    end if;
-------------------------------------------------------------------------------
-- Counters
-------------------------------------------------------------------------------
    if vin.valid = '1' then
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
    vout_window <= (others => (others => '0'));

    case NUM_LINES is
      when 3 =>
        if r_r.rows = 0 then
          vout_window(1) <= (others => '0');
          vout_window(2) <= (others => '0');
        elsif r_r.rows = 1 then
          vout_window(1) <= q(0);
          vout_window(2) <= (others => '0');
        elsif r_r.rows = 2 then
          vout_window(1) <= q(1);
          vout_window(2) <= q(0);
        else
          if r_r.sel = 0 then
            vout_window(1) <= q(2); vout_window(2) <= q(1);
          elsif r_r.sel = 1 then
            vout_window(1) <= q(0); vout_window(2) <= q(2);
          elsif r_r.sel = 2 then
            vout_window(1) <= q(1); vout_window(2) <= q(0);
          end if;
        end if;
      when 5 =>
        if r_r.rows = 0 then
          vout_window(1) <= (others => '0');
          vout_window(2) <= (others => '0');
          vout_window(3) <= (others => '0');
          vout_window(4) <= (others => '0');
        elsif r_r.rows = 1 then
          vout_window(1) <= q(0);
          vout_window(2) <= (others => '0');
          vout_window(3) <= (others => '0');
          vout_window(4) <= (others => '0');
        elsif r_r.rows = 2 then
          vout_window(1) <= q(1);
          vout_window(2) <= q(0);
          vout_window(3) <= (others => '0');
          vout_window(4) <= (others => '0');
        elsif r_r.rows = 3 then
          vout_window(1) <= q(2);
          vout_window(2) <= q(1);
          vout_window(3) <= q(0);
          vout_window(4) <= (others => '0');
        else
          if r_r.sel = 0 then
            vout_window(1) <= q(4); vout_window(2) <= q(3); vout_window(3) <= q(2); vout_window(4) <= q(1);
          elsif r_r.sel = 1 then
            vout_window(1) <= q(0); vout_window(2) <= q(4); vout_window(3) <= q(3); vout_window(4) <= q(2);
          elsif r_r.sel = 2 then
            vout_window(1) <= q(1); vout_window(2) <= q(0); vout_window(3) <= q(4); vout_window(4) <= q(3);
          elsif r_r.sel = 3 then
            vout_window(1) <= q(2); vout_window(2) <= q(1); vout_window(3) <= q(0); vout_window(4) <= q(4);
          elsif r_r.sel = 4 then
            vout_window(1) <= q(3); vout_window(2) <= q(2); vout_window(3) <= q(1); vout_window(4) <= q(0);
          end if;
        end if;
      when others => null;
    end case;

    vout_window(0) <= vin_data_r;

    if rst = '1' then
      init(v);
    end if;

    r_next <= v;
    vout   <= vin_r;                    -- 1 cycles delay due to blockram
  end process;

  process (clk, r, r_next)
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      vin_data_r <= vin_data;

      vin_r <= vin;

      r_r <= r;
      r   <= r_next;
    end if;
  end process;

end impl;
