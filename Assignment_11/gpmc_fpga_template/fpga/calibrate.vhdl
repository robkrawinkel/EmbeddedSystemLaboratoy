-- Calibration happens in 5 states for both motors simultaneously
	-- 	0:	Reset stepcounters to 0
	--	1:	Rotate motors with fixed dutycycle in the negative direction until step count has not changed significantly (more than x) for 100ms
	--	2: 	Reset stepcounters to 0 and update min stepCount
	--	3:	Rotate motors with fixed dutycycle in the positive direction until step count has not changed significantly (mroe than x) for 100ms
	--	4: 	Update max stepcount
	--	5: 	Rotate to half the max step count (predefined per motor)

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY calibrate IS
	PORT (
		-- CLOCK and reset
		reset		: IN std_logic;
		CLOCK_50	: IN std_logic;

		-- Enable calibration
		calibrate_enable	: IN std_logic;
		calibrate_running	: INOUT std_logic;

		-- Motor control
		dutycycle0			: OUT integer RANGE 0 TO 100;
		dutycycle1			: OUT integer RANGE 0 TO 100;
		CW0					: OUT std_logic;
		CW1					: OUT std_logic;
		PWM_enable0			: INOUT std_logic;
		PWM_enable1			: INOUT std_logic;

		-- Stepcount control
		stepCount0			: IN integer RANGE -8192 TO 8191;
		stepCount0_min		: INOUT integer RANGE -8192 TO 0;
		stepCount0_max		: INOUT integer RANGE 0 TO 8191;
		stepCount1			: IN integer RANGE -8192 TO 8191;
		stepCount1_min		: INOUT integer RANGE -8192 TO 0;
		stepCount1_max		: INOUT integer RANGE 0 TO 8191;
		stepReset			: OUT std_logic

	);
END ENTITY;

ARCHITECTURE bhv OF calibrate IS
	
	CONSTANT calibrate_clockTimeout 		: integer := 50000000;	-- 5.000.000 clock pulses for 100ms
	CONSTANT calibrate_stepCount_driftMax 	: integer := 5;			-- The maximum amount of steps a stepCount may drift at the end position
	CONSTANT calibrate0_dutyCycle			: integer := 50;		-- Dutycycle that powers the motors during calibration
	CONSTANT calibrate1_dutyCycle			: integer := 25;		-- Dutycycle that powers the motors during calibration
	CONSTANT calibrateR_dutyCycle			: integer := 20;		-- Dutycycle when moving to final position

