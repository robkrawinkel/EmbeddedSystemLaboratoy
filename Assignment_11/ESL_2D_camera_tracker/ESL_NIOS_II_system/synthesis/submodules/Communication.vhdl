LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Communication IS
	GENERIC (
		DATA_WIDTH 	: natural := 32;	-- word size OF each INput and OUTput regISter
		MAX_PWM		: natural := 100;	-- maximum speed for the motors
		GPMC_ADDR_WIDTH_HIGH : integer := 10;
		GPMC_ADDR_WIDTH_LOW  : integer := 1;
		RAM_SIZE             : integer := 32
	);
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
END ENTITY;

ARCHITECTURE bhv OF Communication IS
	

-----------------------------------------GPMC driver
component ramstix_gpmc_driver is
    generic(
    DATA_WIDTH           : integer := 16;
    GPMC_ADDR_WIDTH_HIGH : integer := 10;
    GPMC_ADDR_WIDTH_LOW  : integer := 1;
    -- RAM_SIZE should be a power of 2
    RAM_SIZE             : integer := 32
  );
 port(
    clk           : in    std_logic;
    -- Input (data from fpga to gumstix) at IDX 0 and IDX 1
    in_reg0 : in std_logic_vector(16 - 1 downto 0);
    in_reg1 : in std_logic_vector(16 - 1 downto 0);

    -- Output (data from gumstix to fpga) at IDX 2 and IDX 3
    out_reg2      : out   std_logic_vector(16 - 1 downto 0);
    out_reg3      : out   std_logic_vector(16 - 1 downto 0);

	 -- GPMC bus signals
    GPMC_DATA     : inout std_logic_vector(16 - 1 downto 0);
    GPMC_ADDR     : in    std_logic_vector(GPMC_ADDR_WIDTH_HIGH downto GPMC_ADDR_WIDTH_LOW);
    GPMC_nPWE     : in    std_logic;
    GPMC_nOE      : in    std_logic;
    GPMC_FPGA_IRQ : in    std_logic;
    GPMC_nCS6     : in    std_logic;
    GPMC_CLK      : in    std_logic
  );


  end component;

    -- Define signals to connect the component to the gpmc_driver
	signal in_reg0 : std_logic_vector(16 - 1 downto 0) := (others => '0');
	signal in_reg1 : std_logic_vector(16 - 1 downto 0) := (others => '0');
   signal out_reg2 : std_logic_vector(16 - 1 downto 0) := (others => '0');
	signal out_reg3 : std_logic_vector(16 - 1 downto 0) := (others => '0');
  

	-- Internal memory for the system
	SIGNAL memREAD     		: std_logic_vector(31 downto 0);
	SIGNAL memSEND    		: std_logic_vector(31 downto 0);

BEGIN
	
  -- Map GPMC controller to I/O.
  gpmc_driver : ramstix_gpmc_driver generic map(
	DATA_WIDTH           => DATA_WIDTH,
	GPMC_ADDR_WIDTH_HIGH => GPMC_ADDR_WIDTH_HIGH,
	GPMC_ADDR_WIDTH_LOW  => GPMC_ADDR_WIDTH_LOW,
	RAM_SIZE             => RAM_SIZE
  )
  port map (
	clk           => CLOCK_50,
	in_reg0 => in_reg0,
	in_reg1 => in_reg1,
	out_reg2 => out_reg2,
	out_reg3 => out_reg3,
	GPMC_DATA     => GPMC_DATA,
	GPMC_ADDR     => GPMC_ADDR,
	GPMC_nPWE     => GPMC_nPWE,
	GPMC_nOE      => GPMC_nOE,
	GPMC_FPGA_IRQ => GPMC_FPGA_IRQ,
	GPMC_nCS6     => GPMC_nCS6,
	GPMC_CLK      => GPMC_CLK
  );
	-- Create a process which reacts to the specified signals
	PROCESS(reset, CLOCK_50)
		
		-- Variables that store the amount of clock cycles to count based on the set frequency and dutycycle
		VARIABLE PWM_0 : integer range -128 to 128;
		VARIABLE PWM_1 : integer range -128 to 128;
		VARIABLE counter : integer;
		VARIABLE sendID : integer range 0 to 7;
		VARIABLE calibrate_running_old : std_logic;
		
	BEGIN
		
		-- Reset everything
		IF reset = '1' THEN
		
			enable0 <= '0';
			enable1 <= '0';
			memSend <= (others => '0');
			memREAD <= (others => '0');
			counter := 0;
			doRecalibrate <= '0';
			calibrate_running_old := '0';
			sendID := 1;

			
			
		ELSIF rising_edge(CLOCK_50) THEN
			------------------------------------------------------- Sending data

			-- Only send the max values on the falling edge of the calibrate_running signal (when calibration is finished)
			IF calibrate_running /= calibrate_running_old AND calibrate_running = '0' THEN
				sendID := 2;
				calibrate_running_old := calibrate_running;
			ELSE
				calibrate_running_old := calibrate_running;
			END IF;

			-- Send data
			

				CASE sendID IS
					WHEN 1 => 
						memSend <= std_logic_vector(to_unsigned(sendID,3)) & std_logic_vector(to_unsigned(stepcount0,11)) & std_logic_vector(to_unsigned(stepCount1,11)) & std_logic_vector(to_signed(0,32-11-11-3));
					WHEN 2 => 
						memSend <= std_logic_vector(to_unsigned(sendID,3)) & std_logic_vector(to_unsigned(stepcount0Max,11)) & std_logic_vector(to_unsigned(stepCount1Max,11)) & std_logic_vector(to_signed(0,32-11-11-3));
						sendID := 1;
					WHEN OTHERS => 
						memSend <= (others => '0') ;
						sendID := 1;
				END CASE;
				in_reg0(15 downto 0) <= memSend(31 downto 16);
				in_reg1(15 downto 0) <= memSend(15 downto 0);

			
			---------------------------------------------------- Reading data

			
				counter := 0;
				memRead(31 downto 16) <= out_reg2(15 downto 0);
				memRead(15 downto 0) <= out_reg3(15 downto 0);
				
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



				--counter := counter + 1;
				--IF counter >= 50000000 THEN --check if a message was received in the last 100ms
				--	counter := 0;
				--	enable1 <= '0';
				--	enable0 <= '0';
				--	doRecalibrate <= '0';
				--END IF;
				


			

		END IF;
		
	END PROCESS;
	

END bhv;
