LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ESL_NIOS_II_IP IS
	GENERIC (
		DATA_WIDTH : natural := 32;	-- word size OF each INput and OUTput regISter
		LED_WIDTH  : natural := 8	-- numbers OF LEDs on the DE0-NANO
	);
	PORT (
		-- Signals to connect to an Avalon clock source INterface
		clk				: IN  std_logic;
		reset			: IN  std_logic;

		-- Signals to connect to an Avalon-MM slave INterface
		slave_address		: IN  std_logic_vector(7 downto 0);
		slave_read			: IN  std_logic;
		slave_write			: IN  std_logic;
		slave_readdata		: OUT std_logic_vector(DATA_WIDTH-1 downto 0);
		slave_writedata		: IN  std_logic_vector(DATA_WIDTH-1 downto 0);
		slave_byteenable	: IN  std_logic_vector((DATA_WIDTH/8)-1 downto 0);

		-- Signals to connect to custom user logic
		LED				: OUT std_logic_vector(LED_WIDTH-1 downto 0);
		GPIO_0			: INOUT std_logic_vector(33 downto 0);
		--GPIO_1			: INOUT std_logic_vector(33 downto 0);
		KEY				: IN std_logic_vector(1 downto 0);
		SW				: IN std_logic_vector(3 downto 0)
		--GPIO_1[0]		: INOUT std_logic;
		--GPIO_1[1]		: INOUT std_logic
	);
END ENTITY;

ARCHITECTURE behavior OF ESL_NIOS_II_IP IS

------------------------------------------------------------------------------ ARCHITECTURE - Avalon bus ------------------------------------------------------------------------------

	-- Internal memory for the system and a subset for the IP
	SIGNAL mem        		: std_logic_vector(31 downto 0);
	SIGNAL memSEND    		: std_logic_vector(31 downto 0);


------------------------------------------------------------------------------ ARCHITECTURE - Quadrature encoder ------------------------------------------------------------------------------


	-- Signals for quadrature encoder
	SIGNAL stepCount0 		: integer;
	SIGNAL stepCount1 		: integer;

	signal stepReset		: std_logic;

	-- Define the quadrature encoder module
	COMPONENT QuadratureEncoder		
		PORT (
			-- CLOCK and reset
			reset		: IN std_logic;
			CLOCK_50	: IN std_logic;

			-- SIGNALs from the encoder
			SIGNALA	: IN std_logic;
			SIGNALB	: IN std_logic;

			-- OUTput step counter IN 32 bits signed
			stepCount : INOUT integer;

			--Reset stepcount to 0
			stepReset : IN std_logic
			);
	END COMPONENT;



------------------------------------------------------------------------------ ARCHITECTURE - PWM module ------------------------------------------------------------------------------


	-- Signals for the PWM generation
	SIGNAL PWM_frequency 	: integer range 0 to 50000000;
	SIGNAL PWM_dutycycle0	: integer range 0 to 100;
	SIGNAL PWM_dutycycle1	: integer range 0 to 100;
	SIGNAL PWM_CW0	 		: std_logic;
	SIGNAL PWM_CW1	 		: std_logic;
	SIGNAL PWM_enable0		: std_logic;
	SIGNAL PWM_enable1		: std_logic;

	-- Define the PWM module
	COMPONENT PWM
		PORT (
			-- CLOCK and reset
			reset		: IN std_logic;
			CLOCK_50	: IN std_logic;

			-- Input SIGNALs module
			frequency	: IN integer range 0 to 50000000; 	--frequency OF the SIGNAL IN Hz
			dutycycle	: IN integer range 0 to 100; 		--dutycycle OF the SIGNAL IN percentage
			CW			: IN std_logic; 					--rotational direction OF the SIGNAL

			-- Output pwm_SIGNAL and rotation direction
			PWM_SIGNAL 	: OUT std_logic;
			INA 		: OUT std_logic;
			INB			: OUT std_logic;

			enable		: IN std_logic
			);
	END COMPONENT;

------------------------------------------------------------------------------ ARCHITECTURE - Calibrate ------------------------------------------------------------------------------

	-- Calibration happens in 3 states for both motors
	-- 	0:	Reset stepcounters to 0
	--	1:	Rotate motors with fixed dutycycle in the negative direction until step count has not changed significantly (more than 10) for 100ms
	--	2: 	Reset stepcounters to 0
	--	3: 	Rotate to half the max step count (predefined per motor)

	CONSTANT stepCount0_max : integer := 1115;
	CONSTANT stepCount1_max : integer := 221;
	CONSTANT calibrate_clockTimeout : integer := 5000000;	-- 5.000.000 clock pulses for 100ms
	CONSTANT calibrate_stepCount_driftMax : integer := 10;

	SIGNAL calibrate_enable	: std_logic;
