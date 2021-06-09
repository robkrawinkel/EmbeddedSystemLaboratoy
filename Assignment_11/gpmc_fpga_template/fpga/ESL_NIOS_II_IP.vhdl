LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ESL_NIOS_II_IP IS
	GENERIC (
		DATA_WIDTH : natural := 32;	-- word size OF each INput and OUTput regISter
		LED_WIDTH  : natural := 8;	-- numbers OF LEDs on the DE0-NANO
		GPMC_ADDR_WIDTH_HIGH : integer := 10;
		GPMC_ADDR_WIDTH_LOW  : integer := 1;
		RAM_SIZE             : integer := 32
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

		-- GPMC side
		GPMC_DATA     : inout std_logic_vector(16 - 1 downto 0);
		GPMC_ADDR     : in    std_logic_vector(GPMC_ADDR_WIDTH_HIGH downto GPMC_ADDR_WIDTH_LOW);
		GPMC_nPWE     : in    std_logic;
		GPMC_nOE      : in    std_logic;
		GPMC_FPGA_IRQ : in    std_logic;
		GPMC_nCS6     : in    std_logic;
		GPMC_CLK      : in    std_logic;
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
	SIGNAL stepCount0_min	: integer RANGE -8192 TO 0;
	SIGNAL stepCount0_max	: integer RANGE 0 TO 8191;
	SIGNAL stepCount1_min	: integer RANGE -8192 TO 0;
	SIGNAL stepCount1_max	: integer RANGE 0 TO 8191;
	signal stepCount0 : integer RANGE -8192 TO 8191;
	signal stepCount1 : integer RANGE -8192 TO 8191;

	SIGNAL stepReset		: std_logic;

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
			stepCount : OUT integer RANGE -8192 TO 8191;

			-- Input stepCount min and max value
			stepCount_min	: IN integer RANGE -8192 TO 0;
			stepCount_max	: IN integer RANGE 0 TO 8191;

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

			-- Output pwm_SIGNAL and rotationstepCount1_max direction
			PWM_SIGNAL 	: OUT std_logic;
			INA 		: OUT std_logic;
			INB			: OUT std_logic;

			enable		: IN std_logic
			);
	END COMPONENT;

------------------------------------------------------------------------------ ARCHITECTURE - Calibrate ------------------------------------------------------------------------------

	SIGNAL CALL_calibrate_enable	: std_logic;
	SIGNAL CALL_calibrate_running	: std_logic;
	SIGNAL CALL_dutycycle0			: integer RANGE 0 TO 100;
	SIGNAL CALL_dutycycle1			: integer RANGE 0 TO 100;
	SIGNAL CALL_CW0					: std_logic;
	SIGNAL CALL_CW1					: std_logic;
	SIGNAL CALL_enable0				: std_logic;
	SIGNAL CALL_enable1				: std_logic;
	SIGNAL CALL_stepReset			: std_logic;

	-- Define calibrate component
	COMPONENT calibrate
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
			PWM_enable0			: OUT std_logic;
			PWM_enable1			: OUT std_logic;

			-- Stepcount control
			stepCount0			: IN integer RANGE -8192 TO 8191;
			stepCount0_min		: OUT integer RANGE -8192 TO 0;
			stepCount0_max		: OUT integer RANGE 0 TO 8191;
			stepCount1			: IN integer RANGE -8192 TO 8191;
			stepCount1_min		: OUT integer RANGE -8192 TO 0;
			stepCount1_max		: OUT integer RANGE 0 TO 8191;
			stepReset			: OUT std_logic

		);
	END COMPONENT;

------------------------------------------------------------------------------ ARCHITECTURE - Communication ------------------------------------------------------------------------------
	SIGNAL COMM_dutycycle0 	: integer range 0 to 100;
	SIGNAL COMM_dutycycle1 	: integer range 0 to 100;
	SIGNAL COMM_CW0			: std_logic;
	SIGNAL COMM_CW1			: std_logic;
	SIGNAL COMM_enable0		: std_logic;
	SIGNAL COMM_enable1		: std_logic;
	SIGNAL COMM_recalibrate : std_logic;
	
	COMPONENT Communication
		PORT (
			-- CLOCK and reset
			reset		: IN std_logic;
			CLOCK_50	: IN std_logic;
			

			-- GPMC side
			GPMC_DATA     : inout std_logic_vector(16 - 1 downto 0);
			GPMC_ADDR     : in    std_logic_vector(GPMC_ADDR_WIDTH_HIGH downto GPMC_ADDR_WIDTH_LOW);
			GPMC_nPWE     : in    std_logic;
			GPMC_nOE      : in    std_logic;
			GPMC_FPGA_IRQ : in    std_logic;
			GPMC_nCS6     : in    std_logic;
			GPMC_CLK      : in    std_logic;

			-- Output signals for the PWM signal of PWM blocks
			dutycycle0			: OUT integer range 0 to 100; 		--dutycycle of the signal in percentage
			CW0					: OUT std_logic; 					--rotational direction of the signal
			enable0     		: OUT std_logic;					--enable for the PMW module
			dutycycle1			: OUT integer range 0 to 100; 		--dutycycle of the signal in percentage
			CW1					: OUT std_logic; 					--rotational direction of the signal
			enable1     		: OUT std_logic;					--enable for the PMW module
			
			-- Input signals from the encoder
			stepCount0 			: IN integer;					--stepcount of the motor
			stepCount1			: IN integer;
			
			-- Maximum stepcount values
			stepCount0Max 		: IN integer;					-- Maximum value the stepcount can reach.
			stepCount1Max 		: IN integer;
			
			--flag to recalibrate
			doRecalibrate 		: OUT std_logic;
			calibrate_running	: IN std_logic

			);
	END COMPONENT;
	
	
