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
    shared variable r_count, g_count, b_count : integer range 0 to 255;
begin

STATE_REGISTER: process(clk2, start, reset)
    variable running : std_logic := '0';
begin
    if rising_edge(clk2) then
        if start = '1' then running := '1'; end if;            
        if reset = '1' then
            r_count := 255;
            g_count := 0;
            b_count := 0;
            phase <= RED_MAGENTA;
        else
            phase <= next_phase;
            do <= next_do;
        end if;
    end if;
end process;

STATE_MACHINE: process(phase, frame_req)
begin
    if frame_req = '1' then
        case phase is
        when RED_MAGENTA =>
            if(b_count < 255) then b_count := b_count + 1;
            else next_phase <= MAGENTA_BLUE; end if;
        when MAGENTA_BLUE =>
            if(r_count >   0) then r_count := r_count - 1;
            else next_phase <= BLUE_CYAN; end if;
        when BLUE_CYAN =>
            if(g_count < 255) then g_count := g_count + 1;
            else next_phase <= CYAN_GREEN; end if;
        when CYAN_GREEN =>
            if(b_count >   0) then b_count := b_count - 1;
            else next_phase <= GREEN_YELLOW; end if;
        when GREEN_YELLOW =>
            if(r_count < 255) then r_count := r_count + 1;
            else next_phase <= YELLOW_RED; end if;                
        when YELLOW_RED =>
            if(g_count >   0) then g_count := g_count - 1;
            else next_phase <= RED_MAGENTA; end if;
        end case;
        next_do <= std_logic_vector(to_unsigned(r_count, 8)) &
            std_logic_vector(to_unsigned(g_count, 8)) &
            std_logic_vector(to_unsigned(b_count, 8));
    end if;
end process;


end architecture;