library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.parameters.all;
Library xpm;
use xpm.vcomponents.all;

entity top_level is
    generic(
        clk_delay : integer := 4
    );
    port(
        clk : in std_logic; --internal clock
        reset : in std_logic;
        start : in std_logic;
        disp_en : in std_logic;
        rgb1, rgb2 : out std_logic_vector(2 downto 0);
        sel : out std_logic_vector(3 downto 0);  
        lat : out std_logic;                            
        oe : out std_logic;
        clk_out : out std_logic; --clock to LED display
        gnd : out std_logic_vector(2 downto 0) := "000"
    );
end top_level;

architecture Behavioral of top_level is
    signal data : std_logic_vector(2*COLOR_DEPTH-1 downto 0); --MSB: lower half, LSB: upper half
--    SIGNAL NOT_DATA : std_logic_vector(2*COLOR_DEPTH-1 downto 0); 
    signal addr : std_logic_vector(8 downto 0); --512 locations
    signal addr_upper : std_logic_vector(9 downto 0); --1024 locations
    signal addr_lower : std_logic_vector(9 downto 0); --1024 locations
    
    signal clk2 : std_logic;
    signal clk3 : std_logic;
    signal frame_req : std_logic;
    signal s_rgb1, s_rgb2 : std_logic_vector(2 downto 0);
    signal s_col : std_logic_vector(4 downto 0); --0 to 31
    signal s_row : std_logic_vector(3 downto 0); --0 to 15
begin
    
    --DISPLAY ON/OFF SWITCH
    with disp_en select rgb1 <=
        "000" when '0',
        s_rgb1 when '1',
        "000" when others;
    with disp_en select rgb2 <=
        "000" when '0',
        s_rgb2 when '1',
        "000" when others;
    
	CLK_DIV_LED_CONTROL : entity work.clk_div
        generic map(clk_delay => clk_delay)
        port map(
           clk_in => clk,
           clk_out => clk2
    );
    
    LED_CONTROL: entity work.led_control
    port map(
        clk2 => clk2,
        frame_req => frame_req,
        rgb1 => s_rgb1,
        rgb2 => s_rgb2,
        sel => sel,
        lat => lat,
        oe => oe,
        clk_out => clk_out,
        reset => reset,
        start => start,
        di1 => data(COLOR_DEPTH-1 downto 0), --upper
        di2 => data(2*COLOR_DEPTH-1 downto COLOR_DEPTH), --lower
        addr => addr
    );
    
    addr_upper <= '0' & addr;
    addr_lower <= '1' & addr;
--    data <= NOT not_data;
    
    xpm_memory_dprom_inst : xpm_memory_dprom
    generic map (
        ADDR_WIDTH_A => 10, -- DECIMAL
        ADDR_WIDTH_B => 10, -- DECIMAL
        AUTO_SLEEP_TIME => 0, -- DECIMAL
        ECC_MODE => "no_ecc", -- String
        MEMORY_INIT_FILE => "romTemp.mem", -- String
        MEMORY_INIT_PARAM => "0", -- String
        MEMORY_OPTIMIZATION => "false", -- String
        MEMORY_PRIMITIVE => "block", -- String
        MEMORY_SIZE => 24576, -- 32x32x24
        MESSAGE_CONTROL => 0, -- DECIMAL
        READ_DATA_WIDTH_A => 24, -- DECIMAL
        READ_DATA_WIDTH_B => 24, -- DECIMAL
        READ_LATENCY_A => 1, -- DECIMAL
        READ_RESET_VALUE_A => "0", -- String
        READ_LATENCY_B => 1, -- DECIMAL
        READ_RESET_VALUE_B => "0", -- String
        USE_MEM_INIT => 1, -- DECIMAL
        WAKEUP_TIME => "disable_sleep" -- String
    )
    port map (
        douta => data(COLOR_DEPTH-1 downto 0), --upper
        doutb => data(2*COLOR_DEPTH-1 downto COLOR_DEPTH), --lower
        addra => addr_upper,
        addrb => addr_lower,
        clka => clk, --ref clock
        clkb => clk, --ref clock
        ena => '1',
        enb => '1',
        injectdbiterra => '0', -- 1-bit input: Do not change from the provided value.
        injectsbiterra => '0', -- 1-bit input: Do not change from the provided value.
        injectdbiterrb => '0', -- 1-bit input: Do not change from the provided value.
        injectsbiterrb => '0', -- 1-bit input: Do not change from the provided value.
        regcea => '1',
        regceb => '1',
        rsta => '0',
        rstb => '0',
        sleep => '0'
    );
    
    

end Behavioral;
