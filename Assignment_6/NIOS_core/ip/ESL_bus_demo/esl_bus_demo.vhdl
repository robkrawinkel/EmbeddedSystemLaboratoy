-------------------------------------------------------------------------------
-- 
-- ESL demo
-- Version: 1.0
-- Creator: Rene Moll
-- Date: 10th April 2012
--
-------------------------------------------------------------------------------
--
-- Straight forward INitialization and mappINg OF an IP to the avalon bus.
-- The communication part IS kept simple, sINce only regISter IS OF INterest.
--
-- Communication SIGNALs USE the prefix slave_
-- User SIGNALs USE the prefix user_
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY esl_bus_demo IS
	GENERIC (
		DATA_WIDTH : natural := 32;	-- word size OF each INput and OUTput regISter
		LED_WIDTH  : natural := 8	-- numbers OF LEDs on the DE0-NANO
	);
	PORT (
		-- SIGNALs to connect to an Avalon clock source INterface
		clk				: IN  std_logic;
		reset			: IN  std_logic;

		-- SIGNALs to connect to an Avalon-MM slave INterface
		slave_address		: IN  std_logic_vector(7 downto 0);
		slave_read			: IN  std_logic;
		slave_write			: IN  std_logic;
		slave_readdata		: OUT std_logic_vector(DATA_WIDTH-1 downto 0);
		slave_writedata		: IN  std_logic_vector(DATA_WIDTH-1 downto 0);
		slave_byteenable	: IN  std_logic_vector((DATA_WIDTH/8)-1 downto 0);

		-- SIGNALs to connect to custom user logic
		user_OUTput		: OUT std_logic_vector(LED_WIDTH-1 downto 0);
		GPIO_0			: INOUT std_logic_vector(33 downto 0);
		GPIO_1			: INOUT std_logic_vector(33 downto 0);
		KEY				: IN std_logic_vector(1 downto 0);
		SW				: IN std_logic_vector(3 downto 0)

	);
END ENTITY;

ARCHITECTURE behavior OF esl_bus_demo IS
	-- Internal memory for the system and a subset for the IP
	SIGNAL mem        		: std_logic_vector(31 downto 0);
	SIGNAL memSEND    		: std_logic_vector(31 downto 0);


	-- Signals for quadrature encoder
	SIGNAL stepCount0 		: integer;
	SIGNAL stepCount1 		: integer;

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
			stepCount : INOUT integer
			);
	END COMPONENT;


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
			stepCount => stepCount0
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
			stepCount => stepCount1
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
		
	
	-- Output to the leds a 1 and the step count of encoder 0 in 7 bits signed
	user_output <= '1' & std_logic_vector(to_signed(stepCount0, 7));
	

	-- Process to handle PWM generation
	PWM_process : PROCESS(clk,reset,KEY)
	BEGIN
		IF (reset = '1') THEN
			PWM_enable0 <= '0';
			PWM_enable1 <= '0';
			PWM_dutycycle0 <= 0;
			PWM_dutycycle1 <= 0;
			PWM_CW0 <= '0';
			PWM_CW1 <= '0';
			PWM_frequency  <= 20000;

		ELSIF rising_edge(clk) THEN

			PWM_frequency <= 20000;
			PWM_dutycycle1 <= 50;
			PWM_dutycycle0 <= 10;

			-- If key0 is pressed rotate both motors counter clockwise
			IF KEY(0) = '0' THEN
				PWM_CW0 <= '0';
				PWM_CW1 <= '0';
				PWM_enable0 <= '1';
				PWM_enable1 <= '1';

			-- If key1 is pressed rotate both motors clockwise
			ELSIF KEY(1) = '0' THEN
				PWM_CW0 <= '1';
				PWM_CW1 <= '1';
				PWM_enable0 <= '1';
				PWM_enable1 <= '1';

			-- If none of the buttons are pressed stop the PWM generation
			ELSE
				PWM_enable0 <= '0';
				PWM_enable1 <= '0';

			END IF;
		END IF;
	END PROCESS;


	-- Communication with the bus process
	p_avalon : PROCESS(clk, reset)
	BEGIN
		IF (reset = '1') THEN
			mem <= (others => '0');
			memSEND <= (others => '0');
		ELSIF (rISINg_edge(clk)) THEN
			memSEND <= std_logic_vector(to_signed(stepcount0,16)) & std_logic_vector(to_signed(stepCount1,16));
			
			IF (slave_read = '1') THEN
				slave_readdata <= memSEND;
			END IF;
			
			IF (slave_write = '1') THEN
				mem <= slave_writedata;
			END IF;
		END IF;
	END PROCESS;
	
END ARCHITECTURE;

