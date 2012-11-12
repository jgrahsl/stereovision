library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


library digilent;
use digilent.TWIUtils.all;
library UNISIM;
use UNISIM.VComponents.all;

entity i2c is
  port (
    RST_I : in    std_logic;
    CLK   : in    std_logic;            --24 MHz
    SDA   : inout std_logic;
    SCL   : inout std_logic;

    wr_clk  : in  std_logic;
    wr_data : in  std_logic_vector(7 downto 0);
    wr_en   : in  std_logic;
    wr_full : out std_logic
    );
end i2c;

architecture rtl of i2c is

  constant CLOCKFREQ : natural := 24;   --MHz

  constant TWI_MT9D112                 : std_logic_vector(7 downto 1) := "0111100";
  constant IRD                         : std_logic                    := '1';  -- init read
  constant IWR                         : std_logic                    := '0';  -- init write
  
  constant CMD_DELAY        : natural := 1;  --ms
  constant CMD_DELAY_CYCLES : natural := 100000; --00000;

  type   state_type is (stR, stRegAddr1, stRegAddr2, stData1, stData2, stError, stDone, stIdle, stDelay);
  signal state, nstate : state_type := stIdle;

  signal twiStb, twiDone, twiErr, twiRst, iTwiStb, twiNewMsg : std_logic;
  signal twiAddr, twiDi, twiDo, iTwiData, iTwiAddr, regData1 : std_logic_vector(7 downto 0);
  signal twiErrType                                          : digilent.TWIUtils.error_type;

  signal waitCnt   : natural range 0 to CMD_DELAY_CYCLES := CMD_DELAY_CYCLES;
  signal waitCntEn : std_logic;

  signal intRst, SRst : std_logic := '1';

  signal rd_en       : std_logic;
  signal dout        : std_logic_vector(7 downto 0);
  signal empty       : std_logic;
  signal octets      : natural range 0 to 6;
  signal next_octets : natural range 0 to 6;
  type   reg_t is array (0 to 5) of std_logic_vector(7 downto 0);
  signal reg         : reg_t;
  signal count : std_logic_vector(4 downto 0);
  signal next_reg : reg_t;

  signal reg1 : std_logic_vector(7 downto 0);
  signal reg2 : std_logic_vector(7 downto 0);  
  signal nreg1 : std_logic_vector(7 downto 0);
  signal nreg2 : std_logic_vector(7 downto 0);

  signal fwr_full : std_logic;
  signal awr_full : std_logic;  
begin
  my_i2cfifo : entity work.i2cfifo
    port map (
      rst    => rst_i,                  -- [IN]
      wr_clk => wr_clk,                 -- [IN]
      rd_clk => clk,                    -- [IN]
      din    => wr_data,                -- [IN]
      wr_en  => wr_en,                  -- [IN]
      rd_en  => rd_en,                  -- [IN]
      dout   => dout,                   -- [OUT]
      full   => fwr_full,                -- [OUT]
      almost_full => awr_full,
      empty  => empty
      );                 -- [OUT]

  wr_full <= awr_full or fwr_full;
  
  Inst_LocalRst : entity digilent.LocalRst port map(
    RST_I  => RST_I,
    CLK_I  => CLK,
    SRST_O => intRst
    );

  Inst_TWICtl : entity digilent.TWICtl generic map (CLOCKFREQ)
    port map(
      MSG_I     => twiNewMsg,
      STB_I     => twiStb,
      A_I       => twiAddr,
      D_I       => twiDi,
      D_O       => twiDo,
      DONE_O    => twiDone,
      ERR_O     => twiErr,
      ERRTYPE_O => twiErrType,
      CLK       => CLK,
      SRST      => intRst,
      SDA       => SDA,
      SCL       => SCL
      );

  Wait_CNT : process (CLK)
  begin
    if Rising_Edge(CLK) then
      if (waitCntEn = '0') then
        waitCnt <= CMD_DELAY_CYCLES;
      else
        waitCnt <= waitCnt - 1;
      end if;
    end if;
  end process;

  SYNC_PROC : process (CLK)
  begin
    if Rising_Edge(CLK) then
      if (intRst = '1') then
        state <= stIdle;
      else
        state  <= nstate;
        reg    <= next_reg;
        octets <= next_octets;
        reg1 <= nreg1;
        reg2 <= nreg2;
      end if;
    end if;
  end process;

  twiAddr(7 downto 1) <= reg(0)(7 downto 1);  --"0111100"; --
  twiAddr(0)          <= reg(0)(0) when state = stData1 or state = stData2 else '0';

  OUTPUT_DECODE : process (state, twiDone, twiErr)
  begin
    twiDi     <= "--------";
    twiStb    <= '0';
    twiNewMsg <= '0';
    nstate    <= state;
    rd_en     <= '0';
    waitCntEn <= '0';
    next_octets <= octets;
    next_reg    <= reg;
    nreg1 <= reg1;
    nreg2 <= reg2;    
    case (state) is
      when stIdle =>
        next_octets <= 0;
        nstate <= stR;
        
      when stR =>
        if empty = '0' then

          if octets = 4 then
            nstate <= stRegAddr1;
          end if;
          next_octets <= octets + 1;

          rd_en       <= '1';
          next_reg(octets) <= dout;
        end if;

      when stRegAddr1 =>
        twiDi     <= reg(1);
        twiStb    <= '1';
        twiNewMsg <= '1';

        if (twiDone = '1') then
          twiStb    <= '0';
          twiNewMsg <= '0';

          if (twiErr = '1') then
            nstate <= stError;
          else
            nstate <= stRegAddr2;
          end if;
        end if;

      when stRegAddr2 =>
        twiDi  <= reg(2);
        twiStb <= '1';

        if (twiDone = '1') then
          twiStb    <= '0';
          twiNewMsg <= '0';

          if (twiErr = '1') then
            nstate <= stError;
          else
            nstate <= stData1;
          end if;
        end if;

      when stData1 =>
        twiDi  <= reg(3);
        twiStb <= '1';

        if (twiDone = '1') then
          twiStb    <= '0';
          twiNewMsg <= '0';
          nreg1 <= twiDo;
          if (twiErr = '1') then
            nstate <= stError;
          else           
            nstate <= stData2;
          end if;
        end if;

        if (reg(0)(0) = '1') then
          twiNewMsg <= '1';
        end if;
        
      when stData2 =>
        twiDi  <= reg(4);
        twiStb <= '1';

        if (twiDone = '1') then
          twiStb    <= '0';
          twiNewMsg <= '0';
          nreg2 <= twiDo;
          if (twiErr = '1') then
            nstate <= stError;
          else
            nstate <= stDelay;
          end if;
        end if;

      when stDelay =>
        waitCntEn <= '1';
        if (waitCnt = 0) then
          if reg(0)(0) = '0' or (reg(0)(0) = '1' and reg1 = reg(3) and reg2 = reg(4)) then
            nstate <= stIdle;            
          else
            nstate <= stRegAddr1; 
          end if;
        end if;
        
      when stError =>
--        nstate <= stRegAddr1;
        null;
      when others =>
        null;                                        --default values specifiec before case
    end case;

  end process;
end rtl;
