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
		GPIO_1			: INOUT std_logic_vector(33 downto 0)
	);
end entity;

architecture behavior of esl_bus_demo is
	-- Internal memory for the system and a subset for the IP
	signal mem        : std_logic_vector(31 downto 0);
	signal memSend    : std_logic_vector(31 downto 0);
	signal stepCount0 : integer;
	signal stepCount1 : integer;

	component QuadratureEncoder		
		PORT (
			-- CLOCK and reset
			reset		: IN std_logic;
			CLOCK_50	: IN std_logic;
			-- Signals from the encoder
			signalA	: IN std_logic;
			signalB	: IN std_logic;
			-- Output velocity in 32 bits
			velocity	: OUT integer;
			-- Output step counter in 32 bits signed
			stepCount : INOUT integer;
			-- Output error
			overSpeedError : OUT std_logic

			);
	end component;
	
	
	
	begin
	
	--------------------------------- quadrature encoder -----------------------------------
	encoder0 : QuadratureEncoder
		PORT MAP (
			-- CLOCK and reset
			reset		=> reset,
			CLOCK_50	=> clk,

			-- Signals from the encoder
			signalA	=> GPIO_0(20),
			signalB	=> GPIO_0(22),
			
			-- Output velocity in 32 bits
			velocity	=> open,
			
			-- Output step count
			stepCount => stepCount0,
			
			-- Output error
			overSpeedError => open
		);
	
	encoder1 : QuadratureEncoder
		PORT MAP (
			-- CLOCK and reset
			reset		=> reset,
			CLOCK_50	=> clk,

			-- Signals from the encoder
			signalA	=> GPIO_0(21),
			signalB	=> GPIO_0(23),
			
			-- Output velocity in 32 bits
			velocity	=> open,
			
			-- Output step count
			stepCount => stepCount1,
			
			-- Output error
			overSpeedError => open
		);
		
	user_output <= std_logic_vector(to_signed(stepCount0, 8));
	
	
	------------------------------------------------------------------------------------------
	-- Initialization of the example
	--my_ip : esl_bus_demo_example
	--generic map(
	--	DATA_WIDTH => LED_WIDTH
	--)
	--port map(
	--	clk    => clk,
	--	rst    => reset,
	--	input  => mem_masked,
	--	cnt_enable => enable,
	--	output => user_output
	--);

	-- Communication with the bus
	p_avalon : process(clk, reset)
	begin
		if (reset = '1') then
			mem <= (others => '0');
			memSend <= (others => '0');
		elsif (rising_edge(clk)) then
			memSend <= std_logic_vector(to_signed(stepcount0,16)) & std_logic_vector(to_signed(stepCount1,16));
			
			if (slave_read = '1') then
				slave_readdata <= memSend;
			end if;
			
			if (slave_write = '1') then
				mem <= slave_writedata;
			end if;
		end if;
	end process;
	
end architecture;
