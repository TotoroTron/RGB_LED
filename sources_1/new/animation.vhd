library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity animation is
    port(
        clk2 : in std_logic;
        start, reset : in std_logic;
        frame_req : in std_logic;
        do : out std_logic_vector(23 downto 0)
    );
end entity;

architecture Behavioral of animation is
    type COLOR_TRANSITIONS is (RED_MAGENTA, MAGENTA_BLUE, BLUE_CYAN, CYAN_GREEN, GREEN_YELLOW, YELLOW_RED);
    signal phase, next_phase : COLOR_TRANSITIONS;
    signal next_do : std_logic_vector(23 downto 0);
    signal r_count, g_count, b_count : integer range 0 to 255;
    signal next_r, next_g, next_b : integer range 0 to 255;
begin

STATE_REGISTER: process(clk2, start, reset)
    variable running : std_logic := '0';
begin
    if rising_edge(clk2) then
        if start = '1' then running := '1'; end if;            
        if reset = '1' then
            r_count <= 255;
            g_count <= 0;
            b_count <= 0;
            phase <= RED_MAGENTA;
        elsif running = '1' then
            r_count <= next_r;
            g_count <= next_g;
            b_count <= next_b;
            phase <= next_phase;
            do <= std_logic_vector(to_unsigned(next_r, 8)) &
                std_logic_vector(to_unsigned(next_g, 8)) &
                std_logic_vector(to_unsigned(next_b, 8));
        end if;
    end if;
end process;

STATE_MACHINE: process(phase, frame_req, r_count, g_count, b_count)
begin
    next_r <= r_count;
    next_g <= g_count;
    next_b <= b_count;
    next_phase <= phase;
    if rising_edge(frame_req) then
        case phase is
        when RED_MAGENTA =>
            if(b_count < 255) then next_b <= b_count + 1;
            else next_phase <= MAGENTA_BLUE; end if;
        when MAGENTA_BLUE =>
            if(r_count >   0) then next_r <= r_count - 1;
            else next_phase <= BLUE_CYAN; end if;
        when BLUE_CYAN =>
            if(g_count < 255) then next_g <= g_count + 1;
            else next_phase <= CYAN_GREEN; end if;
        when CYAN_GREEN =>
            if(b_count >   0) then next_b <= b_count - 1;
            else next_phase <= GREEN_YELLOW; end if;
        when GREEN_YELLOW =>
            if(r_count < 255) then next_r <= r_count + 1;
            else next_phase <= YELLOW_RED; end if;                
        when YELLOW_RED =>
            if(g_count >   0) then next_g <= g_count - 1;
            else next_phase <= RED_MAGENTA; end if;
        end case;

    end if;
end process;

end architecture;