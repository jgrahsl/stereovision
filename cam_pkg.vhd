library ieee;
use ieee.std_logic_1164.all;

package cam_pkg is

-- vin_data(1)(0) 1 col delay
-- vin_data(0)(1) 1 row delay
  constant MAX_PIPE  : natural := 32;
  constant MAX_PARAM : natural := 6;

  constant PARAM : natural := 5;
  
  constant IDENT_MCBFEED : std_logic_vector(7 downto 0) := X"01";
  constant IDENT_SKIN    : std_logic_vector(7 downto 0) := X"02";
  constant IDENT_MOTION  : std_logic_vector(7 downto 0) := X"03";
  constant IDENT_MORPH   : std_logic_vector(7 downto 0) := X"04";
  constant IDENT_HISTX   : std_logic_vector(7 downto 0) := X"05";
  constant IDENT_HISTY   : std_logic_vector(7 downto 0) := X"06";
  constant IDENT_MCBSINK : std_logic_vector(7 downto 0) := X"07";
  constant IDENT_COLMUX  : std_logic_vector(7 downto 0) := X"08";

  constant IDENT_SIMFEED       : std_logic_vector(7 downto 0) := X"09";
  constant IDENT_SIMSINK       : std_logic_vector(7 downto 0) := X"0A";
  constant IDENT_WIN_TEST      : std_logic_vector(7 downto 0) := X"0B";
  constant IDENT_TRANSLATE     : std_logic_vector(7 downto 0) := X"0C";
  constant IDENT_TRANSLATE_WIN : std_logic_vector(7 downto 0) := X"0D";
  constant IDENT_NULL          : std_logic_vector(7 downto 0) := X"0E";

  subtype mono_t is std_logic_vector(0 downto 0);
  subtype rgb565_t is std_logic_vector(15 downto 0);
  subtype rgb888_t is std_logic_vector(23 downto 0);
  subtype gray8_t is std_logic_vector(7 downto 0);

  type mono_1d_t is array (0 to 4) of mono_t;
  type mono_2d_t is array (0 to 4) of mono_1d_t;

  subtype byte_t is std_logic_vector(7 downto 0);
  type    param_t is array (0 to MAX_PARAM-1) of byte_t;

  type stage_t is record
    valid    : std_logic;
    init     : std_logic;
    aux      : std_logic_vector(31 downto 0);
    data_1   : mono_t;
    data_8   : gray8_t;
    data_565 : rgb565_t;
    data_888 : rgb888_t;
    identity : std_logic_vector(7 downto 0);
  end record;
  constant NULL_STAGE : stage_t := ('0', '0', (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));

  type inspect_t is record
    identity : std_logic_vector(7 downto 0);
  end record;

  type cfg_t is record
    enable   : std_logic;
    identify : std_logic;
    p        : param_t;
  end record;

  type ctrl_t is record
    clk   : std_logic;
    rst   : std_logic;
    issue : std_logic;
    stall : std_logic;
  end record;

  type cfg_set_t is array (0 to MAX_PIPE-1) of cfg_t;

  type pipe_t is record
    stage : stage_t;
    cfg   : cfg_set_t;
    ctrl  : ctrl_t;
--    stall : std_logic;
  end record;

  type pipe_set_t is array (0 to MAX_PIPE-1) of pipe_t;

  type mcb_fifo_t is record
    clk   : std_logic;
    en    : std_logic;
    stall : std_logic;
    data  : std_logic_vector(31 downto 0);
  end record;

  type sim_fifo_t is record
    clk   : std_logic;
    en    : std_logic;
    stall : std_logic;
    data  : std_logic_vector((24+16+8+1)-1 downto 0);
  end record;

  type pixel_fifo_t is record
    clk   : std_logic;
    en    : std_logic;
    stall : std_logic;
    data  : std_logic_vector(15 downto 0);
    count : std_logic_vector(9 downto 0);
  end record;
  
  type abcd_t is record
    ax : out std_logic_vector(PARAM-1 downto 0);
    ay : out std_logic_vector(PARAM-1 downto 0);
    bx : out std_logic_vector(PARAM-1 downto 0);
    by : out std_logic_vector(PARAM-1 downto 0);
    cx : out std_logic_vector(PARAM-1 downto 0);
    cy : out std_logic_vector(PARAM-1 downto 0);
    dx : out std_logic_vector(PARAM-1 downto 0);
    dy : out std_logic_vector(PARAM-1 downto 0);
  end record;

  procedure connect_pipe (
    signal clk       : out std_logic;
    signal rst       : out std_logic;
    signal pipe_in   : in  pipe_t;
    signal pipe_out  : out pipe_t;
    signal stall_in  : in  std_logic;
    signal stall_out : out std_logic;
    signal stage     : in  stage_t;
    signal src_valid : out std_logic;
    signal issue     : in  std_logic;
    signal stall     : out std_logic);
end cam_pkg;


package body cam_pkg is
  procedure connect_pipe (
    signal clk       : out std_logic;
    signal rst       : out std_logic;
    signal pipe_in   : in  pipe_t;
    signal pipe_out  : out pipe_t;
    signal stall_in  : in  std_logic;
    signal stall_out : out std_logic;
    signal stage     : in  stage_t;
    signal src_valid : out std_logic;
    signal issue     : in  std_logic;
    signal stall     : out std_logic)
  is
  begin
    clk <= pipe_in.ctrl.clk;
    rst <= pipe_in.ctrl.rst;

    pipe_out.ctrl  <= pipe_in.ctrl;
    pipe_out.cfg   <= pipe_in.cfg;
    pipe_out.stage <= stage;

    stall_out <= stall_in or issue;
    stall     <= stall_in;

    src_valid <= pipe_in.stage.valid and not (stall_in or issue);
  end procedure connect_pipe;

  

end cam_pkg;
