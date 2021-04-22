PACKAGE common IS

	TYPE t_matrix_lut IS ARRAY (0 to 168) of integer range 0 to 127;
	TYPE t_matrix_result IS ARRAY (0 to 168) of integer range 0 to 89355;
   TYPE t_MAC_matrix IS ARRAY (0 to 12) of integer range 0 to 127;
	TYPE t_matrix_lut_nest IS ARRAY (0 to 12) of t_MAC_matrix;
	
END common;

PACKAGE BODY common IS
   -- subprogram bodies here
END common;