LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY PWM IS
	PORT (
	-- CLOCK and reset
	reset		: IN std_logic;
	CLOCK_50	: IN std_logic;

	-- Input signals module
	frequency	: IN integer range 0 to 50000000; 	--frequency of the signal in Hz
	dutycycle	: IN integer range 0 to 100; 		--dutycycle of the signal in percentage
	CW			: IN std_logic; 					--rotational direction of the signal

	-- Output pwm_signal and rotation direction
	PWM_signal 	: OUT std_logic;
	INA 		: OUT std_logic;
	INB			: OUT std_logic;
	
	-- Enable for the PMW module
	enable      	: IN std_logic

	);
END ENTITY;

ARCHITECTURE bhv OF PWM IS
	
	-- Counter for the amount of clock cycles
	SIGNAL counter : integer range 0 to 50000000;

BEGIN
	

	-- Create a process which reacts to the specified signals
	PROCESS(reset, CLOCK_50)
		
		-- Variables that store the amount of clock cycles to count based on the set frequency and dutycycle
		VARIABLE cycles_per_period : integer range 0 to 50000000;
		VARIABLE on_cycles_per_period : integer range 0 to 50000000;
		
	BEGIN
		
		-- Reset everything
		IF reset = '1' THEN
		
			counter <= 0;
			
			PWM_signal <= '0';
			INA <= '0';
			INB <= '0';
			
		ELSIF rising_edge(CLOCK_50) THEN

			-- calculate the relevant variables at the start of each PWM cycle
			cycles_per_period := 50000000/frequency;
			on_cycles_per_period := ((50000000/frequency) * dutycycle) / 100;

			--set the rotational direction based on the CW input
			IF enable = '1' THEN

				-- Set the directional outputs
				INA <= CW;
			    INB <= NOT CW;
            
                --change the PWM signal depending on the counter
				IF counter = 0 THEN
					PWM_signal <= '1';
					counter <= counter + 1;

				ELSIF counter = on_cycles_per_period-1 THEN
					PWM_signal <= '0';
					counter <= counter + 1;

				ELSIF counter = cycles_per_period-1 THEN
					PWM_signal <= '1';
					counter <= 0;
				ELSE
					counter <= counter + 1;
				END IF;

			ELSE -- If the PWM module is not enabled
				INA <= '0';
				INB <= '0';
				PWM_signal <= '0';
				counter <= 0;
			END IF;
			
		END IF;
		
	END PROCESS;
	

END bhv;
