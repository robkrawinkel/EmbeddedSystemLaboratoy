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
	
	-- Output velocity in 32 bits
	velocity	: OUT integer;
	
	-- Output step counter in 32 bits signed
	stepCount : INOUT integer;
	
	-- Output error
	overSpeedError : OUT std_logic

	);
END ENTITY;

ARCHITECTURE bhv OF QuadratureEncoder IS
	
	-- Create signals to manage the timer
	SIGNAL runTimer	: std_logic;
	SIGNAL resetTimer	: std_logic;
	SIGNAL timerCount	: integer;
	SIGNAL maxTimer	: integer := 50000000;
	SIGNAL timerLimit	: std_logic;	

BEGIN
	
	-- Initialize timer and tie to local variables and signals
	timer : ENTITY work.timer
		PORT MAP (
			reset		=> resetTimer,
			CLOCK 	=> CLOCK_50,
			runTimer => runTimer,
			maxTimer => maxTimer,
			result 	=> timerCount,
			timerLimit => timerLimit
		);

	-- Create a process which reacts to the specified signals
	PROCESS(reset, CLOCK_50, signalA, signalB, timerLimit)
	
		-- Create variable to keep track of direction, ClockWise
		VARIABLE CW	: std_logic;
		
		-- Variables to keep track of previous states
		VARIABLE oldStateA : std_logic;
		VARIABLE oldStateB : std_logic;
		
		-- Define device constants
		CONSTANT RadPerPulse : integer := 12566;	-- 2pi/pulsesPerRot*1000000, with 500 pulsesPerRot
		CONSTANT maxRotSpeed : integer := 1;		-- Defined in clock pulses
		
	BEGIN
		
		-- Reset everything
		IF reset = '1' THEN
			velocity <= 0;
			runTimer <= '0';
			resetTimer <= '0';
			overSpeedError <= '0';
			stepCount <= 0;
			
		-- If A is detected
		ELSIF rising_edge(CLOCK_50) THEN
			
			IF (signalA /= oldStateA AND signalA = '1') THEN
				IF resetTimer = '0' THEN	-- If the timer is not running yet
					resetTimer <= '1';			-- Release the timer from reset
					runTimer <= '1';				-- Start counting
					CW := '1';						-- Note that the rotation is CW
					
				ELSIF CW = '0'	THEN			-- If the timer is running and rotation is CCW
					runTimer <= '0';					-- Stop the timer
					stepCount <= stepCount - 1;	-- Decrement step counter
					
					IF timerCount > maxRotSpeed THEN		-- If not too fast
						velocity <= -50000000/timerCount*RadPerPulse;		-- in micro Rad / s
						overSpeedError <= '0';
						
					ELSE 											-- If too fast
						-- Don't alter velocity
						overSpeedError <= '1';
						
					END IF;
					
				END IF;
				
			
		
			-- If B is detected
			ELSIF (signalB /= oldStateB AND signalB = '1') THEN
			
				IF resetTimer = '0' THEN	-- If the timer is not running yet
					resetTimer <= '1';			-- Release the timer from reset
					runTimer <= '1';			-- Start counting
					CW := '0';					-- Note that the rotation is CW
					
				ELSIF CW = '1' THEN				-- If the timer is running and rotation is CCW
					runTimer <= '0';					-- Stop the timer
					stepCount <= stepCount + 1;	-- Increment step coun
					
					IF timerCount > maxRotSpeed THEN		-- If not too fast
						velocity <= 50000000/timerCount*RadPerPulse;		-- in micro Rad / s
						overSpeedError <= '0';
						
					ELSE 											-- If too fast
						-- Don't alter velocity
						overSpeedError <= '1';
						
					END IF;
					
				END IF;
			
			
		
			-- Reset loop
			ELSIF ((signalA /= oldStateA AND signalA = '0') OR (signalB /= oldStateB AND signalB = '0')) THEN
				resetTimer <= '0';
				runTimer <= '0';
			
			
			-- Timer overflow
			ELSIF timerLimit = '1' THEN
				velocity <= 0;
				resetTimer <= '0';
				runTimer <= '0';
				
			END IF;
			
			oldStateA := signalA;
			oldStateB := signalB;
			
		END IF;
		
	END PROCESS;
	

END bhv;