library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.parameters.all;

entity led_control is
    Port(
        clk2 : in std_logic; --internal clock
        reset : in std_logic;
        start : in std_logic;
        di : in std_logic_vector(23 downto 0) := X"FF0000";
        
        frame_req : out std_logic;
        rgb1, rgb2 : out std_logic_vector(2 downto 0);
        sel : out std_logic_vector(3 downto 0);  
        lat : out std_logic;                            
        oe : out std_logic;
        clk_out : out std_logic --clock to LED display
    );
end entity;

architecture behavioral of led_control is
    type STATE_TYPE is (INIT, GET_DATA, NEXT_COLUMN, LATCH_INCR_SECTION, INCR_DUTY_FRAME, ANIMATE);
    signal state, next_state : STATE_TYPE;
    type COLOR_TRANSITIONS is (RED_MAGENTA, MAGENTA_BLUE, BLUE_CYAN, CYAN_GREEN, GREEN_YELLOW, YELLOW_RED);
    signal col, next_col : integer range 0 to 31;
    signal sect, next_sect : integer range 0 to 15;
    signal next_rgb1, next_rgb2 : std_logic_vector(2 downto 0);
    signal duty, next_duty : integer range 0 to 255;
    signal rep_count, next_rep_count : integer range 0 to 20; --frame repeat
    signal phase, next_phase : COLOR_TRANSITIONS;
    signal next_di : std_logic_vector(23 downto 0);
    constant frame_reps : integer := 0;
begin

STATE_REGISTER : process(clk2, start, reset)
    variable running : std_logic := '0';
begin
    if rising_edge(clk2) then
        if start = '1' then running := '1'; end if;
        if(reset = '1') then
            state <= INIT;
            col <= 0;
            sect <= 0;
            duty <= 0;
            rep_count <= 0;
            phase <= RED_MAGENTA;
        elsif(running = '1') then
            state <= next_state;
            rgb1 <= next_rgb1;
            rgb2 <= next_rgb2;
            col <= next_col;
            sect <= next_sect;
            sel <= std_logic_vector(to_unsigned(next_sect, 4));
            duty <= next_duty;
            rep_count <= next_rep_count;
            phase <= next_phase;
        end if;
    end if;
end process;
STATE_MACHINE : process(state, col ,sect, duty, di, rep_count)
    variable v_rgb1, v_rgb2 : std_logic_vector(2 downto 0);
    variable r_count, g_count, b_count : integer range 0 to 255;
begin
    frame_req <= '0';
    next_state <= state;
    next_di <= di;
    next_col <= col;
    next_sect <= sect;
    next_duty <= duty;
    next_rep_count <= rep_count;
    next_phase <= phase;
    r_count := to_integer( unsigned( di(23 downto 16) )); --255
    g_count := to_integer( unsigned( di(15 downto  8) )); --0
    b_count := to_integer( unsigned( di( 7 downto  0) )); --0
    v_rgb1 := "000"; 
    v_rgb2 := "000";
    clk_out <= '0';
    lat <= '0';
    oe <= '1';
    
    case state is
    when INIT =>
        next_state <= GET_DATA;
    when GET_DATA =>
        oe <= '0';
        if(duty < gamma(r_count) ) then v_rgb1(0) := '1'; v_rgb2(0) := '1'; end if;
        if(duty < gamma(g_count) ) then v_rgb1(1) := '1'; v_rgb2(1) := '1'; end if;
        if(duty < gamma(b_count) ) then v_rgb1(2) := '1'; v_rgb2(2) := '1'; end if;
        next_state <= NEXT_COLUMN;
    when NEXT_COLUMN =>
        oe <= '0';
        clk_out <= '1';
        if(col < 31) then
            next_col <= col + 1;
            next_state <= GET_DATA;
        else
            next_col <= 0;
            next_state <= LATCH_INCR_SECTION;
        end if;
    when LATCH_INCR_SECTION =>
        lat <= '1';
        if(sect < 15) then
            next_sect <= sect + 1;
            next_state <= GET_DATA;
        else
            next_sect <= 0;
            next_state <= INCR_DUTY_FRAME;
        end if;
    when INCR_DUTY_FRAME =>
        if(duty < 255) then
            next_duty <= duty + 1;
            next_state <= GET_DATA;
        else
            next_duty <= 0;
            if(rep_count < frame_reps) then    --display the color frame_reps times before displaying next color
                next_rep_count <= rep_count + 1;
                next_state <= GET_DATA;
            else
                frame_req <= '1';
                next_rep_count <= 0;
                next_state <= ANIMATE;
            end if;
        end if;
    when ANIMATE => 
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
        next_state <= GET_DATA;
    end case;
    next_di <= std_logic_vector(to_unsigned(r_count, 8)) &
            std_logic_vector(to_unsigned(g_count, 8)) &
            std_logic_vector(to_unsigned(b_count, 8));
    next_rgb1 <= v_rgb1;
    next_rgb2 <= v_rgb2;
    
end process;
end architecture;