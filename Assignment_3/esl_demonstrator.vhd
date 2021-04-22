LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY esl_demonstrator IS
	PORT (
	-- CLOCK
	CLOCK_50	: IN std_logic;
	-- LEDs are only available on the DE0 Nano board.
	LED		: OUT std_logic_vector(7 DOWNTO 0);		-- LED 0, overSpeedError enc0
																	-- LED 1, overSpeedError enc1
																	
	KEY		: IN std_logic_vector(1 DOWNTO 0);		-- SW 0, reset
	
	SW			: IN std_logic_vector(3 DOWNTO 0);

	-- GPIO_0, GPIO_0 connect to GPIO Default
	GPIO_0		: INOUT std_logic_vector(33 DOWNTO 0);
	GPIO_0_IN	: IN    std_logic_vector(1 DOWNTO 0);

	-- GPIO_1, GPIO_1 connect to GPIO Default
	GPIO_1		: INOUT std_logic_vector(33 DOWNTO 0);
	GPIO_1_IN	: IN    std_logic_vector(1 DOWNTO 0)
	);
END ENTITY;


ARCHITECTURE behavior OF esl_demonstrator IS
	SIGNAL velocity0 : integer;
	SIGNAL velocity1 : integer;
	
BEGIN
	encoder0 : ENTITY work.QuadratureEncoder
		PORT MAP (
			-- CLOCK and reset
			reset		=> KEY(0),
			CLOCK_50	=> CLOCK_50,

			-- Signals from the encoder
			signalA	=> GPIO_0(6),
			signalB	=> GPIO_0(7),
			
			-- Output velocity in 32 bits
			velocity	=> velocity0,
			
			-- Output error
			overSpeedError => LED(0)
		);
	
	encoder1 : ENTITY work.QuadratureEncoder
		PORT MAP (
			-- CLOCK and reset
			reset		=> KEY(0),
			CLOCK_50	=> CLOCK_50,

			-- Signals from the encoder
			signalA	=> GPIO_0(8),
			signalB	=> GPIO_0(9),
			
			-- Output velocity in 32 bits
			velocity	=> velocity1,
			
			-- Output error
			overSpeedError => LED(1)
		);
		
	--pwm : ENTITY work.PulseWidthModulator
		--PORT MAP (
			-- MAP your pulse width modulator here to the I/O
		--);
END ARCHITECTURE;