library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.parameters.all;

entity animation is
    port(
        clk : in std_logic;
        start, reset : in std_logic;
        frame_req : in std_logic;
        do1 : out std_logic_vector(COLOR_DEPTH-1 downto 0);
        do2 : out std_logic_vector(COLOR_DEPTH-1 downto 0)
    );
end entity;

architecture colorcycle of animation is
    type COLOR_TRANSITIONS is (
        RED_MAGENTA, MAGENTA_BLUE, BLUE_CYAN, CYAN_GREEN, GREEN_YELLOW, YELLOW_RED
    );
    signal phase : COLOR_TRANSITIONS;
begin

STATE_MACHINE: process(frame_req ,phase)
    variable r_count : integer range 0 to 2**(COLOR_DEPTH/3)-1 := 2**(COLOR_DEPTH/3)-1;
    variable g_count, b_count : integer range 0 to 2**(COLOR_DEPTH/3)-1 := 0;
begin
    if rising_edge(frame_req) then
        case phase is
        when RED_MAGENTA =>
            if(b_count < 2**(COLOR_DEPTH/3)-1) then b_count := b_count + 1;
            else phase <= MAGENTA_BLUE; end if;
        when MAGENTA_BLUE =>
            if(r_count >   0) then r_count := r_count - 1;
            else phase <= BLUE_CYAN; end if;
        when BLUE_CYAN =>
            if(g_count < 2**(COLOR_DEPTH/3)-1) then g_count := g_count + 1;
            else phase <= CYAN_GREEN; end if;
        when CYAN_GREEN =>
            if(b_count >   0) then b_count := b_count - 1;
            else phase <= GREEN_YELLOW; end if;
        when GREEN_YELLOW =>
            if(r_count < 2**(COLOR_DEPTH/3)-1) then r_count := r_count + 1;
            else phase <= YELLOW_RED; end if;                
        when YELLOW_RED =>
            if(g_count >   0) then g_count := g_count - 1;
            else phase <= RED_MAGENTA; end if;
        end case;
        do1 <= std_logic_vector(to_unsigned(r_count, COLOR_DEPTH/3)) &
            std_logic_vector(to_unsigned(g_count, COLOR_DEPTH/3)) &
            std_logic_vector(to_unsigned(b_count, COLOR_DEPTH/3));
        do2 <= std_logic_vector(to_unsigned(r_count, COLOR_DEPTH/3)) &
            std_logic_vector(to_unsigned(g_count, COLOR_DEPTH/3)) &
            std_logic_vector(to_unsigned(b_count, COLOR_DEPTH/3));
    end if;
end process;
end architecture;

architecture solidcolor of animation is
    type COLORS is (
        RED, MAGENTA, BLUE, CYAN, GREEN, YELLOW
    );
    type rgb_type is array (0 to 2) of integer range 0 to 2**(COLOR_DEPTH/3)-1;
    signal phase : COLORS;
begin
STATE_MACHINE: process(frame_req ,phase)
    variable rgb : rgb_type;
    variable period_count : integer range 0 to 100;
begin
    if rising_edge(frame_req) then
        case phase is
        when RED =>
            rgb := (63, 0, 0);
            if period_count < 100 then period_count := period_count + 1;
            else phase <= MAGENTA; period_count := 0; end if;
        when MAGENTA =>
            rgb := (63, 0, 63);
            if period_count < 100 then period_count := period_count + 1;
            else phase <= BLUE; period_count := 0; end if;
        when BLUE =>
            rgb := (0, 0, 63);
            if period_count < 100 then period_count := period_count + 1;
            else phase <= CYAN; period_count := 0; end if;
        when CYAN =>
            rgb := (0, 63, 63);
            if period_count < 100 then period_count := period_count + 1;
            else phase <= GREEN; period_count := 0; end if;
        when GREEN =>
            rgb := (0, 63, 0);
            if period_count < 100 then period_count := period_count + 1;
            else phase <= YELLOW; period_count := 0; end if;                
        when YELLOW =>
            rgb := (32, 32, 0);
            if period_count < 100 then period_count := period_count + 1;
            else phase <= RED; period_count := 0; end if;
        end case;
        do1 <= std_logic_vector(to_unsigned(rgb(0), COLOR_DEPTH/3)) &
            std_logic_vector(to_unsigned(rgb(1), COLOR_DEPTH/3)) &
            std_logic_vector(to_unsigned(rgb(2), COLOR_DEPTH/3));
        do2 <= std_logic_vector(to_unsigned(rgb(0), COLOR_DEPTH/3)) &
            std_logic_vector(to_unsigned(rgb(1), COLOR_DEPTH/3)) &
            std_logic_vector(to_unsigned(rgb(2), COLOR_DEPTH/3));
    end if;
end process;
end architecture;

architecture yellow of animation is
    type rgb_type is array (0 to 2) of integer range 0 to 2**(COLOR_DEPTH/3)-1;
    signal rgb : rgb_type;
begin
    rgb <= (0, 0, 0);
    do1 <= std_logic_vector(to_unsigned(rgb(0), COLOR_DEPTH/3)) &
        std_logic_vector(to_unsigned(rgb(1), COLOR_DEPTH/3)) &
        std_logic_vector(to_unsigned(rgb(2), COLOR_DEPTH/3));
    do2 <= std_logic_vector(to_unsigned(rgb(0), COLOR_DEPTH/3)) &
        std_logic_vector(to_unsigned(rgb(1), COLOR_DEPTH/3)) &
        std_logic_vector(to_unsigned(rgb(2), COLOR_DEPTH/3));
end architecture;
