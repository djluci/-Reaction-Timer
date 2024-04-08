-- Testbench for timer
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timingtest is
end entity timingtest;

architecture sim of timingtest is

    -- Instantiate the timer module
	 signal clk    : std_logic := '0';
	 signal reset  : std_logic := '0';
	 signal start  : std_logic := '1';
	 signal react  : std_logic := '1';	
	 signal cycles : unsigned(7 downto 0) := (others => '0');
	 signal leds   : std_logic_vector(2 downto 0) := (others => '0');
	 signal state_debug : integer := 0; -- Debugging the state 
	 
	 -- Clock period definition 
	 constant clk_period : time := 10 ns;
	 
	 component timer
        Port (
            clk    : in std_logic;
            reset  : in std_logic;
            start  : in std_logic;
            react  : in std_logic;
            cycles : out unsigned(7 downto 0);
            leds   : out std_logic_vector(2 downto 0)
        );
    end component;

begin
    -- Instantiate the UUT (Unit Under Test)
    UUT: timer
    port map (
        clk    => clk,
        reset  => reset,
        start  => start,
        react  => react,
        cycles => cycles,
        leds   => leds
    );

    -- Map state for debugging
    process(clk)
    begin
        if rising_edge(clk) then
            case leds is
                when "100" => state_debug <= 0;  -- sIdle
                when "010" => state_debug <= 1;  -- sWait
                when "001" => state_debug <= 2;  -- sCount
                when others => state_debug <= -1;  -- Invalid state
            end case;
        end if;
    end process;

    -- Clock generation process
    clk_process: process
    begin
        wait for clk_period / 2;
        clk <= not clk;
    end process;

    -- Testbench stimulus process
    stimulus_process: process
	 begin
		-- Initialize
		start <= '0';
		react <= '0';

		-- Extended reset time
		reset <= '0';
		wait for 40 ns;  
		reset <= '1';
		wait for 50 ns;  -- Provide a bit more time after reset
    
		-- Start button press and release
		start <= '1';
		wait for 20 ns;
		start <= '0';
		wait for 50 ns;  -- Wait for state transition

		-- React button press and release during sWait (should set counter to all 1s)
		react <= '1';
		wait for 20 ns;
		react <= '0';
		wait for 50 ns;  

		-- Start button press and release again
		start <= '1';
		wait for 20 ns;
		start <= '0';
		wait for 50 ns;  -- Wait for state transition

		-- React button press and release during sCount
		wait for 50 ns;  
		react <= '1';
		wait for 20 ns;
		react <= '0';

		wait;  -- End the simulation
	end process;
end sim;