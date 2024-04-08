library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity timer is
    port(
        clk     : in std_logic;
        reset   : in std_logic;
        start   : in std_logic;
        react   : in std_logic;
        cycles  : out unsigned(7 downto 0);
        leds    : out std_logic_vector(2 downto 0)
    );
end entity;

architecture Behavioral of timer is
    type state_type is (sIdle, sWait, sCount);

    signal current_state : state_type := sIdle;
    signal next_state    : state_type := sIdle;
    signal count         : unsigned(7 downto 0) := (others => '0');

begin
    -- State machine process
    process (clk, reset)
    begin
        if reset = '0' then
            current_state <= sIdle;
            count         <= (others => '0');
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
    
    -- Next state logic
    process(current_state, start, react) 
			variable is_meta : boolean;
    begin
		  is_meta := false;
        next_state <= current_state;  -- Default
        
		  for i in count'range loop
				if count(i) = 'U' or count(i) = 'X' or count(i) = 'W' or count(i) = '-' then
					is_meta := true;
					exit;
				end if;
		  end loop;

			-- Only proceed if count doesn't have any metavalue
			if not is_meta then
            case current_state is
                when sIdle => 
                    if start = '1' then 
                        next_state <= sWait;
                    end if;
                        
                when sWait => 
                    if start = '1' then
                        next_state <= sIdle;
                    elsif count = "00000100" then
                        next_state <= sCount;
                    end if;
                        
                when sCount =>
                    if react = '1' then
                        next_state <= sIdle;
                    end if;
            end case;
        end if;  -- This handles the undefined value condition
    end process;
    
    -- Counter logic
    process(clk, reset, current_state, start)
    begin
        if reset = '0' then
            count <= (others => '0');
        elsif rising_edge(clk) then
            if current_state = sWait and count < "00000100" then
                count <= count + 1;
            elsif current_state = sCount then
                count <= count + 1;
            elsif current_state = sWait and start = '1' then
                count <= (others => '1');
            end if;
        end if;
    end process;
    
    -- Output behavior
    leds(0) <= '1' when current_state = sIdle else '0';
    leds(1) <= '1' when current_state = sWait else '0';
    leds(2) <= '1' when current_state = sCount else '0';
    cycles <= (others => '0') when current_state = sWait else count;

end Behavioral;