------------------------------------------------------------------------------ ARCHITECTURE - Communication ------------------------------------------------------------------------------
	SIGNAL COMM_dutycycle0 	: integer range 0 to 100;
	SIGNAL COMM_dutycycle1 	: integer range 0 to 100;
	SIGNAL COMM_CW0			: std_logic;
	SIGNAL COMM_CW1			: std_logic;
	SIGNAL COMM_enable0		: std_logic;
	SIGNAL COMM_enable1		: std_logic;
	SIGNAL COMM_doRecalibrate: std_logic;
	SIGNAL COMM_max0 : integer := 0;
	SIGNAL COMM_max1 : integer := 0;
	
	
	COMPONENT Communication
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
			dutycycle0	: OUT integer range 0 to 100; 		--dutycycle of the signal in percentage
			CW0			: OUT std_logic; 					--rotational direction of the signal
			enable0     : OUT std_logic;					--enable for the PMW module
			dutycycle1	: OUT integer range 0 to 100; 		--dutycycle of the signal in percentage
			CW1			: OUT std_logic; 					--rotational direction of the signal
			enable1     : OUT std_logic;					--enable for the PMW module
			
			-- Input signals from the encoder
			stepCount0 	: IN integer;					--stepcount of the motor
			stepCount1	: IN integer;
			
				-- Maximum stepcount values
	stepCount0Max : IN integer;					-- Maximum value the stepcount can reach.
	stepCount1Max : IN integer;
	
	--flag to recalibrate
	doRecalibrate : OUT std_logic


			);
	END COMPONENT;
	
	
------------------------------------------------------------------------------ ARCHITECTURE - begin ------------------------------------------------------------------------------


