LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.common.ALL;

ENTITY int2hexdisp IS
	PORT (reset	: IN std_logic;
			x		: IN integer range 0 to 16777215; 
			HEX0	: OUT std_logic_vector (6 DOWNTO 0);
			HEX1	: OUT std_logic_vector (6 DOWNTO 0);
			HEX2	: OUT std_logic_vector (6 DOWNTO 0);
			HEX3	: OUT std_logic_vector (6 DOWNTO 0);
			HEX4	: OUT std_logic_vector (6 DOWNTO 0);
			HEX5	: OUT std_logic_vector (6 DOWNTO 0)
			);
END int2hexdisp;

ARCHITECTURE bhv OF int2hexdisp IS
	
	TYPE t_array_lut is array (0 to 15) of std_logic_vector (0 to 6);
	CONSTANT int2digit : t_array_lut := (
		NOT "0111111",
		NOT "0000110",
		NOT "1011011",
		NOT "1001111",
		NOT "1100110",
		NOT "1101101",
		NOT "1111101",
		NOT "0000111",
		NOT "1111111",
		NOT "1101111",
		NOT "1110111",
		NOT "1111100",
		NOT "0111001",
		NOT "1011110",
		NOT "1111001",
		NOT "1110001"
	);
	
BEGIN

	PROCESS(x, reset)
	
		VARIABLE D5	: integer range 0 to 15;
		VARIABLE D4	: integer range 0 to 15;
		VARIABLE D3	: integer range 0 to 15;
		VARIABLE D2	: integer range 0 to 15;
		VARIABLE D1	: integer range 0 to 15;
		VARIABLE D0	: integer range 0 to 15;
		VARIABLE x1 : integer range 0 to 16777215; -- max value that can be represented by the hex matrix
		
	BEGIN
	
		IF reset = '0' THEN
			D5 := 0;
			D4 := 0;
			D3 := 0;
			D2 := 0;
			D1 := 0;
			D0 := 0;
			x1 := 0;
			
			HEX5 <= NOT "1000000";
			HEX4 <= NOT "1000000";
			HEX3 <= NOT "1000000";
			HEX2 <= NOT "1000000";
			HEX1 <= NOT "1000000";
			HEX0 <= NOT "1000000";
			
		ELSE
		
			x1 := x;
			
			D5 := x1/1048576;
			x1 := x1 - D5*1048576;
			
			D4 := x1/65536;
			x1 := x1 - D4*65536;
			
			D3 := x1/4096;
			x1 := x1 - D3*4096;
			
			D2 := x1/256;
			x1 := x1 - D2*256;
			
			D1 := x1/16;
			
			D0 := x1 - D1*16;
			
			HEX5 <= int2digit(D5);
			HEX4 <= int2digit(D4);
			HEX3 <= int2digit(D3);
			HEX2 <= int2digit(D2);
			HEX1 <= int2digit(D1);
			HEX0 <= int2digit(D0);
			
		END IF;
		
	END PROCESS;
	
  
  
END bhv;