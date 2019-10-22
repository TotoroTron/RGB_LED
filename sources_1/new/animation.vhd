library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity animation is
    generic( mode : string );
    port(
        start, reset : in std_logic;
        frame_req : in std_logic;
        do1 : out std_logic_vector(23 downto 0);
        do2 : out std_logic_vector(23 downto 0)
    );
end entity;

architecture colorcycle of animation is
    type COLOR_TRANSITIONS is (RED_MAGENTA, MAGENTA_BLUE, BLUE_CYAN, CYAN_GREEN, GREEN_YELLOW, YELLOW_RED);
begin

STATE_MACHINE: process(frame_req, start, reset)
    variable running : boolean := false;
    variable phase : COLOR_TRANSITIONS;
    variable r_count : integer range 0 to 255 := 255;
    variable g_count, b_count : integer range 0 to 255 := 0;
begin
    if start = '1' then running := true; end if;
    if reset = '1' then
        r_count := 255;
        g_count := 0;
        b_count := 0;
        phase := RED_MAGENTA;
    elsif rising_edge(frame_req) then
        case phase is
        when RED_MAGENTA =>
            if(b_count < 255) then b_count := b_count + 1;
            else phase := MAGENTA_BLUE; end if;
        when MAGENTA_BLUE =>
            if(r_count >   0) then r_count := r_count - 1;
            else phase := BLUE_CYAN; end if;
        when BLUE_CYAN =>
            if(g_count < 255) then g_count := g_count + 1;
            else phase := CYAN_GREEN; end if;
        when CYAN_GREEN =>
            if(b_count >   0) then b_count := b_count - 1;
            else phase := GREEN_YELLOW; end if;
        when GREEN_YELLOW =>
            if(r_count < 255) then r_count := r_count + 1;
            else phase := YELLOW_RED; end if;                
        when YELLOW_RED =>
            if(g_count >   0) then g_count := g_count - 1;
            else phase := RED_MAGENTA; end if;
        end case;
        do1 <= std_logic_vector(to_unsigned(r_count, 8)) &
            std_logic_vector(to_unsigned(g_count, 8)) &
            std_logic_vector(to_unsigned(b_count, 8));
        do2 <= std_logic_vector(to_unsigned(r_count, 8)) &
            std_logic_vector(to_unsigned(g_count, 8)) &
            std_logic_vector(to_unsigned(b_count, 8));
    end if;
end process;
end architecture;

architecture colorswipe of animation is
begin


end architecture;