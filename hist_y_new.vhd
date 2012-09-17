library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity hist_y is
  generic (
    ID     : integer range 0 to 63   := 0;
    WIDTH  : natural range 1 to 2048 := 2048;
    HEIGHT : natural range 1 to 2048 := 2048
    );
  port (
    pipe_in  : in  pipe_t;
    pipe_out : out pipe_t);
end hist_y;

architecture impl of hist_y is

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
  constant PHASES : natural := 4;
  subtype  counter_t is natural range 0 to 2047;
  type     reg_t is record
    cols   : natural range 0 to WIDTH;
    rows   : natural range 0 to HEIGHT;
    val    : counter_t;
    cur    : counter_t;
    rd_adr : natural range 0 to WIDTH-1;
    wr_adr : natural range 0 to WIDTH-1;
    phase  : natural range 0 to 3;

    draw_start : natural range 0 to (HEIGHT-1);
    draw_end   : natural range 0 to (HEIGHT-1);
    maxarea    : natural range 0 to (WIDTH*HEIGHT);
    maxstart   : natural range 0 to (WIDTH-1);
    maxend     : natural range 0 to (WIDTH-1);
    area       : natural range 0 to (WIDTH*HEIGHT);
    start      : natural range 0 to (WIDTH-1);
  end record;

  signal r      : reg_t;
  signal r_next : reg_t;

  procedure init (variable v : inout reg_t) is
  begin
    v.cols   := 0;
    v.rows   := 0;
    v.cur    := 0;
    v.val    := 0;
    v.rd_adr := 0;
    v.wr_adr := 0;
    v.phase  := 0;

    v.maxarea  := 0;
    v.maxstart := 0;
    v.maxend   := 0;
    v.area     := 0;
    v.start    := 0;
  end init;

  signal ram2_wen  : std_logic_vector(0 downto 0);
  signal ram2_adr  : std_logic_vector(10 downto 0);
  signal ram2_din  : std_logic_vector(9 downto 0);
  signal ram2_dout : std_logic_vector(9 downto 0);

  signal ram0_wen  : std_logic_vector(0 downto 0);
  signal ram0_adr  : std_logic_vector(10 downto 0);
  signal ram0_din  : std_logic_vector(9 downto 0);
  signal ram0_dout : std_logic_vector(9 downto 0);

  signal ram1_wen  : std_logic_vector(0 downto 0);
  signal ram1_adr  : std_logic_vector(10 downto 0);
  signal ram1_din  : std_logic_vector(9 downto 0);
  signal ram1_dout : std_logic_vector(9 downto 0);
begin
  issue <= '0';

  connect_pipe(clk, rst, pipe_in, pipe_out, stage, src_valid, issue, stall);

  swap_ram : entity work.bit_ram
    generic map (
      ADDR_BITS  => 4,
      WIDTH_BITS => 10)
    port map (
      clka  => clk,                     -- [IN]
      wea   => ram2_wen,                -- [IN]
      addra => ram2_adr(3 downto 0),    -- [IN]
      dina  => ram2_din,                -- [IN]
      douta => ram2_dout);              -- [OUT]

  ram0_ram : entity work.bit_ram
    generic map (
      ADDR_BITS  => 4,
      WIDTH_BITS => 10)
    port map (
      clka  => clk,                     -- [IN]
      wea   => ram0_wen,                -- [IN]
      addra => ram0_adr(3 downto 0),    -- [IN]
      dina  => ram0_din,                -- [IN]
      douta => ram0_dout);              -- [OUT]

  ram1_ram : entity work.bit_ram
    generic map (
      ADDR_BITS  => 4,
      WIDTH_BITS => 10)
    port map (
      clka  => clk,                     -- [IN]
      wea   => ram1_wen,                -- [IN]
      addra => ram1_adr(3 downto 0),    -- [IN]
      dina  => ram1_din,                -- [IN]
      douta => ram1_dout);              -- [OUT]  


  ram0_adr <= std_logic_vector(to_unsigned(r.wr_adr, 11)) when r.phase = 0 or r.phase = 2 else
              std_logic_vector(to_unsigned(r.rd_adr+1, 11)) when src_valid = '1' else
              std_logic_vector(to_unsigned(r.rd_adr, 11));

  ram1_adr <= std_logic_vector(to_unsigned(r.wr_adr, 11)) when r.phase = 1 else
              std_logic_vector(to_unsigned(r.rd_adr+1, 11)) when src_valid = '1' else
              std_logic_vector(to_unsigned(r.rd_adr, 11));
  
  ram2_adr <= std_logic_vector(to_unsigned(r.wr_adr, 11)) when r.phase = 3 else
              std_logic_vector(to_unsigned(r.rd_adr+1, 11)) when src_valid = '1' else
              std_logic_vector(to_unsigned(r.rd_adr, 11));

  ram0_wen <= "1" when (r.phase = 0 or r.phase = 2) and src_valid = '1' else
              "0";

  ram1_wen <= "1" when r.phase = 1 and src_valid = '1' else
              "0";

  ram2_wen <= "1" when r.phase = 3 and src_valid = '1' else
              "0";
  
  process (pipe_in, r, ram0_dout, ram1_dout, ram2_dout, src_valid, rst)
    variable v   : reg_t;
    variable cur : natural range 0 to (HEIGHT-1);
  begin
    stage_next <= pipe_in.stage;
    v          := r;