------------------------------------------------------------------------------ ARCHITECTURE - begin ------------------------------------------------------------------------------


BEGIN
	
	-- Initialize encoder 0
	encoder0: QuadratureEncoder
		PORT MAP (
			-- CLOCK and reset
			reset		=> reset,
			CLOCK_50	=> clk,

			-- Signals from the encoder
			SIGNALA	=> GPIO_0(20),
			SIGNALB	=> GPIO_0(22),
			
			-- Output step count
			stepCount => stepCount0,

			stepCount_min => stepCount0_min,
			stepCount_max => stepCount0_max,

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

			stepCount_min => stepCount1_min,
			stepCount_max => stepCount1_max,

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
			
			GPMC_DATA     => GPMC_DATA,
			GPMC_ADDR     => GPMC_ADDR,
			GPMC_nPWE     => GPMC_nPWE,
			GPMC_nOE      => GPMC_nOE,
			GPMC_FPGA_IRQ => GPMC_FPGA_IRQ,
			GPMC_nCS6     => GPMC_nCS6,
			GPMC_CLK      => GPMC_CLK,

			-- Output signals for the PWM signal of PWM blocks
			dutycycle0	=> COMM_dutycycle0,
			CW0			=> COMM_CW0,
			enable0     => COMM_enable0,
			stepCount0 	=> stepCount0,
			stepCount1	=> stepCount1,
			
				-- Maximum stepcount values
			stepCount0Max => stepCount0_max,					-- Maximum value the stepcount can reach.
			stepCount1Max => stepCount1_max,
	
			--flag to recalibrate
			doRecalibrate => COMM_recalibrate,
			calibrate_running => CALL_calibrate_running

		);
	

	CalibrateIP: calibrate
		PORT MAP(
			-- CLOCK and reset
			reset				=> reset,
			CLOCK_50			=> clk,

			-- Enable calibration
			calibrate_enable	=> CALL_calibrate_enable,
			calibrate_running	=> CALL_calibrate_running,

			-- Motor control
			dutycycle0			=> CALL_dutycycle0,
			dutycycle1			=> CALL_dutycycle1,
			CW0					=> CALL_CW0,
			CW1					=> CALL_CW1,
			PWM_enable0			=> CALL_enable0,
			PWM_enable1			=> CALL_enable1,

			-- Stepcount control
			stepCount0			=> stepCount0,
			stepCount0_min		=> stepCount0_min,
			stepCount0_max		=> stepCount0_max,
			stepCount1			=> stepCount1,
			stepCount1_min		=> stepCount1_min,
			stepCount1_max		=> stepCount1_max,
			stepReset			=> CALL_stepReset

		);	
	
	-- Output to the leds a 1 and the step count of encoder 0 in 7 bits signed
	LED <= '1' & std_logic_vector(to_signed(stepCount1, 7));
	

	-- Process to handle PWM generation
	PWM_process : PROCESS(clk,reset)

	BEGIN
		-- Reset the PWM process
		IF (reset = '1') THEN

			-- Change all PWM parameters back to default
			PWM_enable0 <= '0';
			PWM_enable1 <= '0';
			PWM_dutycycle0 <= 0;
			PWM_dutycycle1 <= 0;
			PWM_CW0 <= '0';
			PWM_CW1 <= '0';
			PWM_frequency  <= 20000;

			-- Start calibration of the motors after reset
			CALL_calibrate_enable <= '1';
			stepReset <= '1';		-- Reset the stepcount

		ELSIF rising_edge(clk) THEN

			IF (CALL_calibrate_running = '1') THEN
				-- If calibrating, its process controlls the motors
				stepReset <= CALL_stepReset;

				PWM_dutycycle0 	<= CALL_dutycycle0;
				PWM_dutycycle1 	<= CALL_dutycycle1;
				PWM_CW0 		<= CALL_CW0;
				PWM_CW1			<= CALL_CW1;
				PWM_enable0		<= CALL_enable0;
				PWM_enable1		<= CALL_enable1;


			ELSE
				-- If not calibrating, the motors are controlled by the communication process

				-- Turn off calibration now that it is finished
				CALL_calibrate_enable <= COMM_recalibrate;

				-- Don't reset the step counter
				stepReset <= '0';

				-- communication control
				PWM_dutycycle0 	<= COMM_dutycycle0;
				PWM_dutycycle1 	<= COMM_dutycycle1;
				PWM_CW0 		<= COMM_CW0;
				PWM_CW1			<= COMM_CW1;

				-- Check if Motor 0 is at its min or max, if so, stop it from rotating any further
				IF (stepCount0 <= stepCount0_min + 1 AND COMM_CW0 = '0') OR
				   (stepCount0 >= stepCount0_max - 1 AND COMM_CW0 = '1') THEN

					PWM_enable0 <= '0';
				ELSE
					PWM_enable0		<= COMM_enable0;
				END IF;

				-- Check if Motor 1 is at its min or max, if so, stop it from rotating any further
				IF (stepCount1 <= stepCount1_min + 1 AND COMM_CW1 = '0') OR
				   (stepCount1 >= stepCount1_max - 1 AND COMM_CW1 = '1') THEN

					PWM_enable1 <= '0';
				ELSE
					PWM_enable1		<= COMM_enable1;
				END IF;

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

