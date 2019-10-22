library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.parameters.all;

entity led_control is
    Port(
        clk2 : in std_logic; --internal clock
        reset : in std_logic;
        start : in std_logic;
        di1 : in std_logic_vector(23 downto 0);
        di2 : in std_logic_vector(23 downto 0);
        addr : out std_logic_vector(8 downto 0);
        
        frame_req : out std_logic;
        rgb1, rgb2 : out std_logic_vector(2 downto 0);
        sel : out std_logic_vector(3 downto 0);  
        lat : out std_logic;                            
        oe : out std_logic;
        clk_out : out std_logic --clock to LED display
    );
end entity;

architecture behavioral of led_control is
    type STATE_TYPE is (INIT, GET_DATA, NEXT_COLUMN, LATCH_INCR_SECTION, INCR_DUTY_FRAME);
    signal state, next_state : STATE_TYPE;
    signal col, next_col : integer range 0 to 31;
    signal sect, next_sect : integer range 0 to 15;
    signal next_rgb1, next_rgb2 : std_logic_vector(2 downto 0);
    signal duty, next_duty : integer range 0 to 255;
    signal rep_count, next_rep_count : integer range 0 to 20; --frame repeat
    signal s_addr, next_addr : std_logic_vector(8 downto 0);
    constant frame_reps : integer := 0;
begin

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
            s_addr <= (others => '0');
        elsif(running = true) then
            state <= next_state;
            rgb1 <= next_rgb1;
            rgb2 <= next_rgb2;
            col <= next_col;
            sect <= next_sect;
            sel <= std_logic_vector(to_unsigned(next_sect, 4));
            duty <= next_duty;
            rep_count <= next_rep_count;
            s_addr <= next_addr;
        end if;
    end if;
end process;

STATE_MACHINE : process(state, col ,sect, duty, di1, di2, rep_count)
    variable v_rgb1, v_rgb2 : std_logic_vector(2 downto 0);
    variable r_count1, g_count1, b_count1 : integer range 0 to 255;
    variable r_count2, g_count2, b_count2 : integer range 0 to 255;
begin
    addr <= s_addr;
    frame_req <= '0';
    next_state <= state;
    next_col <= col;
    next_sect <= sect;
    next_duty <= duty;
    next_rep_count <= rep_count;
    r_count1 := to_integer( unsigned( di1(23 downto 16) )); --255
    g_count1 := to_integer( unsigned( di1(15 downto  8) )); --0
    b_count1 := to_integer( unsigned( di1( 7 downto  0) )); --0
    r_count2 := to_integer( unsigned( di2(23 downto 16) )); --255
    g_count2 := to_integer( unsigned( di2(15 downto  8) )); --0
    b_count2 := to_integer( unsigned( di2( 7 downto  0) )); --0
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
        if(duty < gamma(r_count1) ) then v_rgb1(0) := '1'; end if;
        if(duty < gamma(g_count1) ) then v_rgb1(1) := '1'; end if;
        if(duty < gamma(b_count1) ) then v_rgb1(2) := '1'; end if;
        if(duty < gamma(r_count2) ) then v_rgb2(0) := '1'; end if;
        if(duty < gamma(g_count2) ) then v_rgb2(1) := '1'; end if;
        if(duty < gamma(b_count2) ) then v_rgb2(2) := '1'; end if;        
        next_state <= NEXT_COLUMN;
    when NEXT_COLUMN =>
        oe <= '0';
        clk_out <= '1';
        if( to_integer( unsigned (s_addr)) < 511) then
            next_addr <= std_logic_vector(unsigned(s_addr) + 1);
        else
            next_addr <= (others => '0');
        end if;
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