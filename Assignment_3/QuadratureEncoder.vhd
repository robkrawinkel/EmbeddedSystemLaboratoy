LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY QuadratureEncoder IS
	PORT (
	-- CLOCK and reset
	reset		: IN std_logic;
	CLOCK_50	: IN std_logic;

	-- Signals from the encoder
	signalA	: IN std_logic;
	signalB	: IN std_logic;
	
	-- Output velocity in 16 bits
	velocity	: OUT std_logic_vector(15 DOWNTO 0);

	);
END ENTITY;

ARCHITECTURE bhv OF QuadratureEncoder IS

	-- Create a timer object from the timer entity
	COMPONENT timer IS
		PORT (reset		: IN std_logic;
				CLOCK 	: IN std_logic;
				runTimer : IN std_logic;
				result 	: INOUT integer
				);
	END COMPONENT timer;
	
	-- Create variables to manage the timer
	VARIABLE runTimer		: std_logic;
	VARIABLE resetTimer	: std_logic;
	VARIABLE timerCount	: integer;
	
	-- Create variable to keep track of direction
	VARIABLE CW	: std_logic;

BEGIN

	-- Start the timer tied to the created variables
	timer	: timer	PORT MAP (resetTimer, CLOCK_50, runTimer, timerCount);

	-- Create a process which reacts to the specified signals
	PROCESS(reset, CLOCK_50, signalA, signalB)
	
		CONSTANT RadPerPulse : integer := 12566;	-- 2pi/pulsesPerRot*1000000, with 500 pulsesPerRot
		CONSTANT minRotSpeed : integer := 0;		-- Defined in clock pulses
		CONSTANT maxRotSpeed : integer := 1000;	-- Defined in clock pulses
		
	BEGIN
		
		-- Reset everything
		IF reset = '0' THEN
			velocity <= 0;
			runTimer := '0';
			resetTimer := '0';
			
		ELSIF rising_edge(signalA) THEN
			IF resetTimer == '0' THEN	-- If the timer is not running yet
				resetTimer == '1';		-- Release the timer from reset
				runTimer == '1';			-- Start counting
				CW == '1';					-- Note that the rotation is CW
				
			ELSIF CW == '0'				-- If the timer is running and rotation is CCW
				runTimer == '0';			-- Stop the timer
				IF (timerCount > minRotSpeed and timerCount < maxRotSpeed)
					velocity <= (RadPerPulse/1000000)/(timerCount/50000000);
				
			END IF;
		
		ELSIF rising_edge(signalB) THEN
		
		ELSIF falling_edge(signalA) THEN
			runTimer := '0';
			resetTimer := '0';
			velocity <= 0;
		
		ELSIF falling_edge(signalB) THEN
			runTimer := '0';
			resetTimer := '0';
			velocity <= 0;
				
		END IF;
		
	END PROCESS;
	

END bhv;