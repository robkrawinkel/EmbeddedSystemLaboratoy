-- QuadratureEncoder, used to count the number of steps the motor has turned.

-- The steps are created using a state machine, as follows:
-- 	State	0	1	2	3 
---------------------------
--	A 		0	0	1	1
--  B 		0	1	1	0
-------------------------

-- If the transition from state 3 to 0 happens, the counter is increased. If 0 to 3 happens, the counter is decreased.
-- State 4 is used if the current state is not known.

-- Every cycle the current state is compared to the previous state. If the next state is not a neighbour of the last state due to too high a speed, 
-- the previous direction of rotation is used.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY QuadratureEncoder IS
	PORT (
	-- CLOCK and reset
	reset		: IN std_logic;
	CLOCK_50	: IN std_logic;

	-- Signals from the encoder
	signalA		: IN std_logic;
	signalB		: IN std_logic;
	
	-- Output step counter in 32 bits signed
	stepCount 	: INOUT integer RANGE -8192 TO 8191;

	-- Input stepCount min and max value
	stepCount_min	: IN integer RANGE -8192 TO 0;
	stepCount_max	: IN integer RANGE 0 TO 8191;

	--Reset stepcount to 0
	stepReset : IN std_logic

	);
END ENTITY;

ARCHITECTURE bhv OF QuadratureEncoder IS
	SIGNAL inputSignals : std_logic_vector(1 downto 0);

BEGIN

	-- Create a process which reacts to the specified signals
	PROCESS(reset, CLOCK_50)
	
		-- Create variable to keep track of direction, ClockWise
		VARIABLE CW	: std_logic;
		VARIABLE state: integer range 0 to 4;
		
		-- Variables to keep track of previous states
		VARIABLE oldState : integer range 0 to 4;

	BEGIN
		
		-- Reset everything
		IF reset = '1' THEN
			stepCount <= 0;
			state := 4;
			CW := '0';
			
		-- If A is detected
		ELSIF rising_edge(CLOCK_50) THEN

			IF stepReset = '1' THEN
				stepCount <= 0;
				
			ELSE

				inputSignals <= signalA & signalB;
				
				IF state = 4 THEN
					--redefine state as the current one is not known, don't do anything else
					CASE inputSignals IS
						WHEN "00" => state := 0;
						WHEN "01" => state := 1;
						WHEN "11" => state := 2;
						WHEN "10" => state := 3;
						WHEN OTHERS => state := 4;
					END CASE;
					
					
				ELSE
					CASE inputSignals IS
						WHEN "00" => state := 0;
						WHEN "01" => state := 1;
						WHEN "11" => state := 2;
						WHEN "10" => state := 3;
						WHEN OTHERS => state := 4;
					END CASE;
					
					--if something has changed, find out if the counter should be increased/decreased and set the rotational direction
					IF state /= oldState THEN
						IF state = oldState + 1 THEN
							CW := '1';
						ELSIF state = 0 AND oldState = 3 THEN
							CW := '1';

							IF stepCount < stepCount_max THEN
								stepCount <= stepCount + 1;
							ELSE
								stepCount <= stepCount_max;
							END IF;

						ELSIF state = oldState - 1 THEN
							CW := '0';
						ELSIF state = 3 AND oldState = 0 THEN
							CW := '0';

							IF stepCount > stepCount_min THEN
								stepCount <= stepCount - 1;
							ELSE
								stepCount <= stepCount_min;
							END IF;

						ELSE
							-- if it is not an increase or decrease of one step, assume the rotational direction didn't change and check if the counter should be increased
							IF state < oldState AND CW = '1' THEN
								IF stepCount < stepCount_max THEN
									stepCount <= stepCount + 1;
								ELSE
									stepCount <= stepCount_max;
								END IF;

							ELSIF state > oldState AND CW = '0' THEN
								IF stepCount > stepCount_min THEN
									stepCount <= stepCount - 1;
								ELSE
									stepCount <= stepCount_min;
								END IF;
								
							END IF;
						END IF;
					END IF;
					
				
				END IF;
				
				--store old state for next loop
				oldState := state;

			END IF;
			
		END IF;
		
	END PROCESS;
	

END bhv;