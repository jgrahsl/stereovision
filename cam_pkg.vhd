library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package cam_pkg is

-- vin_data(1)(0) 1 col delay
-- vin_data(0)(1) 1 row delay
  constant MAX_PIPE     : natural := 26;
  constant MAX_PARAM    : natural := 6;
  constant MAX_KERNEL   : natural := 9;
  -----------------------------------------------------------------------------
  -- Bilinear
  -----------------------------------------------------------------------------
  constant COMMA    : natural := 4;
  constant ABCD_BITS    : natural := 20;
  constant GRIDX_BITS   : natural := 6;
  constant GRIDY_BITS   : natural := 6;  -- MS bits taken from pixel counter
                                         -- for rom adr
  constant SUBGRID_BITS : natural := 3;  -- LS bits taken from pixel counter
                                         -- for interpolation
  -----------------------------------------------------------------------------
  -- Ident codes
  -----------------------------------------------------------------------------

  constant IDENT_MCBFEED : std_logic_vector(7 downto 0) := X"01";
  constant IDENT_SKIN    : std_logic_vector(7 downto 0) := X"02";
  constant IDENT_MOTION  : std_logic_vector(7 downto 0) := X"03";
  constant IDENT_MORPH   : std_logic_vector(7 downto 0) := X"04";
  constant IDENT_HISTX   : std_logic_vector(7 downto 0) := X"05";
  constant IDENT_HISTY   : std_logic_vector(7 downto 0) := X"06";
  constant IDENT_MCBSINK : std_logic_vector(7 downto 0) := X"07";
  constant IDENT_COLMUX  : std_logic_vector(7 downto 0) := X"08";

  constant IDENT_SIMFEED : std_logic_vector(7 downto 0) := X"09";
  constant IDENT_SIMSINK : std_logic_vector(7 downto 0) := X"0A";

  constant IDENT_FIFOSINK : std_logic_vector(7 downto 0) := X"0B";

  constant IDENT_TRANSLATE       : std_logic_vector(7 downto 0) := X"10";
  constant IDENT_TRANSLATE_WIN   : std_logic_vector(7 downto 0) := X"11";
  constant IDENT_TRANSLATE_WIN_8 : std_logic_vector(7 downto 0) := X"12";
  constant IDENT_LINEBUFFER      : std_logic_vector(7 downto 0) := X"13";
  constant IDENT_LINEBUFFER_8    : std_logic_vector(7 downto 0) := X"14";
  constant IDENT_WINDOW          : std_logic_vector(7 downto 0) := X"15";
  constant IDENT_WINDOW_8        : std_logic_vector(7 downto 0) := X"16";
  constant IDENT_WIN_TEST        : std_logic_vector(7 downto 0) := X"17";
  constant IDENT_WIN_TEST_8      : std_logic_vector(7 downto 0) := X"18";
  constant IDENT_TESTPIC         : std_logic_vector(7 downto 0) := X"19";

  constant IDENT_BI1       : std_logic_vector(7 downto 0) := X"1A";
  constant IDENT_BI2       : std_logic_vector(7 downto 0) := X"1B";
  constant IDENT_BI2_X     : std_logic_vector(7 downto 0) := X"1C";
  constant IDENT_BI2_Y     : std_logic_vector(7 downto 0) := X"1D";
  constant IDENT_BI2_C     : std_logic_vector(7 downto 0) := X"1E";
  constant IDENT_BI3       : std_logic_vector(7 downto 0) := X"1F";
  constant IDENT_DISPARITY : std_logic_vector(7 downto 0) := X"20";
  constant IDENT_CENSUS    : std_logic_vector(7 downto 0) := X"21";


  constant IDENT_NULL : std_logic_vector(7 downto 0) := X"F0";
  -----------------------------------------------------------------------------
  -- Stage types
  -----------------------------------------------------------------------------
  subtype  mono_t is std_logic_vector(0 downto 0);
  subtype  rgb565_t is std_logic_vector(15 downto 0);
  subtype  rgb888_t is std_logic_vector(23 downto 0);
  subtype  gray8_t is std_logic_vector(7 downto 0);

  type mono_1d_t is array (0 to MAX_KERNEL-1) of mono_t;
  type mono_2d_t is array (0 to MAX_KERNEL*MAX_KERNEL-1) of mono_t;

  type gray8_1d_t is array (0 to MAX_KERNEL-1) of gray8_t;
  type gray8_2d_t is array (0 to MAX_KERNEL*MAX_KERNEL-1) of gray8_t;

  type rgb565_1d_t is array (0 to MAX_KERNEL-1) of rgb565_t;
  type rgb565_2d_t is array (0 to MAX_KERNEL*MAX_KERNEL-1) of rgb565_t;

  subtype byte_t is std_logic_vector(7 downto 0);
  type    param_t is array (0 to MAX_PARAM-1) of byte_t;

  type stage_t is record
    valid    : std_logic;
