library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.parameters.all;

entity julia_set is
    port(
        img_col : in std_logic_vector(IMG_WIDTH-1 downto 0); -- horizontal coordinate of pixel
        img_row : in std_logic_vector(IMG_HEIGHT/2-1 downto 0); -- vertical coordinate of pixel
        pixel_req : in std_logic; --pixel data request signal from led_control.vhd
        do1 : out std_logic_vector(COLOR_DEPTH-1 downto 0); --data out to led_control.vhd
        do2 : out std_logic_vector(COLOR_DEPTH-1 downto 0) --data out to led_control.vhd
    );
end julia_set;

architecture behavioral of julia_set is
	type pixel_type is array (2 downto 0) of integer range 0 to 2**(COLOR_DEPTH/3)-1;
	--type image_type is array (IMG_WIDTH-1 downto 0, IMG_HEIGHT-1 downto 0) of pixel_type;
	signal pixel : pixel_type; --(R, G, B)
	--signal image : image_type; --image display (not to be confused with imaginary)
begin
	
    JULIA_SET: process(pixel_req)
        -- Julia Set Iterative Equation: z(n+1) = z(n)^2 + c
        -- Assign: y = z(n+1), x = z(n)
        -- y, x, and c are complex numbers
        variable temp_real, temp_imag : real; -- temporary variables for calculations
        variable y_real, y_imag, x_real, x_imag, c_real, c_imag : real;
        --variable level : integer range 1 to 100;
        variable n : integer := 100; -- iterate the julia function n times to check if coord is within the set
        variable i, j : integer;
    begin
        if rising_edge(pixel_req) then
            
            i := to_integer(unsigned(img_col));
            j := to_integer(unsigned(img_row));
            x_real := -1.5 + 1.5 / real(IMG_WIDTH/2) * real(i); -- scale and shift to -1.5 < real < 1.5
            x_imag := -1.5 + 1.5 / real(IMG_HEIGHT/2) * real(j); -- scale and shift to -1.5 < imaginary < 1.5
            
            L1: for k in 1 to n loop
                --use foil method for squaring complex numbers
                temp_real := x_real**2 - x_imag**2 + c_real;
                temp_imag := real(2)*x_real*x_imag + c_imag;
                y_real := temp_real;
                y_imag := temp_imag;
                if y_real < real(2) AND y_imag < real(2) then
                    --image(i, j) <= (63, 63, 63); -- image(i,j) is within julia set
                    pixel <= (63,63,63); --white pixel
                    --level := level + 1;
                else
                    pixel <= (0,0,0); --black pixel
                    --image(i, j) <= (0, 0, 0); -- image(i,j) is outside julia set
                    EXIT L1;
                end if;
            end loop;
            
            do1 <= std_logic_vector(to_unsigned(pixel(2), COLOR_DEPTH/3)) &
                std_logic_vector(to_unsigned(pixel(1), COLOR_DEPTH/3)) &
                std_logic_vector(to_unsigned(pixel(0), COLOR_DEPTH/3));
            do2 <= std_logic_vector(to_unsigned(pixel(2), COLOR_DEPTH/3)) &
                std_logic_vector(to_unsigned(pixel(1), COLOR_DEPTH/3)) &
                std_logic_vector(to_unsigned(pixel(0), COLOR_DEPTH/3));
                
        end if;
    end process;
    
end architecture;