BEGIN
	
	-- Initialize encoder 0
	encoder0 : QuadratureEncoder
		PORT MAP (
			-- CLOCK and reset
			reset		=> reset,
			CLOCK_50	=> clk,

			-- SIGNALs from the encoder
			SIGNALA	=> GPIO_0(20),
			SIGNALB	=> GPIO_0(22),
			
			-- OUTput step count
			stepCount => stepCount0,

			--Reset stepcount to 0
			stepReset => stepReset
		);

	-- Initialize encoder 1
	encoder1: QuadratureEncoder
		PORT MAP (
			-- CLOCK and reset
			reset		=> reset,
			CLOCK_50	=> clk,

			-- SIGNALs from the encoder
			SIGNALA	=> GPIO_0(21),
			SIGNALB	=> GPIO_0(23),

			-- OUTput step count
			stepCount => stepCount1,

			--Reset stepcount to 0
			stepReset => stepReset
		);

	-- Initialize PWM generator 0
	PWM0: PWM
		PORT MAP (
			-- CLOCK and reset
			reset		=> reset,
			CLOCK_50	=> clk,
			-- INput SIGNALs module
			frequency	=> PWM_frequency,
			dutycycle	=> PWM_dutycycle0,
			CW			=> PWM_CW0,
			-- OUTput pwm_SIGNAL and rotation direction
			PWM_SIGNAL 	=> GPIO_0(8),
			INA 		=> GPIO_0(10),
			INB			=> GPIO_0(12),
			
			enable		=> PWM_enable0
			);
	
	-- Initialize PWM generator 1
	PWM1: PWM
		PORT MAP (
			-- CLOCK and reset
			reset		=> reset,
			CLOCK_50	=> clk,
			-- INput SIGNALs module
			frequency	=> PWM_frequency,
			dutycycle	=> PWM_dutycycle1,
			CW			=> PWM_CW1,
			-- OUTput pwm_SIGNAL and rotation direction
			PWM_SIGNAL 	=> GPIO_0(9),
			INA 		=> GPIO_0(11),
			INB			=> GPIO_0(13),
			
			enable		=> PWM_enable1
			);
		
	-- Initialize Communication IP
	CommunicationIP: Communication
			PORT MAP(
			-- CLOCK and reset
			reset		=> reset,
			CLOCK_50	=> clk,
			
			-- Signals to connect to an Avalon-MM slave INterface
			slave_address	=> slave_address,	
			slave_read		=> slave_read,
			slave_write		=> slave_write,
			slave_readdata	=> slave_readdata,
			slave_writedata	=> slave_writedata,
			slave_byteenable=> slave_byteenable,

			-- Output signals for the PWM signal of PWM blocks
			dutycycle0	=> COMM_dutycycle0,
			CW0			=> COMM_CW0,
			enable0     => COMM_enable0,
			dutycycle1	=> COMM_dutycycle1,
			CW1			=> COMM_CW1,
			enable1     => COMM_enable1,
			
			-- Input signals from the encoder
			stepCount0 	=> stepCount0,
			stepCount1	=> stepCount1,
			
				-- Maximum stepcount values
			stepCount0Max => COMM_max0,					-- Maximum value the stepcount can reach.
			stepCount1Max => COMM_max1,
	
			--flag to recalibrate
			doRecalibrate => COMM_doRecalibrate

			);
	
	-- Output to the leds a 1 and the step count of encoder 0 in 7 bits signed
	LED <= '1' & std_logic_vector(to_signed(stepCount1, 7));
	

	-- Process to handle PWM generation
	PWM_process : PROCESS(clk,reset)
		VARIABLE calibrate_state : integer RANGE 0 TO 4;
		VARIABLE calibrate_stepCount0_old : integer;
		VARIABLE calibrate_stepCount1_old : integer;
		VARIABLE calibrate_clockCounter : integer;
	BEGIN
		IF (reset = '1') THEN
			PWM_enable0 <= '0';
			PWM_enable1 <= '0';
			PWM_dutycycle0 <= 0;
			PWM_dutycycle1 <= 0;
			PWM_CW0 <= '0';
			PWM_CW1 <= '0';
			PWM_frequency  <= 20000;

			calibrate_enable <= '1';
			calibrate_state := 0;
			stepReset <= '1';

		ELSIF rising_edge(clk) THEN
			IF (calibrate_enable = '1') THEN
				CASE calibrate_state IS
					WHEN 0 =>										
						-- Reset all calibrate variables to start calibration

						calibrate_stepCount0_old := 0;
						calibrate_stepCount1_old := 0;

						calibrate_clockCounter := 0;

						calibrate_state := 1;

					WHEN 1 =>
						-- Start moving to maximum position
						-- Start both motors with a fixed dutycycle		
						
						stepReset <= '0';

						PWM_dutycycle0 <= 20;
						PWM_dutycycle1 <= 20;

						PWM_CW0 <= '0';
						PWM_CW1 <= '0';

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
								

							END IF;

						END IF;

					WHEN 2 =>
						-- Set the stepcounts to 0 now that the end position has been reached
						stepReset <= '1';

						calibrate_state := 3;

					WHEN 3 =>
						-- Now move the motors until the half way point of the encoders has been reached
						stepReset <= '0';

						PWM_dutycycle0 <= 20;
						PWM_dutycycle1 <= 20;

						PWM_CW0 <= '1';
						PWM_CW1 <= '1';

						-- If motor 0 is not at its half way point yet
						IF (stepCount0 < stepCount0_max / 2) THEN
							PWM_enable0 <= '1';
						ELSE
							PWM_enable0 <= '0';
						END IF;

						-- If motor 1 is not at its half way point yet
						IF (stepCount1 < stepCount1_max / 2) THEN
							PWM_enable1 <= '1';
						ELSE
							PWM_enable1 <= '0';
						END IF;

						-- If both are at their half way point (the motors have been disabled), calibration is complete
						IF (PWM_enable0 = '0' AND PWM_enable1 = '0') THEN
							calibrate_enable <= '0';
						END IF;
					WHEN OTHERS =>

				END CASE;
			ELSE
				stepReset <= '0';

				-- communication control
				PWM_dutycycle0 	<= COMM_dutycycle0;
				PWM_dutycycle1 	<= COMM_dutycycle1;
				PWM_CW0 		<= COMM_CW0;
				PWM_CW1			<= COMM_CW1;
				PWM_enable0		<= COMM_enable0;
				PWM_enable1		<= COMM_enable1;
			END IF;


			-- PWM_frequency <= 20000;
			-- PWM_dutycycle1 <= 50;
			-- PWM_dutycycle0 <= 10;

			-- -- If key0 is pressed rotate both motors counter clockwise
			-- IF KEY(0) = '0' THEN
			-- 	PWM_CW0 <= '0';
			-- 	PWM_CW1 <= '0';
			-- 	PWM_enable0 <= '1';
			-- 	PWM_enable1 <= '1';

			-- -- If key1 is pressed rotate both motors clockwise
			-- ELSIF KEY(1) = '0' THEN
			-- 	PWM_CW0 <= '1';
			-- 	PWM_CW1 <= '1';
			-- 	PWM_enable0 <= '1';
			-- 	PWM_enable1 <= '1';

			-- -- If none of the buttons are pressed stop the PWM generation
			-- ELSE
			-- 	PWM_enable0 <= '0';
			-- 	PWM_enable1 <= '0';

			-- END IF;
		END IF;
	END PROCESS;

	
	---- Communication with the bus process
	--p_avalon : PROCESS(clk, reset)
	--BEGIN
	--	IF (reset = '1') THEN
	--		mem <= (others => '0');
	--		memSEND <= (others => '0');
	--	ELSIF (rising_edge(clk)) THEN
    --
	--		-- Send the step counter data in 16 bit signed, concatenated to get 32 bits
	--		memSEND <= std_logic_vector(to_signed(stepcount0,16)) & std_logic_vector(to_signed(stepCount1,16));
	--		
	--		IF (slave_read = '1') THEN
	--			slave_readdata <= memSEND;
	--		END IF;
	--		
	--		IF (slave_write = '1') THEN
	--			mem <= slave_writedata;
	--		END IF;
	--	END IF;
	--END PROCESS;
	
END ARCHITECTURE;

