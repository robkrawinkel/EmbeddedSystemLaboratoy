LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY PWM IS
	PORT (
	-- CLOCK and reset
	reset		: IN std_logic;
	CLOCK_50	: IN std_logic;

	-- Signals from the encoder
	period	: IN std_logic; --period in clockcycles
	periodOn	: IN std_logic; --dutycycle of the signal, 
	
	-- Output pwm_signal
	PWM_signal : OUT std_logic;
	
	-- Output error
	dutycycleError : OUT std_logic

	);
END ENTITY;

ARCHITECTURE bhv OF PWM IS
	
	-- Create signals to manage the timer
	SIGNAL runTimer	: std_logic;
	SIGNAL resetTimer	: std_logic;
	SIGNAL timerCount	: integer;
	SIGNAL maxTimer	: integer := 50000000;
	SIGNAL timerLimit	: std_logic;	

BEGIN
	
	-- Initialize timer and tie to local variables and signals

	-- Create a process which reacts to the specified signals
	PROCESS(reset, CLOCK_50)
	
		
		-- Define device constants
		--CONSTANT RadPerPulse : integer := 12566;	-- 2pi/pulsesPerRot*1000000, with 500 pulsesPerRot
		--CONSTANT maxRotSpeed : integer := 1;		-- Defined in clock pulses
		
		VARIABLE counter : integer;
		
	BEGIN
		
		-- Reset everything
		IF reset = '0' THEN
		
			counter := 0;
			
			PWM_signal <= '0';
			dutycycleError <= '0';
			
		ELSIF rising_edge(CLOCK_50) THEN
			counter := counter + 1;
			IF counter = periodOn THEN
				PWM_signal <= '0';
			ELSIF counter = period THEN
				PWM_signal <= '1'
				counter := 0;
			END
			
		END IF;
		
	END PROCESS;
	

END bhv;