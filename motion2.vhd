library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cam_pkg.all;

entity motion is
  generic (
    ID : integer range 0 to 63 := 0);
  port (
    pipe_in  : in  pipe_t;
    pipe_out : out pipe_t);
end motion;

architecture impl of motion is

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal stage      : stage_t;
  signal stage_next : stage_t;

begin
  
  clk <= pipe_in.ctrl.clk;
  rst <= pipe_in.ctrl.rst;

  pipe_out.ctrl  <= pipe_in.ctrl;
  pipe_out.cfg   <= pipe_in.cfg;
  pipe_out.stage <= stage;

  process (pipe_in)
    variable diff       : unsigned(15 downto 0);
    variable m          : unsigned(7 downto 0);
    variable v          : unsigned(14 downto 0);
    variable i          : unsigned(7 downto 0);
    variable d          : unsigned(0 downto 0);
    variable d_old      : unsigned(0 downto 0);
    variable vmin       : unsigned(v'high downto v'low);
    variable vmax       : unsigned(v'high downto v'low);
    variable brightness : unsigned(8 downto 0);
  begin
    stage_next <= pipe_in.stage;

    diff       := (others => '0');
    m          := unsigned(pipe_in.stage.aux((0+m'high) downto 0));
    v          := unsigned(pipe_in.stage.aux((16+v'high) downto 16));
    d          := unsigned(pipe_in.stage.aux(31 downto 31));
    brightness := ("000" & unsigned(pipe_in.stage.data_565(15 downto 11)) & "0") +
                  ("000" & unsigned(pipe_in.stage.data_565(10 downto 5))) +
                  ("000" & unsigned(pipe_in.stage.data_565(4 downto 0)) & "0");
    i    := brightness(7 downto 0);
    vmin := unsigned(pipe_in.cfg(ID).p(1)(6 downto 0)) & unsigned(pipe_in.cfg(ID).p(0));
    vmax := unsigned(pipe_in.cfg(ID).p(3)(6 downto 0)) & unsigned(pipe_in.cfg(ID).p(2));

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
--    if d = 0 then
      if i < m then
        m := m - 1;
      elsif i > m then
        m := m + 1;
      end if;
--    end if;

    if i < m then
      diff(7 downto 0) := m - i;
    elsif i > m then
      diff(7 downto 0) := i - m;
    end if;

    case unsigned(pipe_in.cfg(ID).p(4)) is
      when "00000000" =>                --to_unsigned(0, 8) =>
        diff := diff;
      when "00000001" =>                --to_unsigned(1, 8) =>
        diff := diff(14 downto 0) & "0";
      when "00000010" =>                --to_unsigned(2, 8) =>
        diff := diff(13 downto 0) & "00";
      when "00000011" =>                --to_unsigned(3, 8) =>
        diff := diff(12 downto 0) & "000";
      when "00000100" =>                --to_unsigned(4, 8) =>
        diff := diff(11 downto 0) & "0000";
      when others =>
        diff := diff;
    end case;

    if v < (diff) then
      v := v + 1;
    elsif v > (diff) then
      v := v - 1;
    end if;

    if v < vmin then
      v := vmin;
    end if;

    if v > vmax then
      v := vmax;
    end if;
    i := v(7 downto 0);
    v := to_unsigned(200,15);

    if diff < v then
      d := "0";
    else
      d := "1";
    end if;
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------   
    stage_next.aux((0+m'high) downto 0)   <= std_logic_vector(m);
    stage_next.aux((15+v'high) downto 15) <= std_logic_vector(v);
    stage_next.aux(31 downto 31)          <= std_logic_vector(d);

    if d = 1 then
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

    case unsigned(pipe_in.cfg(ID).p(5)) is
      when "00000001" =>
        stage_next.data_565 <= std_logic_vector(i(7 downto 3)) & std_logic_vector(i(7 downto 2)) & std_logic_vector(i(7 downto 3));        
      when "00000010" =>                --to_unsigned(1, 8) =>
        stage_next.data_565 <= std_logic_vector(m(7 downto 3)) & std_logic_vector(m(7 downto 2)) & std_logic_vector(m(7 downto 3));
      when "00000011" =>                --to_unsigned(2, 8) =>
        stage_next.data_565 <= std_logic_vector(diff(7 downto 3)) & std_logic_vector(diff(7 downto 2)) & std_logic_vector(diff(7 downto 3));
      when "00000100" =>                --to_unsigned(3, 8) =>
        stage_next.data_565 <= std_logic_vector(v(7 downto 3)) & std_logic_vector(v(7 downto 2)) & std_logic_vector(v(7 downto 3));
      when others => null;        
    end case;
    
  end process;

  proc_clk : process(pipe_in)
  begin
    if rst = '1' then
      stage.valid <= '0';
      stage.init  <= '0';
    else
      if rising_edge(clk) then
        if (pipe_in.cfg(ID).enable = '1') then
          stage <= stage_next;
        else
          stage <= pipe_in.stage;
        end if;
      end if;
    end if;
  end process;

end impl;
