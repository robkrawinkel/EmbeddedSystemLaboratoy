LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.common.ALL;

ENTITY timer IS
	PORT (reset		: IN std_logic;
			CLOCK 	: IN std_logic;
			runClock : IN std_logic;
			result 	: INOUT integer range 0 to 16777215
			);
END timer;

ARCHITECTURE bhv OF timer IS

	
BEGIN

	PROCESS(reset, CLOCK, runClock)
	
		
		
	BEGIN
	
		IF reset = '0' THEN
			result <= 0;
			
		ELSIF runClock = '1' THEN
			
			IF rising_edge(CLOCK) THEN
					result <= result + 1;

			END IF;
				
		END IF;
		
	END PROCESS;
	
  
  
END bhv;