--    init     : std_logic;
    aux      : std_logic_vector(31 downto 0);
    data_1   : mono_t;
    data_8   : gray8_t;
    data_565 : rgb565_t;
    data_888 : rgb888_t;
    identity : std_logic_vector(7 downto 0);
  end record;

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
--    issue : std_logic;
--    stall : std_logic;
  end record;

  type cfg_set_t is array (0 to MAX_PIPE-1) of cfg_t;

  type pipe_t is record
    stage : stage_t;
    cfg   : cfg_set_t;
    ctrl  : ctrl_t;
--    stall : std_logic;
  end record;

  constant NULL_STAGE : stage_t := ('0', (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
  constant NULL_CFG : cfg_t := ('0', '0', (others => (others => '0')));
  constant NULL_CFG_SET : cfg_set_t := (others => NULL_CFG);
  constant NULL_CTRL : ctrl_t := (others => '0');
  constant NULL_PIPE : pipe_t := (NULL_STAGE, NULL_CFG_SET, NULL_CTRL);  
  
  type pipe_set_t is array (0 to MAX_PIPE-1) of pipe_t;

  type mcb_fifo_t is record
    clk   : std_logic;
    en    : std_logic;
    stall : std_logic;
    data  : std_logic_vector(31 downto 0);
  end record;

  type cam_fifo_t is record
    clk   : std_logic;
    en    : std_logic;
    stall : std_logic;
    data  : std_logic_vector(15 downto 0);
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
    ax : signed((ABCD_BITS/2)-1 downto 0);
    ay : signed((ABCD_BITS/2)-1 downto 0);
    bx : signed((ABCD_BITS/2)-1 downto 0);
    by : signed((ABCD_BITS/2)-1 downto 0);
    cx : signed((ABCD_BITS/2)-1 downto 0);
    cy : signed((ABCD_BITS/2)-1 downto 0);
    dx : signed((ABCD_BITS/2)-1 downto 0);
    dy : signed((ABCD_BITS/2)-1 downto 0);
  end record;

  type abcd2_t is record
    a      : std_logic_vector(8 downto 0);
    b      : std_logic_vector(8 downto 0);
    c      : std_logic_vector(8 downto 0);
    d      : std_logic_vector(8 downto 0);
    x_frac : unsigned(SUBGRID_BITS-1+COMMA downto 0);
    y_frac : unsigned(SUBGRID_BITS-1+COMMA downto 0);
  end record;


  type d0_t is record
    pr_count   : std_logic_vector(7 downto 0);
    pw_count   : std_logic_vector(7 downto 0);
    auxr_count : std_logic_vector(7 downto 0);
    auxw_count : std_logic_vector(7 downto 0);
    state      : std_logic_vector(15 downto 0);
    fe         : std_logic_vector(7 downto 0);
    p1         : std_logic_vector(7 downto 0);
    p2         : std_logic_vector(7 downto 0);
    p3         : std_logic_vector(7 downto 0);
    p1state    : std_logic_vector(7 downto 0);
    p2state    : std_logic_vector(7 downto 0);
    dvistate   : std_logic_vector(7 downto 0);
    off        : std_logic_vector(7 downto 0);
    off2       : std_logic_vector(7 downto 0);
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

  procedure connect_pipe_join (
    signal clk         : out std_logic;
    signal rst         : out std_logic;
    signal pipe_in_1   : in  pipe_t;
    signal pipe_in_2   : in  pipe_t;
    signal pipe_out    : out pipe_t;
    signal stall_in    : in  std_logic;
    signal stall_out_1 : out std_logic;
    signal stall_out_2 : out std_logic;
    signal stage       : in  stage_t;
    signal src_valid   : out std_logic;
    signal issue       : in  std_logic;
    signal stall       : out std_logic);

  procedure connect_pipe_fork (
    signal clk        : out std_logic;
    signal rst        : out std_logic;
    signal pipe_in    : in  pipe_t;
    signal pipe_out_1 : out pipe_t;
    signal pipe_out_2 : out pipe_t;
    signal stall_in_1 : in  std_logic;
    signal stall_in_2 : in  std_logic;
    signal stall_out  : out std_logic;
    signal stage      : in  stage_t;
    signal stage_2      : in  stage_t;    
    signal src_valid  : out std_logic;
    signal issue      : in  std_logic;
    signal stall      : out std_logic);

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

  procedure connect_pipe_join (
    signal clk         : out std_logic;
    signal rst         : out std_logic;
    signal pipe_in_1   : in  pipe_t;
    signal pipe_in_2   : in  pipe_t;
    signal pipe_out    : out pipe_t;
    signal stall_in    : in  std_logic;
    signal stall_out_1 : out std_logic;
    signal stall_out_2 : out std_logic;
    signal stage       : in  stage_t;
    signal src_valid   : out std_logic;
    signal issue       : in  std_logic;
    signal stall       : out std_logic)
  is
  begin
    clk <= pipe_in_1.ctrl.clk;
    rst <= pipe_in_1.ctrl.rst;

    pipe_out.ctrl  <= pipe_in_1.ctrl;
    pipe_out.cfg   <= pipe_in_1.cfg;
    pipe_out.stage <= stage;

    stall_out_1 <= stall_in or issue or (pipe_in_1.stage.valid and not pipe_in_2.stage.valid);
    stall_out_2 <= stall_in or issue or (not pipe_in_1.stage.valid and pipe_in_2.stage.valid);
    stall       <= stall_in;

    src_valid <= pipe_in_1.stage.valid and pipe_in_2.stage.valid and not (stall_in or issue);
  end procedure connect_pipe_join;

  procedure connect_pipe_fork (
    signal clk        : out std_logic;
    signal rst        : out std_logic;
    signal pipe_in    : in  pipe_t;
    signal pipe_out_1 : out pipe_t;
    signal pipe_out_2 : out pipe_t;
    signal stall_in_1 : in  std_logic;
    signal stall_in_2 : in  std_logic;
    signal stall_out  : out std_logic;
    signal stage      : in  stage_t;
    signal stage_2      : in  stage_t;    
    signal src_valid  : out std_logic;
    signal issue      : in  std_logic;
    signal stall      : out std_logic)
  is
  begin
    clk <= pipe_in.ctrl.clk;
    rst <= pipe_in.ctrl.rst;

    pipe_out_1.ctrl  <= pipe_in.ctrl;
    pipe_out_1.cfg   <= pipe_in.cfg;
    pipe_out_1.stage <= stage;

    pipe_out_2.ctrl  <= pipe_in.ctrl;
    pipe_out_2.cfg   <= pipe_in.cfg;
    pipe_out_2.stage <= stage_2;

    stall_out <= (stall_in_1) or issue;
    stall     <= stall_in_1;    

    src_valid <= pipe_in.stage.valid and not (stall_in_1 or issue);    
  end procedure connect_pipe_fork;
  
  

end cam_pkg;
