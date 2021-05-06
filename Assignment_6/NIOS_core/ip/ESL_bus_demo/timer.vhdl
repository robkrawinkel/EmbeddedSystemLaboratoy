LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY timer IS
	PORT (reset		: IN std_logic;
			CLOCK 	: IN std_logic;
			runTimer : IN std_logic;
			result 	: INOUT integer;
			);
END timer;

ARCHITECTURE bhv OF timer IS

	
BEGIN

	PROCESS(reset, CLOCK, runTimer)
	
		
		
	BEGIN
	
		IF reset = '1' THEN
			result <= 0;
			timerLimit <= '0';
			
		ELSIF runTimer = '1' THEN
			
			IF rising_edge(CLOCK) THEN
				result <= result + 1;
				END IF;

			END IF;
				
		END IF;
		
	END PROCESS;
	
  
  
END bhv;