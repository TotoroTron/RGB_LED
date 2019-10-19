----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/11/2019 12:18:17 AM
-- Design Name: 
-- Module Name: testbench - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is
    signal clk_tb : std_logic;
    signal rgb1_tb, rgb2_tb : std_logic_vector(2 downto 0);
    signal sel_tb : std_logic_vector(3 downto 0);
    signal lat_tb, oe_tb, clk_out_tb : std_logic;
    signal start_tb, reset_tb : std_logic;
    constant clk_period : time := 10ns;
begin
    UUT : entity work.led_control
    port map(
        clk_in => clk_tb,
        rgb1 => rgb1_tb,
        rgb2 => rgb2_tb,
        sel => sel_tb,
        lat => lat_tb,
        oe => oe_tb,
        clk_out => clk_out_tb,
        start => start_tb,
        reset => reset_tb
    );
    
    CLOCK_GEN : process
    begin
        start_tb <= '1';
        reset_tb <= '0';
        clk_tb <= '1';
        wait for clk_period/2;
        clk_tb <= '0';
        wait for clk_period/2;
    end process;
end Behavioral;
