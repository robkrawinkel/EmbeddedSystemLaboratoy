LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.common.ALL;

ENTITY MAC IS
	PORT (reset			: IN std_logic;
			inputA		: IN t_MAC_matrix; 
			inputAT		: IN t_MAC_matrix;
			inputB		: IN integer range 0 to 127;
			result 		: OUT integer range 0 to 89355
			);
END MAC;

ARCHITECTURE bhv OF MAC IS


	
BEGIN

	PROCESS(reset, inputA, inputAT, inputB)
		
	BEGIN
		IF reset = '0' THEN
			result <= 0;
		ELSE
			result <= inputA(0)*inputAT(0) + inputA(1)*inputAT(1) + inputA(2)*inputAT(2) + inputA(3)*inputAT(3) + inputA(4)*inputAT(4) + inputA(5)*inputAT(5) + inputA(6)*inputAT(6) + inputA(7)*inputAT(7) + inputA(8)*inputAT(8) + inputA(9)*inputAT(9) + inputA(10)*inputAT(10) + inputA(11)*inputAT(11) + inputA(12)*inputAT(12) + 2*inputB;	
		END IF;
		
		
	END PROCESS;
	
  
  
END bhv;