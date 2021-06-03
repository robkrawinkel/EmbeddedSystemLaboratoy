LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Communication IS
	GENERIC (
		DATA_WIDTH 	: natural := 32;	-- word size OF each INput and OUTput regISter
		MAX_PWM		: natural := 100;	-- maximum speed for the motors
	);
	PORT (
	-- CLOCK and reset
	reset		: IN std_logic;
	CLOCK_50	: IN std_logic;
	

	-- Signals to connect to an Avalon-MM slave INterface
	slave_address		: IN  std_logic_vector(7 downto 0);
	slave_read			: IN  std_logic;
	slave_write			: IN  std_logic;
	slave_readdata		: OUT std_logic_vector(DATA_WIDTH-1 downto 0);
	slave_writedata		: IN  std_logic_vector(DATA_WIDTH-1 downto 0);
	slave_byteenable	: IN  std_logic_vector((DATA_WIDTH/8)-1 downto 0);

	-- Output signals for the PWM signal of PWM blocks
	frequency	: OUT integer range 0 to 50000000; 	--frequency of the signal in Hz
	dutycycle1	: OUT integer range 0 to 100; 		--dutycycle of the signal in percentage
	CW1			: OUT std_logic; 					--rotational direction of the signal
	enable1     : OUT std_logic;					--enable for the PMW module
	dutycycle2	: OUT integer range 0 to 100; 		--dutycycle of the signal in percentage
	CW2			: OUT std_logic; 					--rotational direction of the signal
	enable2     : OUT std_logic;					--enable for the PMW module
	
	-- Input signals from the encoder
	stepCount1 	: IN integer;					--stepcount of the motor
	stepCount2	: IN integer

	);
END ENTITY;

ARCHITECTURE bhv OF Communication IS
	

	-- Internal memory for the system
	SIGNAL memREAD     		: std_logic_vector(31 downto 0);
	SIGNAL memSEND    		: std_logic_vector(31 downto 0);

BEGIN
	

	-- Create a process which reacts to the specified signals
	PROCESS(reset, CLOCK_50)
		
		-- Variables that store the amount of clock cycles to count based on the set frequency and dutycycle
		VARIABLE PWM_1 : integer range -128 to 128;
		VARIABLE PWM_2 : integer range -128 to 128;
		
	BEGIN
		
		-- Reset everything
		IF reset = '1' THEN
		
			enable1 <= '0';
			enable2 <= '0';
			memSend <= (others => '0');
			memREAD <= (others => '0');
			
			
		ELSIF rising_edge(CLOCK_50) THEN
			memSEND <= std_logic_vector(to_signed(stepcount0,11)) & std_logic_vector(to_signed(stepCount1,11)) & std_logic_vector(to_signed(0,32-11-11));
			--sending data
			IF (slave_read = '1') THEN
				slave_readdata <= memSEND;
			END IF;
			
			--reading data
			IF (slave_write = '1') THEN
				memRead <= slave_writedata;
				
				--Control the PWM signals depending on the input signal
				PWM_1 := to_integer(signed(memRead(31 downto 24)));
				PWM_2 := to_integer(signed(memRead(23 downto 16)));
				
				--If there is no control, so the PWM module should not be enabled
				IF (PWM_1 == 0) THEN
					enable1 <= '0';
					
				--If the Input signal is negative, so it should turn counter clockwise. Also inverts the PWM input signal so it is positive
				ELSIF (PWM_1 < 0) THEN
					enable1 <= '1';
					CW1 <= '0';
					--protection
					IF (PWM_1 < -MAX_PWM) THEN
						PWM_1 := -MAX_PWM;
					END IF;
					dutycycle1 <= -PWM_1;
				ELSE
					enable1 <= '1';
					CW1 <= '1';
					--protection
					IF (PWM_1 > MAX_PWM) THEN
						PWM_1 := MAX_PWM;
					END IF;
					dutycycle1 <= PWM_1;
				END IF;
				
				
				--If there is no control, so the PWM module should not be enabled
				IF (PWM_2 == 0) THEN
					enable1 <= '0';
					
				--If the Input signal is negative, so it should turn counter clockwise. Also inverts the PWM input signal so it is positive
				ELSIF (PWM_2 < 0) THEN
					enable2 <= '1';
					CW2 <= '0';
					--protection
					IF (PWM_2 < -MAX_PWM) THEN
						PWM_2 := -MAX_PWM;
					END IF;
					dutycycle2 <= -PWM_2;
				ELSE
					enable2 <= '1';
					CW2 <= '1';
					--protection
					IF (PWM_2 > MAX_PWM) THEN
						PWM_2 := MAX_PWM;
					END IF;
					dutycycle2 <= PWM_2;
				END IF;
				
				
			END IF;
		END IF;
		
	END PROCESS;
	

END bhv;
