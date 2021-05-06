-------------------------------------------------------------------------------
-- 
-- ESL demo
-- Version: 1.0
-- Creator: Rene Moll
-- Date: 10th April 2012
--
-------------------------------------------------------------------------------
--
-- Straight forward initialization and mapping of an IP to the avalon bus.
-- The communication part is kept simple, since only register is of interest.
--
-- Communication signals use the prefix slave_
-- User signals use the prefix user_
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

entity esl_bus_demo is
	generic (
		DATA_WIDTH : natural := 32;	-- word size of each input and output register
		LED_WIDTH  : natural := 8	-- numbers of LEDs on the DE0-NANO
	);
	port (
		-- signals to connect to an Avalon clock source interface
		clk			: in  std_logic;
		reset			: in  std_logic;

		-- signals to connect to an Avalon-MM slave interface
		slave_address		: in  std_logic_vector(7 downto 0);
		slave_read			: in  std_logic;
		slave_write			: in  std_logic;
		slave_readdata		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		slave_writedata		: in  std_logic_vector(DATA_WIDTH-1 downto 0);
		slave_byteenable	: in  std_logic_vector((DATA_WIDTH/8)-1 downto 0);

		-- signals to connect to custom user logic
		user_output		: out std_logic_vector(LED_WIDTH-1 downto 0);
		GPIO_0			: INOUT std_logic_vector(33 downto 0);
		GPIO_1			: INOUT std_logic_vector(33 downto 0);
		KEY				: IN std_logic_vector(1 downto 0);
		SW				: IN std_logic_vector(3 downto 0)

	);
END entity;

ARCHITECTURE behavior of esl_bus_demo is
	-- Internal memory for the system and a subset for the IP
	signal mem        : std_logic_vector(31 downto 0);
	signal memSEND    : std_logic_vector(31 downto 0);

	-- Signals for quadrature encoder
	signal stepCount0 : integer;
	signal stepCount1 : integer;

	-- Signals for the PWM generation
	signal PWM_frequency : integer range 0 to 50000000;
	signal PWM_dutycycle0: integer range 0 to 100;
	signal PWM_dutycycle1: integer range 0 to 100;
	signal PWM_CW0	 : std_logic;
	signal PWM_CW1	 : std_logic;
	signal PWM_enable0: std_logic;
	signal PWM_enable1: std_logic;

	component QuadratureEncoder		
		PORT (
			-- CLOCK and reset
			reset		: IN std_logic;
			CLOCK_50	: IN std_logic;
			-- Signals from the encoder
			signalA	: IN std_logic;
			signalB	: IN std_logic;
			-- Output step counter in 32 bits signed
			stepCount : INOUT integer
			);
	END component;

	component PWM
		PORT (
			-- CLOCK and reset
			reset		: IN std_logic;
			CLOCK_50	: IN std_logic;
			-- Input signals module
			frequency	: IN integer range 0 to 50000000; --frequency of the signal in Hz
			dutycycle	: IN integer range 0 to 100; --dutycycle of the signal in percentage
			CW			: IN std_logic; --rotational direction of the signal
			-- Output pwm_signal and rotation direction
			PWM_signal 	: OUT std_logic;
			INA 		: OUT std_logic;
			INB			: OUT std_logic;

			enable		: IN std_logic
			);
	END component;
	
	
	BEGIN
	
	encoder0 : QuadratureEncoder
		PORT MAP (
			-- CLOCK and reset
			reset		=> reset,
			CLOCK_50	=> clk,

			-- Signals from the encoder
			signalA	=> GPIO_0(20),
			signalB	=> GPIO_0(22),
			
			-- Output step count
			stepCount => stepCount0
		);
		encoder1: QuadratureEncoder
		PORT MAP (
			-- CLOCK and reset
			reset		=> reset,
			CLOCK_50	=> clk,

			-- Signals from the encoder
			signalA	=> GPIO_0(21),
			signalB	=> GPIO_0(23),

			-- Output step count
			stepCount => stepCount1
		);

	PWM0: PWM
		PORT MAP (
			-- CLOCK and reset
			reset		=> reset,
			CLOCK_50	=> clk,
			-- Input signals module
			frequency	=> PWM_frequency,
			dutycycle	=> PWM_dutycycle0,
			CW			=> PWM_CW0,
			-- Output pwm_signal and rotation direction
			PWM_signal 	=> GPIO_0(8),
			INA 		=> GPIO_0(10),
			INB			=> GPIO_0(12),
			
			enable		=> PWM_enable0
			);

	PWM1: PWM
		PORT MAP (
			-- CLOCK and reset
			reset		=> reset,
			CLOCK_50	=> clk,
			-- Input signals module
			frequency	=> PWM_frequency,
			dutycycle	=> PWM_dutycycle1,
			CW			=> PWM_CW1,
			-- Output pwm_signal and rotation direction
			PWM_signal 	=> GPIO_0(9),
			INA 		=> GPIO_0(11),
			INB			=> GPIO_0(13),
			
			enable		=> PWM_enable1
			);
		
	user_output <= '1' & std_logic_vector(to_signed(stepCount0, 7));
	
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
			IF KEY(0) = '0' THEN
				PWM_CW0 <= '0';
				PWM_CW1 <= '0';
				PWM_enable0 <= '1';
				PWM_enable1 <= '1';
			ELSIF KEY(1) = '0' THEN
				PWM_CW0 <= '1';
				PWM_CW1 <= '1';
				PWM_enable0 <= '1';
				PWM_enable1 <= '1';
			ELSE
				PWM_enable0 <= '0';
				PWM_enable1 <= '0';
			END IF;
		END IF;
	END PROCESS;


	-- Communication with the bus
	p_avalon : PROCESS(clk, reset)
	BEGIN
		IF (reset = '1') THEN
			mem <= (others => '0');
			memSEND <= (others => '0');
		ELSIF (rising_edge(clk)) THEN
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

