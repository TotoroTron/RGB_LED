library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.parameters.all;
Library xpm;
use xpm.vcomponents.all;

entity top_level is
    generic(
        delay : integer := 4
    );
    port(
        clk_in : in std_logic; --internal clock
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
    signal clk2 : std_logic;
    signal frame_req : std_logic;
    signal s_rgb1, s_rgb2 : std_logic_vector(2 downto 0);
    signal s_col : std_logic_vector(4 downto 0); --0 to 31
    signal s_row : std_logic_vector(3 downto 0); --0 to 15
begin
    
    --DISPLAY ON/OFF SWITCH
    with disp_en select rgb1 <=
        "000" when '0',
        s_rgb1 when '1';
    with disp_en select rgb2 <=
        "000" when '0',
        s_rgb2 when '1';
    
    CLOCK_DIV : process(clk_in)
        variable count : integer range 0 to delay;
    begin
        if rising_edge(clk_in) then
            if count < delay/2 then
                clk2 <= '0';
                count := count + 1;
            elsif count < delay then
                clk2 <= '1';
                count := count + 1;
            else
                count := 0;
            end if;
        end if;
    end process;
    
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
        di1 => data(COLOR_DEPTH-1 downto 0),
        di2 => data(2*COLOR_DEPTH-1 downto COLOR_DEPTH)
    );
    
    ANIMATION_BLOCK: entity work.animation(colorcycle)
    port map(
        clk => clk2,
        start => start,
        reset => reset,
        frame_req => frame_req,
        do1 => data(COLOR_DEPTH-1 downto 0),
        do2 => data(2*COLOR_DEPTH-1 downto COLOR_DEPTH)
    );

end Behavioral;
