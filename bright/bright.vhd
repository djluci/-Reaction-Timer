-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;

entity bright is

	port(
		clk		 : in	std_logic;
		buttonOne : in std_logic;
		buttonTwo : in std_logic;
		buttonThree : in std_logic;
		reset	 : in	std_logic;
		greenLED	 : out	std_logic_vector(3 downto 0));
	);

end entity;

architecture rtl of bright is

	-- Build an enumerated type for the state machine
	type state_type is (sIdle, sOne, sTwo, sThree);

	-- Register to hold the current state
	signal state   : state_type;

begin

	-- Logic to advance to the next state
	process (clk, reset)
	begin
		if reset = '0' then
			state <= sIdle;
		elsif (rising_edge(clk)) then
			case state is
				when sIdle=>
					if buttonOne = '0' then
						state <= sOne;
					else
						state <= sIdle;
					end if;
				when sOne=>
					if buttonTwo = '0' then
						state <= sTwo;
					elsif buttonOne = '0' then 
						state <= sOne;
					else
						state <= sIdle;
					end if;
				when sTwo=>
					if buttonThree = '0' then
						state <= sThree;
					elsif buttonTwo = '0' then 
						state <= sTwo;
					else
						state <= sIdle;
					end if;
				when sThree =>
					if buttonThree = '0' then
						state <= sThree;
					else
						state <= sIdle;
					end if;
			end case;
		end if;
	end process;

	-- Output depends solely on the current state
	process (state)
	begin
		case state is
			when sIdle =>
				greenLED <= "0001";
			when sOne =>
				greenLED <= "0010";
			when sTwo =>
				greenLED <= "0100";
			when sThree =>
				greenLED <= "1000";
		end case;
	end process;

end rtl;

