-- Calibration happens in 6 states
	-- 	0:	Reset stepcounter to 0
	--	1:	Rotate motor with fixed dutycycle in the negative direction until step count has not changed significantly (more than x) for 100ms
	--	2: 	Reset stepcounter to 0 and update min stepCount
	--	3:	Rotate motor with fixed dutycycle in the positive direction until step count has not changed significantly (mroe than x) for 100ms
	--	4: 	Update max stepcount
	--	5: 	Rotate to half the max step count

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
		dutycycle			: OUT integer RANGE 0 TO 100;
		CW					: OUT std_logic;
		PWM_enable			: INOUT std_logic;
		calibrate_dutyCycle	: IN integer RANGE 0 TO 100;

		-- Stepcount control
		stepCount			: IN integer RANGE -8192 TO 8191;
		stepCount_min		: INOUT integer RANGE -8192 TO 0;
		stepCount_max		: INOUT integer RANGE 0 TO 8191;
		stepReset			: OUT std_logic

	);
END ENTITY;

ARCHITECTURE bhv OF calibrate IS
	
	CONSTANT calibrate_clockTimeout 		: integer := 5000000;	-- 5.000.000 clock pulses for 100ms
	CONSTANT calibrate_stepCount_driftMax 	: integer := 5;			-- The maximum amount of steps a stepCount may drift at the end position
	CONSTANT calibrate_dutyCycleR			: integer := 20;

BEGIN

	-- Create a process which reacts to the specified signals
	PROCESS(reset, CLOCK_50)
	
		-- Variables for the calibrate process
		VARIABLE calibrate_state 			: integer RANGE 0 TO 5;
		VARIABLE calibrate_stepCount_old 	: integer RANGE -8192 TO 8191;
		VARIABLE calibrate_clockCounter 	: integer;

		VARIABLE calibrate_enable_old		: std_logic;

	BEGIN
		
		-- Reset everything
		IF reset = '1' THEN
			
			calibrate_state := 0;
			calibrate_running <= '0';

			calibrate_enable_old := '0';

			stepCount_min <= -8192;
			stepCount_max <= 8191;
			
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
						calibrate_stepCount_old := 0;

						calibrate_clockCounter := 0;

						stepReset <= '1';

						-- Set the stepcount limits very high such that they can be recalibrated
						stepCount_min <= -8192;
						stepCount_max <= 8191;

						-- Setup the motors
						dutycycle <= calibrate_dutyCycle;

						-- Update state
						calibrate_state := 1;

					WHEN 1 =>
						-- Start moving to minimum position	
						
						-- Stop resetting the stepCount so that it can change again
						stepReset <= '0';

						-- Set the motor to start rotating counterclockwise (negative stepCount)
						CW <= '0';
						PWM_enable <= '1';

						-- Check the stepCount variables on a timeout to see if it has changed since the last check
						-- Increase timer while timeout has not been reached yet
						IF (calibrate_clockCounter < calibrate_clockTimeout) THEN
							calibrate_clockCounter := calibrate_clockCounter + 1;

						ELSE
							-- Check to see if the step count has changed more than the set amount since the last timeout
							IF (ABS(stepCount - calibrate_stepCount_old) > calibrate_stepCount_driftMax) THEN
								
								-- If it has changed substatially, update the old value and reset the clock counter
								calibrate_stepCount_old := stepCount;
								calibrate_clockCounter := 0;

							ELSE
								-- If it has not changed substantially, it has reached its end stop and the next stage is reached
								calibrate_state := 2;

								-- Turn off the motor
								PWM_enable <= '0';

							END IF;

						END IF;

					WHEN 2 =>
						-- Set the stepcount to 0 now that the end position has been reached
						stepReset <= '1';

						-- Set the stepcount minimums to 0
						stepCount_min <= 0;

						-- Reset the calibrate variables to prepare for next step
						calibrate_stepCount_old := 0;
						calibrate_clockCounter := 0;

						-- Update the calibrate state
						calibrate_state := 3;

					WHEN 3 =>
						-- Start moving to maximum position	
						
						-- Stop resetting the stepCount, such that it can change again.
						stepReset <= '0';

						-- Set the motors to start rotating clockwise (positive stepCount)
						CW <= '1';
						PWM_enable <= '1';

						-- Check the stepCount variables on a timeout to see if it has changed since the last check
						-- Increase timer while timeout has not been reached yet
						IF (calibrate_clockCounter < calibrate_clockTimeout) THEN
							calibrate_clockCounter := calibrate_clockCounter + 1;

						ELSE
							-- Check to see if the step count has changed more than the set amount since the last timeout
							IF (ABS(stepCount - calibrate_stepCount_old) > calibrate_stepCount_driftMax) THEN
								
								-- If it has changed substatially, update the old value and reset the clock counter
								calibrate_stepCount_old := stepCount;
								calibrate_clockCounter := 0;

							ELSE
								-- If it has not changed substantially, it has reached its end stop and the next stage is reached
								calibrate_state := 4;

								-- Turn off the motors
								PWM_enable <= '0';

							END IF;

						END IF;

					WHEN 4 =>
						-- Set the stepcounts maximums to the current values
						stepCount_max <= stepCount;

						-- Update the calibrate state
						calibrate_state := 5;

					WHEN 5 =>
						-- Now move the motor until the half way point of the encoders has been reached

						-- Setup the motor to move counterclockwise (negative stepCount)
						CW <= '0';

						dutycycle <= calibrate_dutyCycleR;

						-- If the motor is not at its half way point yet
						IF (stepCount > stepCount_max / 2) THEN
							PWM_enable <= '1';
						ELSE
							-- Otherwise the calibration is finished
							PWM_enable <= '0';
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