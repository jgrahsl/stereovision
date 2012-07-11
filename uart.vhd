
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
  port (
    clk   : in std_logic;
    reset : in std_logic;

-- SimpCon interface

    wr_data : in  std_logic_vector(7 downto 0);
    rd, wr  : in  std_logic;
    rd_data : out std_logic_vector(7 downto 0);

    txd  : out std_logic;
    rxd  : in  std_logic
    );
end uart;

architecture rtl of uart is


  component my_fifofifo
    port (
      clk   : IN  STD_LOGIC;
      rst   : IN  STD_LOGIC;
      din   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      wr_en : IN  STD_LOGIC;
      rd_en : IN  STD_LOGIC;
      dout  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      full  : OUT STD_LOGIC;
      empty : OUT STD_LOGIC); 
  end component;

--
-- signals for uart connection
--
  signal ua_dout     : std_logic_vector(7 downto 0);
  signal ua_wr, tdre : std_logic;
  signal ua_rd, rdrf : std_logic;

  type   uart_tx_state_type is (s0, s1);
  signal uart_tx_state : uart_tx_state_type;

  signal tf_dout  : std_logic_vector(7 downto 0);  -- fifo out
  signal tf_rd    : std_logic;
  signal tf_empty : std_logic;
  signal tf_full  : std_logic;

  signal tsr : std_logic_vector(10 downto 0);  -- tx shift register

  signal tx_clk : std_logic;


  type   uart_rx_state_type is (s0, s1, s2);
  signal uart_rx_state : uart_rx_state_type;

  signal rf_wr    : std_logic;
  signal rf_empty : std_logic;
  signal rf_full  : std_logic;

  signal rxd_reg : std_logic_vector(2 downto 0);
  signal rx_buf  : std_logic_vector(2 downto 0);  -- sync in, filter
  signal rx_d    : std_logic;                     -- rx serial data

  signal rsr : std_logic_vector(10 downto 0);  -- rx shift register

  signal rx_clk     : std_logic;
  signal rx_clk_ena : std_logic;


  constant clk16_cnt : integer := (40000000/19200+8)/16-1;
  

begin


  rd_data(7 downto 0) <= ua_dout;
  
  ua_rd <= rd;
  ua_wr <= wr and not tf_full;
  
  process(clk, reset)

    variable clk16 : integer range 0 to clk16_cnt;
    variable clktx : unsigned(3 downto 0);
    variable clkrx : unsigned(3 downto 0);

  begin
    if (reset = '1') then
      clk16  := 0;
      clktx  := "0000";
      clkrx  := "0000";
      tx_clk <= '0';
      rx_clk <= '0';
      rx_buf <= "111";

    elsif rising_edge(clk) then

      rxd_reg(0) <= rxd;  -- to avoid setup timing error in Quartus
      rxd_reg(1) <= rxd_reg(0);
      rxd_reg(2) <= rxd_reg(1);

      if (clk16 = clk16_cnt) then       -- 16 x serial clock
        clk16 := 0;
--
-- tx clock
--
        clktx := clktx + 1;
        if (clktx = "0000") then
          tx_clk <= '1';
        else
          tx_clk <= '0';
        end if;
--
-- rx clock
--
        if (rx_clk_ena = '1') then
          clkrx := clkrx + 1;
          if (clkrx = "1000") then
            rx_clk <= '1';
          else
            rx_clk <= '0';
          end if;
        else
          clkrx := "0000";
        end if;
--
-- sync in filter buffer
--
        rx_buf(0)          <= rxd_reg(2);
        rx_buf(2 downto 1) <= rx_buf(1 downto 0);
      else
        clk16  := clk16 + 1;
        tx_clk <= '0';
        rx_clk <= '0';
      end if;


    end if;

  end process;


--
-- transmit fifo
--

  amy_my_fifofifo: my_fifofifo
    port map (
      clk   => clk,                     -- [IN]
      rst   => reset,                     -- [IN]
      din   => wr_data,                     -- [IN]
      wr_en => ua_wr,                   -- [IN]
      rd_en => tf_rd,                   -- [IN]
      dout  => tf_dout,                    -- [OUT]
      full  => tf_full,                    -- [OUT]
      empty => tf_empty);                  -- [OUT]
--
-- state machine for actual shift out
--
  process(clk, reset)

    variable i         : integer range 0 to 12;
    variable parity_tx : std_logic;

  begin
    

    if (reset = '1') then
      uart_tx_state <= s0;
      tsr           <= "11111111111";
      tf_rd         <= '0';

    elsif rising_edge(clk) then

      case uart_tx_state is

        when s0 =>

          parity_tx := '1';

          i := 0;
          if (tf_empty = '0') then
            uart_tx_state <= s1;
            tsr           <= parity_tx & tf_dout & '0' & '1';
            tf_rd         <= '1';
          end if;

        when s1 =>
          tf_rd <= '0';
          if (tx_clk = '1') then
            tsr(10)         <= '1';
            tsr(9 downto 0) <= tsr(10 downto 1);
            i               := i+1;
            if (i = 12) or (i = 11) then  -- two stop bits
              uart_tx_state <= s0;
            end if;
            
          end if;
          
      end case;
      
    end if;

  end process;

  txd  <= tsr(0);
  tdre <= not tf_full;

--
-- receive fifo
--

  bmy_my_fifofifo: my_fifofifo
    port map (
      clk   => clk,                     -- [IN]
      rst   => reset,                     -- [IN]
      din   => rsr(8 downto 1),                     -- [IN]
      wr_en => rf_wr,                   -- [IN]
      rd_en => ua_rd,                   -- [IN]
      dout  => ua_dout,                    -- [OUT]
      full  => rf_full,                    -- [OUT]
      empty => rf_empty);                  -- [OUT]
  

  rdrf <= not rf_empty;

--
-- filter rxd
--
  with rx_buf select
    rx_d <= '0' when "000",
    '0'         when "001",
    '0'         when "010",
    '1'         when "011",
    '0'         when "100",
    '1'         when "101",
    '1'         when "110",
    '1'         when "111",
    'X'         when others;

--
-- state machine for actual shift in
--
  process(clk, reset)

    variable i         : integer range 0 to 11;
    variable parity_rx : std_logic;

  begin

    if (reset = '1') then
      uart_rx_state <= s0;
      rsr           <= "00000000000";
      rf_wr         <= '0';
      rx_clk_ena    <= '0';

    elsif rising_edge(clk) then

      case uart_rx_state is


        when s0 =>
          i     := 0;
          rf_wr <= '0';
          if (rx_d = '0') then
            rx_clk_ena    <= '1';
            uart_rx_state <= s1;
          else
            rx_clk_ena <= '0';
          end if;

        when s1 =>
          if (rx_clk = '1') then
            rsr(10)         <= rx_d;
            rsr(9 downto 0) <= rsr(10 downto 1);
            i               := i+1;

            if i = 11 then
              uart_rx_state <= s2;
            end if;

            if i = 10 then
              rsr(10)         <= rx_d;
              rsr(9)          <= rx_d;
              rsr(8 downto 0) <= rsr(10 downto 2);
              uart_rx_state   <= s2;
            end if;
          end if;
          
        when s2 =>
          rx_clk_ena <= '0';

          if rsr(0) = '0' and rsr(10) = '1' then
            

            if rf_full = '0' then       -- if full just drop it
              rf_wr <= '1';
            end if;
          end if;

          uart_rx_state <= s0;

      end case;
    end if;

  end process;

end rtl;