-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------

    if v.phase = 0 then
      if pipe_in.stage.data_1 = "1" then
        ram0_din <= std_logic_vector(unsigned(ram1_dout)+1);
      else
        ram0_din <= std_logic_vector(unsigned(ram1_dout)+0);
      end if;
      if v.rows = 0 then
        ram0_din <= std_logic_vector(to_unsigned(0, 10));
      end if;
      ram1_din <= (others => '0');
      ram2_din <= (others => '0');
      cur      := to_integer(unsigned(ram2_dout));
    elsif v.phase = 1 then
      if pipe_in.stage.data_1 = "1" then
        ram1_din <= std_logic_vector(unsigned(ram0_dout)+1);
      else
        ram1_din <= std_logic_vector(unsigned(ram0_dout)+0);
      end if;
      if v.rows = 0 then
        ram1_din <= std_logic_vector(to_unsigned(0, 10));
      end if;
      ram0_din <= (others => '0');
      ram2_din <= (others => '0');
      cur      := to_integer(unsigned(ram2_dout));
    elsif v.phase = 2 then
      if pipe_in.stage.data_1 = "1" then
        ram0_din <= std_logic_vector(unsigned(ram2_dout)+1);
      else
        ram0_din <= std_logic_vector(unsigned(ram2_dout)+0);
      end if;
      if v.rows = 0 then
        ram0_din <= std_logic_vector(to_unsigned(0, 10));
      end if;
      ram2_din <= (others => '0');
      ram1_din <= (others => '0');
      cur      := to_integer(unsigned(ram1_dout));
    else
      if pipe_in.stage.data_1 = "1" then
        ram2_din <= std_logic_vector(unsigned(ram0_dout)+1);
      else
        ram2_din <= std_logic_vector(unsigned(ram0_dout)+0);
      end if;
      if v.rows = 0 then
        ram2_din <= std_logic_vector(to_unsigned(0, 10));
      end if;

      ram0_din <= (others => '0');
      ram1_din <= (others => '0');
      cur      := to_integer(unsigned(ram1_dout));
    end if;


    if src_valid = '1' then

      if v.rd_adr = (WIDTH-1) then
        v.rd_adr := 0;
      else
        v.rd_adr := v.rd_adr + 1;
      end if;

      if v.wr_adr = (WIDTH-1) then
        v.wr_adr := 0;

        if v.rows = (HEIGHT-1) then
          if v.phase = 0 or v.phase = 1 then
            v.phase := 2;
          else
            v.phase := 0;
          end if;
          v.maxarea := 0;
        else
          if v.phase = 0 then
            v.phase := 1;
          elsif v.phase = 1 then
            v.phase := 0;
          elsif v.phase = 2 then
            v.phase := 3;
          elsif v.phase = 3 then
            v.phase := 2;
          end if;
        end if;

      else
        v.wr_adr := v.wr_adr + 1;
      end if;

      if v.rows = 0 then
        if v.cols = 0 then
          v.maxstart := 0;
          v.maxend   := 0;
          v.maxarea  := 0;
        end if;
        if v.area > 0 then
          -- area is open
          
          if to_unsigned(cur, 10) < unsigned(pipe_in.cfg(ID).p(1)) then
            -- if lower than threshold
            
            if v.area > v.maxarea then
              --current area bigger
              v.maxstart := v.start;
              v.maxend   := v.cols-1;
              v.maxarea  := v.area;
            else
              v.area := 0;
            end if;
          else
            -- over threshold
            v.area := v.area + cur;
          end if;

        else
          if to_unsigned(cur, 10) > unsigned(pipe_in.cfg(ID).p(1)) then
            v.area  := cur;
            v.start := v.cols;
          end if;
        end if;
      end if;
    end if;
-------------------------------------------------------------------------------
-- Output
-------------------------------------------------------------------------------
    if pipe_in.cfg(ID).p(0)(1) = '1' then
      if v.rows < cur then
        stage_next.data_1 <= (others => '1');
      else
        stage_next.data_1 <= (others => '0');
      end if;
    end if;

    if pipe_in.cfg(ID).p(0)(0) = '1' then
      --if (v.cols = v.maxstart or v.cols = v.maxend) and v.maxarea > 0 then
      --  stage_next.data_565 <= "0000011111100000";
      --  stage_next.data_1   <= (others => '1');
      --end if;
      if (v.rows < cur) and v.maxarea > 0 then
        stage_next.data_565 <= "0000011111100000";
        stage_next.data_1   <= (others => '1');
      end if;
    end if;
-------------------------------------------------------------------------------
-- Counter
-------------------------------------------------------------------------------
    if src_valid = '1' then
      if v.cols = (WIDTH-1) then
        v.cols := 0;
        if v.rows = (HEIGHT-1) then
          v.rows := 0;
        else
          v.rows := v.rows + 1;
        end if;
      else
        v.cols := v.cols + 1;
      end if;
    end if;
-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
    if pipe_in.cfg(ID).identify = '1' then
      stage_next.identity <= IDENT_HISTY;
    end if;
    if rst = '1' then
      stage_next <= NULL_STAGE;
      init(v);
    end if;
-------------------------------------------------------------------------------
-- Next
-------------------------------------------------------------------------------    
    r_next <= v;
  end process;

  proc_clk : process(clk, stall, stage_next, pipe_in)
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
