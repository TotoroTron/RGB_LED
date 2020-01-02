library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_div is
    Generic (clk_delay : integer);
    Port (
        clk_in : in std_logic;
        clk_out : out std_logic
    );
end clk_div;

architecture Behavioral of clk_div is
begin
    CLOCK_DIV : process(clk_in)
        variable count : integer range 0 to clk_delay := 0;
    begin
        if rising_edge(clk_in) then
            if count = clk_delay then
                clk_out <= '1';
                count := 0;
            else
                clk_out <= '0';
                count := count + 1;
            end if;
        end if;
    end process;

end Behavioral;