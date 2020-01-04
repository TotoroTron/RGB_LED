library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.parameters.all;

entity led_control is
    Port(
        clk2 : in std_logic; --internal clock
        reset : in std_logic;
        start : in std_logic;
        di1 : in std_logic_vector(COLOR_DEPTH-1 downto 0); --upper
        di2 : in std_logic_vector(COLOR_DEPTH-1 downto 0); --lower
        
        frame_req : out std_logic;
        img_col : out std_logic_vector(4 downto 0);
        img_row : out std_logic_vector(3 downto 0);
        
        rgb1, rgb2 : out std_logic_vector(2 downto 0);
        sel : out std_logic_vector(3 downto 0);  
        lat : out std_logic;                            
        oe : out std_logic;
        clk_out : out std_logic; --clock to LED display
        
        addr : out std_logic_vector(8 downto 0)
    );
end entity;

architecture behavioral of led_control is
    type STATE_TYPE is (INIT, GET_DATA, NEXT_COLUMN, LATCH_INCR_SECTION, INCR_DUTY_FRAME);
    signal state, next_state : STATE_TYPE;
    signal s_rgb1, s_rgb2 : std_logic_vector(2 downto 0);
    signal col, next_col : integer range 0 to IMG_WIDTH-1;
    signal sect, next_sect : integer range 0 to 15;
    
    signal next_rgb1, next_rgb2 : std_logic_vector(2 downto 0);
    signal duty, next_duty : integer range 0 to 2**(COLOR_DEPTH/3)-1;
    signal rep_count, next_rep_count : integer range 0 to 20; --frame repeat
    constant frame_reps : integer := 0;
    
    signal led_count, next_led_count : integer range 0 to 511;
begin

    rgb1 <= s_rgb1; rgb2 <= s_rgb2;

STATE_REGISTER : process(clk2, start, reset)
    variable running : boolean := false;
begin
    if rising_edge(clk2) then
        if start = '1' then running := true; end if;
        if(reset = '1') then
            state <= INIT;
            col <= 0;
            sect <= 0;
            duty <= 0;
            rep_count <= 0;
            led_count <= 0;
        elsif(running = true) then
            state <= next_state;
            s_rgb1 <= next_rgb1;
            s_rgb2 <= next_rgb2;
            col <= next_col;
            sect <= next_sect;
            sel <= std_logic_vector(to_unsigned(next_sect, 4));
            duty <= next_duty;
            rep_count <= next_rep_count;
            led_count <= next_led_count;
            addr <= std_logic_vector(to_unsigned(next_led_count, 9));
        end if;
    end if;
end process;

STATE_MACHINE : process(state, col ,sect, duty, di1, di2, rep_count, led_count)
    variable v_rgb1, v_rgb2 : std_logic_vector(2 downto 0);
    variable r_count1, g_count1, b_count1 : integer range 2**(COLOR_DEPTH/3)-1 downto 0;
    variable r_count2, g_count2, b_count2 : integer range 2**(COLOR_DEPTH/3)-1 downto 0;
begin
    --DEFAULT SIGNAL ASSIGNMENTS
    frame_req <= '0';
    next_rgb1 <= s_rgb1;
    next_rgb2 <= s_rgb2;
    next_state <= state;
    next_col <= col;
    next_sect <= sect;
    next_duty <= duty;
    next_rep_count <= rep_count;
    next_led_count <= led_count;
    v_rgb1 := "000"; v_rgb2 := "000"; clk_out <= '0'; lat <= '0'; oe <= '1';
    
    r_count1 := to_integer( unsigned( di1(  COLOR_DEPTH-1 downto 2*COLOR_DEPTH/3) )); --bits 23 downto 16
    g_count1 := to_integer( unsigned( di1( 2*COLOR_DEPTH/3-1 downto  COLOR_DEPTH/3) )); --bits 15 downto 8
    b_count1 := to_integer( unsigned( di1( COLOR_DEPTH/3-1 downto  0) )); --bits 7 downto 0
    r_count2 := to_integer( unsigned( di2( COLOR_DEPTH-1 downto 2*COLOR_DEPTH/3) )); --bits 23 downto 16
    g_count2 := to_integer( unsigned( di2( 2*(COLOR_DEPTH/3)-1 downto  COLOR_DEPTH/3) )); --bits 15 downto 8
    b_count2 := to_integer( unsigned( di2( COLOR_DEPTH/3-1 downto  0) )); --bits 7 downto 0
    
    case state is
    when INIT =>
        next_state <= GET_DATA;
    when GET_DATA =>
        oe <= '0';
        if(duty < gamma255(r_count1) ) then v_rgb1(2) := '1'; end if;
        if(duty < gamma255(g_count1) ) then v_rgb1(1) := '1'; end if;
        if(duty < gamma255(b_count1) ) then v_rgb1(0) := '1'; end if;
        if(duty < gamma255(r_count2) ) then v_rgb2(2) := '1'; end if;
        if(duty < gamma255(g_count2) ) then v_rgb2(1) := '1'; end if;
        if(duty < gamma255(b_count2) ) then v_rgb2(0) := '1'; end if;        
        next_state <= NEXT_COLUMN;
        
    when NEXT_COLUMN =>
        oe <= '0';  clk_out <= '1';
        if led_count < 511 then
            next_led_count <= led_count + 1;
        else
            next_led_count <= 0;
        end if;        
        if(col < IMG_WIDTH-1) then
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
        if(duty < 2**(COLOR_DEPTH/3)-1) then
            next_duty <= duty + 1;
        else
            next_duty <= 0;
            if(rep_count < frame_reps) then    --display the color frame_reps times before displaying next color
                next_rep_count <= rep_count + 1;
            else
                frame_req <= '1'; --request the next frame
                next_rep_count <= 0;
            end if;
        end if;
        next_state <= GET_DATA;
    end case;
    
    next_rgb1 <= v_rgb1;
    next_rgb2 <= v_rgb2;
end process;
end architecture;