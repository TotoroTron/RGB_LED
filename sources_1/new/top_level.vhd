library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level is
    generic(
        mode : string := "colorcycle";
        --available modes: colorcycle, rainbowswipe, gifplayer
        delay : integer := 6
    );
    port(
        clk_in : in std_logic; --internal clock
        
        rgb1, rgb2 : out std_logic_vector(2 downto 0);
        sel : out std_logic_vector(3 downto 0);  
        lat : out std_logic;                            
        oe : out std_logic;
        clk_out : out std_logic; --clock to LED display
        reset : in std_logic;
        start : in std_logic;
        gnd : out std_logic_vector(2 downto 0) := "000"
    );
end top_level;

architecture Behavioral of top_level is
    signal data : std_logic_vector(23 downto 0);
    signal clk2 : std_logic;
    signal frame_req : std_logic;
begin
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
        rgb1 => rgb1,
        rgb2 => rgb2,
        sel => sel,
        lat => lat,
        oe => oe,
        clk_out => clk_out,
        reset => reset,
        start => start,
        di => data
    );
    ANIMATION_SELECT: if mode = "colorcycle" generate
    COLORCYCLE: entity work.animation
    port map(
        clk2 => clk2,
        start => start,
        reset => reset,
        frame_req => frame_req,
        do => data
    );
    end generate ANIMATION_SELECT;
end Behavioral;
