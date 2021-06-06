LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Communication IS
	GENERIC (
		DATA_WIDTH 	: natural := 32;	-- word size OF each INput and OUTput regISter
		MAX_PWM		: natural := 100	-- maximum speed for the motors
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
END ENTITY;

ARCHITECTURE bhv OF Communication IS
	

	-- Internal memory for the system
	SIGNAL memREAD     		: std_logic_vector(31 downto 0);
	SIGNAL memSEND    		: std_logic_vector(31 downto 0);

BEGIN
	

	-- Create a process which reacts to the specified signals
	PROCESS(reset, CLOCK_50)
		
		-- Variables that store the amount of clock cycles to count based on the set frequency and dutycycle
		VARIABLE PWM_0 : integer range -128 to 128;
		VARIABLE PWM_1 : integer range -128 to 128;
		VARIABLE counter : integer range 0 to 5000000;
		VARIABLE sendID : integer range 0 to 7;
		
	BEGIN
		
		-- Reset everything
		IF reset = '1' THEN
		
			enable0 <= '0';
			enable1 <= '0';
			memSend <= (others => '0');
			memREAD <= (others => '0');
			counter := 0;
			doRecalibrate <= '0';
			sendID := 1;
			
			
		ELSIF rising_edge(CLOCK_50) THEN
			------------------------------------------------------- Sending data

			IF (slave_read = '1') THEN
				CASE sendID IS
					WHEN 1 => 
						memSend <= std_logic_vector(to_signed(sendID,3)) & std_logic_vector(to_signed(stepcount0,11)) & std_logic_vector(to_signed(stepCount1,11)) & std_logic_vector(to_signed(0,32-11-11-3));
						sendID := 2;
					WHEN 2 => 
						memSend <= std_logic_vector(to_signed(sendID,3)) & std_logic_vector(to_signed(stepcount0Max,11)) & std_logic_vector(to_signed(stepCount1Max,11)) & std_logic_vector(to_signed(0,32-11-11-3));
						sendId := 1;
					WHEN OTHERS => 
						memSend <= (others => '0') ;
						sendID := 1;
				END CASE;
				slave_readdata <= memSEND;
			END IF;
			
			---------------------------------------------------- Reading data
			IF counter < 5000000 THEN --check if a message was received in the last 100ms
				IF (slave_write = '1') THEN
					counter := 0;
					memRead <= slave_writedata;
					
					--Control the PWM signals depending on the input signal
					PWM_0 := to_integer(signed(memRead(31 downto 24)));
					PWM_1 := to_integer(signed(memRead(23 downto 16)));
					doRecalibrate <= memRead(15);
					
					--If there is no control, so the PWM module should not be enabled
					IF (PWM_0 = 0) THEN
						enable0 <= '0';
						
					--If the Input signal is negative, so it should turn counter clockwise. Also inverts the PWM input signal so it is positive
					ELSIF (PWM_0 < 0) THEN
						enable0 <= '1';
						CW0 <= '0';
						--protection
						IF (PWM_0 < -MAX_PWM) THEN
							PWM_0 := -MAX_PWM;
						END IF;
						dutycycle0 <= -PWM_0;
					ELSE
						enable0 <= '1';
						CW0 <= '1';
						--protection
						IF (PWM_0 > MAX_PWM) THEN
							PWM_0 := MAX_PWM;
						END IF;
						dutycycle0 <= PWM_0;
					END IF;
					
					
					--If there is no control, so the PWM module should not be enabled
					IF (PWM_1 = 0) THEN
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
					
				END IF;
				counter := counter + 1;
			ELSE --counter overflow, not enough messages received
				counter := 0;
				enable1 <= '0';
				enable0 <= '0';
				doRecalibrate <= '0';
			END IF;
		END IF;
		
	END PROCESS;
	

END bhv;
