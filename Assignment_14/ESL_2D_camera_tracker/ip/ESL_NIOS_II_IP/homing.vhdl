-- Homing is very simple
	-- 	0:	Rotate motor clockwise until an edge is reached
	-- 	1:	Rotate motor counterclockwise until and edge is reached

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY homing IS
	PORT (
		-- CLOCK and reset
		reset				: IN std_logic;
		CLOCK_50			: IN std_logic;

		-- Enable homing
		homing_enable		: IN std_logic;

		-- Motor control
		dutycycle			: OUT integer RANGE 0 TO 100;
		CW					: OUT std_logic;
		PWM_enable			: INOUT std_logic;
		homing_dutyCycle	: IN integer RANGE 0 TO 100;

		-- Stepcount input
		stepCount			: IN integer RANGE -8192 TO 8191;
		stepCount_min		: IN integer RANGE -8192 TO 0;
		stepCount_max		: IN integer RANGE 0 TO 8191

	);
END ENTITY;

ARCHITECTURE bhv OF homing IS
	
	CONSTANT homing_stepCount_driftMax 	: integer := 3;			-- The maximum amount of steps a stepCount may drift at the end position

BEGIN

	-- Create a process which reacts to the specified signals
	PROCESS(reset, CLOCK_50)

		VARIABLE currentCW : std_logic := '1';

	BEGIN
		
		-- Reset everything
		IF reset = '1' THEN
			
			currentCW := '1';
			
		ELSIF rising_edge(CLOCK_50) THEN

			IF homing_enable = '1' THEN
				-- Setup the motor
				dutycycle <= homing_dutyCycle;
				PWM_enable <= '1';
				CW <= currentCW;

				-- Change direction at the edges
				IF (stepCount <= stepCount_min + homing_stepCount_driftMax) THEN
					currentCW := '1';
				ELSIF (stepCount >= stepCount_max - homing_stepCount_driftMax) THEN
					currentCW := '0';
				END IF;

			ELSE
				-- Turn off motor
				PWM_enable <= '0';
			END IF;

		END IF;
		
	END PROCESS;
	

END bhv;