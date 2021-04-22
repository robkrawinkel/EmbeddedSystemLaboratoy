LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY esl_demonstrator IS
	PORT (
	-- CLOCK
	CLOCK_50	: IN std_logic;
	-- LEDs are only available on the DE0 Nano board.
	LED		: OUT std_logic_vector(7 DOWNTO 0);
	KEY		: IN std_logic_vector(1 DOWNTO 0);
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
	SIGNAL placeholder : std_logic_vector(10 DOWNTO 0);
BEGIN
	encoder : ENTITY work.QuadratureEncoder
		PORT MAP (
			-- MAP your encoder here to the I/O
		);
		
	pwm : ENTITY work.PulseWidthModulator
		PORT MAP (
			-- MAP your pulse width modulator here to the I/O
		);
END ARCHITECTURE;