BEGIN

	-- Create a process which reacts to the specified signals
	PROCESS(reset, CLOCK_50)
	
		-- Variables for the calibrate process
		VARIABLE calibrate_state 			: integer RANGE 0 TO 5 := 0;
		VARIABLE calibrate_stepCount0_old 	: integer RANGE -8192 TO 8191 := -8190;
		VARIABLE calibrate_stepCount1_old 	: integer RANGE -8192 TO 8191 := -8190;
		VARIABLE calibrate_clockCounter 	: integer := 0;

		VARIABLE calibrate_enable_old		: std_logic := '0';

	BEGIN
		
		-- Reset everything
		IF reset = '1' THEN
			
			calibrate_state := 0;
			calibrate_running <= '0';

			calibrate_enable_old := '0';

			stepCount0_min <= -8192;
			stepCount0_max <= 8191;
			stepCount1_min <= -8192;
			stepCount1_max <= 8191;
			
		ELSIF rising_edge(CLOCK_50) THEN

			-- If calibrate enable changed to being on, start calibration
			IF calibrate_enable /= calibrate_enable_old AND calibrate_enable = '1' THEN
				calibrate_running <= '1';
				calibrate_state := 0;

				calibrate_enable_old := calibrate_enable;
			ELSE
				calibrate_enable_old := calibrate_enable;
			END IF;

			-- If calibration is running
			IF (calibrate_running = '1') THEN
				CASE calibrate_state IS
					WHEN 0 =>		

						-- Reset all calibrate variables to start calibration
						calibrate_stepCount0_old := 0;
						calibrate_stepCount1_old := 0;

						calibrate_clockCounter := 0;

						stepReset <= '1';

						-- Set the stepcount limits very high such that they can be recalibrated
						stepCount0_min <= -8192;
						stepCount0_max <= 8191;
						stepCount1_min <= -8192;
						stepCount1_max <= 8191;

						-- Setup the motors
						dutycycle0 <= calibrate0_dutyCycle;
						dutycycle1 <= calibrate1_dutyCycle;

						-- Update state
						calibrate_state := 1;

					WHEN 1 =>
						-- Start moving to minimum position
						-- Start both motors with a fixed dutycycle		
						
						-- Stop resetting the stepCount so that it can change again
						stepReset <= '0';

						-- Set the motors to start rotating counterclockwise (negative stepCount)
						CW0 <= '0';
						CW1 <= '0';
						PWM_enable0 <= '1';
						PWM_enable1 <= '1';

						-- Check the stepCount variables on a timeout to see if they have changed since the last check
						-- Increase timer while timeout has not been reached yet
						IF (calibrate_clockCounter < calibrate_clockTimeout) THEN
							calibrate_clockCounter := calibrate_clockCounter + 1;

						ELSE
							-- Check to see if either of the step counts has changed more than the set amount since the last timeout
							IF ((ABS(stepCount0 - calibrate_stepCount0_old) > calibrate_stepCount_driftMax) OR
								(ABS(stepCount1 - calibrate_stepCount1_old) > calibrate_stepCount_driftMax)) THEN
								
								-- If one of them has changed substatially, update the old values and reset the clock counter
								calibrate_stepCount0_old := stepCount0;
								calibrate_stepCount1_old := stepCount1;
								calibrate_clockCounter := 0;

							ELSE
								-- If neither changed substantially, they have reached their end stop and the next stage is reached
								calibrate_state := 2;

								-- Turn off the motors
								PWM_enable0 <= '0';
								PWM_enable1 <= '0';

							END IF;

						END IF;

					WHEN 2 =>
						-- Set the stepcounts to 0 now that the end position has been reached
						stepReset <= '1';

						-- Set the stepcount minimums to 0
						stepCount0_min <= 0;
						stepCount1_min <= 0;

						-- Reset the calibrate variables to prepare for next step
						calibrate_stepCount0_old := 0;
						calibrate_stepCount1_old := 0;
						calibrate_clockCounter := 0;

						-- Update the calibrate state
						calibrate_state := 3;

					WHEN 3 =>
						-- Start moving to maximum position
						-- Start both motors with a fixed dutycycle		
						
						-- Stop resetting the stepCount, such that it can change again.
						stepReset <= '0';

						-- Set the motors to start rotating clockwise (positive stepCount)
						CW0 <= '1';
						CW1 <= '1';
						PWM_enable0 <= '1';
						PWM_enable1 <= '1';

						-- Check the stepCount variables on a timeout to see if they have changed since the last check
						-- Increase timer while timeout has not been reached yet
						IF (calibrate_clockCounter < calibrate_clockTimeout) THEN
							calibrate_clockCounter := calibrate_clockCounter + 1;

						ELSE
							-- Check to see if either of the step counts has changed more than the set amount since the last timeout
							IF ((ABS(stepCount0 - calibrate_stepCount0_old) > calibrate_stepCount_driftMax) OR
								(ABS(stepCount1 - calibrate_stepCount1_old) > calibrate_stepCount_driftMax)) THEN
								
								-- If one of them has changed substatially, update the old values and reset the clock counter
								calibrate_stepCount0_old := stepCount0;
								calibrate_stepCount1_old := stepCount1;
								calibrate_clockCounter := 0;

							ELSE
								-- If neither changed substantially, they have reached their end stop and the next stage is reached
								calibrate_state := 4;

								-- Turn off the motors
								PWM_enable0 <= '0';
								PWM_enable1 <= '0';

							END IF;

						END IF;

					WHEN 4 =>
						-- Set the stepcounts maximums to the current values
						stepCount0_max <= stepCount0;
						stepCount1_max <= stepCount1;

						-- Update the calibrate state
						calibrate_state := 5;

					WHEN 5 =>
						-- Now move the motors until the half way point of the encoders has been reached

						-- Setup the motors to move counterclockwise (negative stepCount)
						CW0 <= '0';
						CW1 <= '0';

						-- Setup the motors
						dutycycle0 <= calibrateR_dutyCycle;
						dutycycle1 <= calibrateR_dutyCycle;

						-- If motor 0 is not at its half way point yet
						IF (stepCount0 > stepCount0_max / 2) THEN
							PWM_enable0 <= '1';
						ELSE
							PWM_enable0 <= '0';
						END IF;

						-- If motor 1 is not at its half way point yet
						IF (stepCount1 > stepCount1_max / 2) THEN
							PWM_enable1 <= '1';
						ELSE
							PWM_enable1 <= '0';
						END IF;

						-- If both are at their half way point (the motors have been disabled), calibration is complete
						IF (stepCount0 <= stepCount0_max / 2 AND stepCount1 <= stepCount1_max / 2) THEN
							calibrate_running <= '0';
							calibrate_state := 0;
						END IF;

					WHEN OTHERS =>
							-- It should not be possible to get to another state but if so, move back to the first step
							calibrate_state := 0;
				END CASE;	
			END IF;

		END IF;
		
	END PROCESS;
	

END bhv;