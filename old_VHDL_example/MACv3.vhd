LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--USE IEEE.numeric_std.ALL;
USE ieee.std_logic_arith.all;
USE work.common.ALL;

ENTITY MACv3 IS
	PORT (KEY	: IN std_logic_vector (3 DOWNTO 0); 
			SW 	: IN std_logic_vector (9 DOWNTO 0);
			
			HEX0	: OUT std_logic_vector (6 DOWNTO 0);
			HEX1	: OUT std_logic_vector (6 DOWNTO 0);
			HEX2	: OUT std_logic_vector (6 DOWNTO 0);
			HEX3	: OUT std_logic_vector (6 DOWNTO 0);
			HEX4	: OUT std_logic_vector (6 DOWNTO 0);
			HEX5	: OUT std_logic_vector (6 DOWNTO 0)
			);
END MACv3;




ARCHITECTURE bhv OF MACv3 IS

	
	
	SIGNAL matrixA : t_matrix_lut_nest 	:= ((0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0));
	SIGNAL matrixAT : t_matrix_lut_nest := ((0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0));
	SIGNAL matrixB : t_matrix_lut			:= (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
	SIGNAL matrixZ : t_matrix_result		:= (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

	

	COMPONENT int2hexdisp IS
		PORT (reset	: IN std_logic;
				x		: IN integer range 0 to 16777215; 
				HEX0	: OUT std_logic_vector (6 DOWNTO 0);
				HEX1	: OUT std_logic_vector (6 DOWNTO 0);
				HEX2	: OUT std_logic_vector (6 DOWNTO 0);
				HEX3	: OUT std_logic_vector (6 DOWNTO 0);
				HEX4	: OUT std_logic_vector (6 DOWNTO 0);
				HEX5	: OUT std_logic_vector (6 DOWNTO 0)
			);
	END COMPONENT int2hexdisp;
	SIGNAL display : integer range 0 to 16777215; -- max value that can be represented by the hex matrix
	
	COMPONENT MAC IS
		PORT (reset			: IN std_logic;
				inputA		: IN t_MAC_matrix; 
				inputAT		: IN t_MAC_matrix;
				inputB		: IN integer range 0 to 127;
				result 		: OUT integer range 0 to 89355
				);
	END COMPONENT;

	
	
	
BEGIN

	disp 	: int2hexdisp	PORT MAP (KEY(0), display, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
		
	MAC0	: MAC				PORT MAP (KEY(0), matrixA(0), matrixAT(0), matrixB(0), matrixZ(0));
	MAC1	: MAC				PORT MAP (KEY(0), matrixA(0), matrixAT(1), matrixB(1), matrixZ(1));
	MAC2	: MAC				PORT MAP (KEY(0), matrixA(0), matrixAT(2), matrixB(2), matrixZ(2));
	MAC3	: MAC				PORT MAP (KEY(0), matrixA(0), matrixAT(3), matrixB(3), matrixZ(3));
	MAC4	: MAC				PORT MAP (KEY(0), matrixA(0), matrixAT(4), matrixB(4), matrixZ(4));
	MAC5	: MAC				PORT MAP (KEY(0), matrixA(0), matrixAT(5), matrixB(5), matrixZ(5));
	MAC6	: MAC				PORT MAP (KEY(0), matrixA(0), matrixAT(6), matrixB(6), matrixZ(6));
	MAC7	: MAC				PORT MAP (KEY(0), matrixA(0), matrixAT(7), matrixB(7), matrixZ(7));
	MAC8	: MAC				PORT MAP (KEY(0), matrixA(0), matrixAT(8), matrixB(8), matrixZ(8));
	MAC9	: MAC				PORT MAP (KEY(0), matrixA(0), matrixAT(9), matrixB(9), matrixZ(9));
	MAC10	: MAC				PORT MAP (KEY(0), matrixA(0), matrixAT(10), matrixB(10), matrixZ(10));
	MAC11	: MAC				PORT MAP (KEY(0), matrixA(0), matrixAT(11), matrixB(11), matrixZ(11));
	MAC12	: MAC				PORT MAP (KEY(0), matrixA(0), matrixAT(12), matrixB(12), matrixZ(12));
	MAC13	: MAC				PORT MAP (KEY(0), matrixA(1), matrixAT(0), matrixB(13), matrixZ(13));
	MAC14	: MAC				PORT MAP (KEY(0), matrixA(1), matrixAT(1), matrixB(14), matrixZ(14));
	MAC15	: MAC				PORT MAP (KEY(0), matrixA(1), matrixAT(2), matrixB(15), matrixZ(15));
	MAC16	: MAC				PORT MAP (KEY(0), matrixA(1), matrixAT(3), matrixB(16), matrixZ(16));
	MAC17	: MAC				PORT MAP (KEY(0), matrixA(1), matrixAT(4), matrixB(17), matrixZ(17));
	MAC18	: MAC				PORT MAP (KEY(0), matrixA(1), matrixAT(5), matrixB(18), matrixZ(18));
	MAC19	: MAC				PORT MAP (KEY(0), matrixA(1), matrixAT(6), matrixB(19), matrixZ(19));
	MAC20	: MAC				PORT MAP (KEY(0), matrixA(1), matrixAT(7), matrixB(20), matrixZ(20));
	MAC21	: MAC				PORT MAP (KEY(0), matrixA(1), matrixAT(8), matrixB(21), matrixZ(21));
	MAC22	: MAC				PORT MAP (KEY(0), matrixA(1), matrixAT(9), matrixB(22), matrixZ(22));
	MAC23	: MAC				PORT MAP (KEY(0), matrixA(1), matrixAT(10), matrixB(23), matrixZ(23));
	MAC24	: MAC				PORT MAP (KEY(0), matrixA(1), matrixAT(11), matrixB(24), matrixZ(24));
	MAC25	: MAC				PORT MAP (KEY(0), matrixA(1), matrixAT(12), matrixB(25), matrixZ(25));
	MAC26	: MAC				PORT MAP (KEY(0), matrixA(2), matrixAT(0), matrixB(26), matrixZ(26));
	MAC27	: MAC				PORT MAP (KEY(0), matrixA(2), matrixAT(1), matrixB(27), matrixZ(27));
	MAC28	: MAC				PORT MAP (KEY(0), matrixA(2), matrixAT(2), matrixB(28), matrixZ(28));
	MAC29	: MAC				PORT MAP (KEY(0), matrixA(2), matrixAT(3), matrixB(29), matrixZ(29));
	MAC30	: MAC				PORT MAP (KEY(0), matrixA(2), matrixAT(4), matrixB(30), matrixZ(30));
	MAC31	: MAC				PORT MAP (KEY(0), matrixA(2), matrixAT(5), matrixB(31), matrixZ(31));
	MAC32	: MAC				PORT MAP (KEY(0), matrixA(2), matrixAT(6), matrixB(32), matrixZ(32));
	MAC33	: MAC				PORT MAP (KEY(0), matrixA(2), matrixAT(7), matrixB(33), matrixZ(33));
	MAC34	: MAC				PORT MAP (KEY(0), matrixA(2), matrixAT(8), matrixB(34), matrixZ(34));
	MAC35	: MAC				PORT MAP (KEY(0), matrixA(2), matrixAT(9), matrixB(35), matrixZ(35));
	MAC36	: MAC				PORT MAP (KEY(0), matrixA(2), matrixAT(10), matrixB(36), matrixZ(36));
	MAC37	: MAC				PORT MAP (KEY(0), matrixA(2), matrixAT(11), matrixB(37), matrixZ(37));
	MAC38	: MAC				PORT MAP (KEY(0), matrixA(2), matrixAT(12), matrixB(38), matrixZ(38));
	MAC39	: MAC				PORT MAP (KEY(0), matrixA(3), matrixAT(0), matrixB(39), matrixZ(39));
	MAC40	: MAC				PORT MAP (KEY(0), matrixA(3), matrixAT(1), matrixB(40), matrixZ(40));
	MAC41	: MAC				PORT MAP (KEY(0), matrixA(3), matrixAT(2), matrixB(41), matrixZ(41));
	MAC42	: MAC				PORT MAP (KEY(0), matrixA(3), matrixAT(3), matrixB(42), matrixZ(42));
	MAC43	: MAC				PORT MAP (KEY(0), matrixA(3), matrixAT(4), matrixB(43), matrixZ(43));
	MAC44	: MAC				PORT MAP (KEY(0), matrixA(3), matrixAT(5), matrixB(44), matrixZ(44));
	MAC45	: MAC				PORT MAP (KEY(0), matrixA(3), matrixAT(6), matrixB(45), matrixZ(45));
	MAC46	: MAC				PORT MAP (KEY(0), matrixA(3), matrixAT(7), matrixB(46), matrixZ(46));
	MAC47	: MAC				PORT MAP (KEY(0), matrixA(3), matrixAT(8), matrixB(47), matrixZ(47));
	MAC48	: MAC				PORT MAP (KEY(0), matrixA(3), matrixAT(9), matrixB(48), matrixZ(48));
	MAC49	: MAC				PORT MAP (KEY(0), matrixA(3), matrixAT(10), matrixB(49), matrixZ(49));
	MAC50	: MAC				PORT MAP (KEY(0), matrixA(3), matrixAT(11), matrixB(50), matrixZ(50));
	MAC51	: MAC				PORT MAP (KEY(0), matrixA(3), matrixAT(12), matrixB(51), matrixZ(51));
	MAC52	: MAC				PORT MAP (KEY(0), matrixA(4), matrixAT(0), matrixB(52), matrixZ(52));
	MAC53	: MAC				PORT MAP (KEY(0), matrixA(4), matrixAT(1), matrixB(53), matrixZ(53));
	MAC54	: MAC				PORT MAP (KEY(0), matrixA(4), matrixAT(2), matrixB(54), matrixZ(54));
	MAC55	: MAC				PORT MAP (KEY(0), matrixA(4), matrixAT(3), matrixB(55), matrixZ(55));
	MAC56	: MAC				PORT MAP (KEY(0), matrixA(4), matrixAT(4), matrixB(56), matrixZ(56));
	MAC57	: MAC				PORT MAP (KEY(0), matrixA(4), matrixAT(5), matrixB(57), matrixZ(57));
	MAC58	: MAC				PORT MAP (KEY(0), matrixA(4), matrixAT(6), matrixB(58), matrixZ(58));
	MAC59	: MAC				PORT MAP (KEY(0), matrixA(4), matrixAT(7), matrixB(59), matrixZ(59));
	MAC60	: MAC				PORT MAP (KEY(0), matrixA(4), matrixAT(8), matrixB(60), matrixZ(60));
	MAC61	: MAC				PORT MAP (KEY(0), matrixA(4), matrixAT(9), matrixB(61), matrixZ(61));
	MAC62	: MAC				PORT MAP (KEY(0), matrixA(4), matrixAT(10), matrixB(62), matrixZ(62));
	MAC63	: MAC				PORT MAP (KEY(0), matrixA(4), matrixAT(11), matrixB(63), matrixZ(63));
	MAC64	: MAC				PORT MAP (KEY(0), matrixA(4), matrixAT(12), matrixB(64), matrixZ(64));
	MAC65	: MAC				PORT MAP (KEY(0), matrixA(5), matrixAT(0), matrixB(65), matrixZ(65));
	MAC66	: MAC				PORT MAP (KEY(0), matrixA(5), matrixAT(1), matrixB(66), matrixZ(66));
	MAC67	: MAC				PORT MAP (KEY(0), matrixA(5), matrixAT(2), matrixB(67), matrixZ(67));
	MAC68	: MAC				PORT MAP (KEY(0), matrixA(5), matrixAT(3), matrixB(68), matrixZ(68));
	MAC69	: MAC				PORT MAP (KEY(0), matrixA(5), matrixAT(4), matrixB(69), matrixZ(69));
	MAC70	: MAC				PORT MAP (KEY(0), matrixA(5), matrixAT(5), matrixB(70), matrixZ(70));
	MAC71	: MAC				PORT MAP (KEY(0), matrixA(5), matrixAT(6), matrixB(71), matrixZ(71));
	MAC72	: MAC				PORT MAP (KEY(0), matrixA(5), matrixAT(7), matrixB(72), matrixZ(72));
	MAC73	: MAC				PORT MAP (KEY(0), matrixA(5), matrixAT(8), matrixB(73), matrixZ(73));
	MAC74	: MAC				PORT MAP (KEY(0), matrixA(5), matrixAT(9), matrixB(74), matrixZ(74));
	MAC75	: MAC				PORT MAP (KEY(0), matrixA(5), matrixAT(10), matrixB(75), matrixZ(75));
	MAC76	: MAC				PORT MAP (KEY(0), matrixA(5), matrixAT(11), matrixB(76), matrixZ(76));
	MAC77	: MAC				PORT MAP (KEY(0), matrixA(5), matrixAT(12), matrixB(77), matrixZ(77));
	MAC78	: MAC				PORT MAP (KEY(0), matrixA(6), matrixAT(0), matrixB(78), matrixZ(78));
	MAC79	: MAC				PORT MAP (KEY(0), matrixA(6), matrixAT(1), matrixB(79), matrixZ(79));
	MAC80	: MAC				PORT MAP (KEY(0), matrixA(6), matrixAT(2), matrixB(80), matrixZ(80));
	MAC81	: MAC				PORT MAP (KEY(0), matrixA(6), matrixAT(3), matrixB(81), matrixZ(81));
	MAC82	: MAC				PORT MAP (KEY(0), matrixA(6), matrixAT(4), matrixB(82), matrixZ(82));
	MAC83	: MAC				PORT MAP (KEY(0), matrixA(6), matrixAT(5), matrixB(83), matrixZ(83));
	MAC84	: MAC				PORT MAP (KEY(0), matrixA(6), matrixAT(6), matrixB(84), matrixZ(84));
	MAC85	: MAC				PORT MAP (KEY(0), matrixA(6), matrixAT(7), matrixB(85), matrixZ(85));
	MAC86	: MAC				PORT MAP (KEY(0), matrixA(6), matrixAT(8), matrixB(86), matrixZ(86));
	MAC87	: MAC				PORT MAP (KEY(0), matrixA(6), matrixAT(9), matrixB(87), matrixZ(87));
	MAC88	: MAC				PORT MAP (KEY(0), matrixA(6), matrixAT(10), matrixB(88), matrixZ(88));
	MAC89	: MAC				PORT MAP (KEY(0), matrixA(6), matrixAT(11), matrixB(89), matrixZ(89));
	MAC90	: MAC				PORT MAP (KEY(0), matrixA(6), matrixAT(12), matrixB(90), matrixZ(90));
	MAC91	: MAC				PORT MAP (KEY(0), matrixA(7), matrixAT(0), matrixB(91), matrixZ(91));
	MAC92	: MAC				PORT MAP (KEY(0), matrixA(7), matrixAT(1), matrixB(92), matrixZ(92));
	MAC93	: MAC				PORT MAP (KEY(0), matrixA(7), matrixAT(2), matrixB(93), matrixZ(93));
	MAC94	: MAC				PORT MAP (KEY(0), matrixA(7), matrixAT(3), matrixB(94), matrixZ(94));
	MAC95	: MAC				PORT MAP (KEY(0), matrixA(7), matrixAT(4), matrixB(95), matrixZ(95));
	MAC96	: MAC				PORT MAP (KEY(0), matrixA(7), matrixAT(5), matrixB(96), matrixZ(96));
	MAC97	: MAC				PORT MAP (KEY(0), matrixA(7), matrixAT(6), matrixB(97), matrixZ(97));
	MAC98	: MAC				PORT MAP (KEY(0), matrixA(7), matrixAT(7), matrixB(98), matrixZ(98));
	MAC99	: MAC				PORT MAP (KEY(0), matrixA(7), matrixAT(8), matrixB(99), matrixZ(99));
	MAC100	: MAC				PORT MAP (KEY(0), matrixA(7), matrixAT(9), matrixB(100), matrixZ(100));
	MAC101	: MAC				PORT MAP (KEY(0), matrixA(7), matrixAT(10), matrixB(101), matrixZ(101));
	MAC102	: MAC				PORT MAP (KEY(0), matrixA(7), matrixAT(11), matrixB(102), matrixZ(102));
	MAC103	: MAC				PORT MAP (KEY(0), matrixA(7), matrixAT(12), matrixB(103), matrixZ(103));
	MAC104	: MAC				PORT MAP (KEY(0), matrixA(8), matrixAT(0), matrixB(104), matrixZ(104));
	MAC105	: MAC				PORT MAP (KEY(0), matrixA(8), matrixAT(1), matrixB(105), matrixZ(105));
	MAC106	: MAC				PORT MAP (KEY(0), matrixA(8), matrixAT(2), matrixB(106), matrixZ(106));
	MAC107	: MAC				PORT MAP (KEY(0), matrixA(8), matrixAT(3), matrixB(107), matrixZ(107));
	MAC108	: MAC				PORT MAP (KEY(0), matrixA(8), matrixAT(4), matrixB(108), matrixZ(108));
	MAC109	: MAC				PORT MAP (KEY(0), matrixA(8), matrixAT(5), matrixB(109), matrixZ(109));
	MAC110	: MAC				PORT MAP (KEY(0), matrixA(8), matrixAT(6), matrixB(110), matrixZ(110));
	MAC111	: MAC				PORT MAP (KEY(0), matrixA(8), matrixAT(7), matrixB(111), matrixZ(111));
	MAC112	: MAC				PORT MAP (KEY(0), matrixA(8), matrixAT(8), matrixB(112), matrixZ(112));
	MAC113	: MAC				PORT MAP (KEY(0), matrixA(8), matrixAT(9), matrixB(113), matrixZ(113));
	MAC114	: MAC				PORT MAP (KEY(0), matrixA(8), matrixAT(10), matrixB(114), matrixZ(114));
	MAC115	: MAC				PORT MAP (KEY(0), matrixA(8), matrixAT(11), matrixB(115), matrixZ(115));
	MAC116	: MAC				PORT MAP (KEY(0), matrixA(8), matrixAT(12), matrixB(116), matrixZ(116));
	MAC117	: MAC				PORT MAP (KEY(0), matrixA(9), matrixAT(0), matrixB(117), matrixZ(117));
	MAC118	: MAC				PORT MAP (KEY(0), matrixA(9), matrixAT(1), matrixB(118), matrixZ(118));
	MAC119	: MAC				PORT MAP (KEY(0), matrixA(9), matrixAT(2), matrixB(119), matrixZ(119));
	MAC120	: MAC				PORT MAP (KEY(0), matrixA(9), matrixAT(3), matrixB(120), matrixZ(120));
	MAC121	: MAC				PORT MAP (KEY(0), matrixA(9), matrixAT(4), matrixB(121), matrixZ(121));
	MAC122	: MAC				PORT MAP (KEY(0), matrixA(9), matrixAT(5), matrixB(122), matrixZ(122));
	MAC123	: MAC				PORT MAP (KEY(0), matrixA(9), matrixAT(6), matrixB(123), matrixZ(123));
	MAC124	: MAC				PORT MAP (KEY(0), matrixA(9), matrixAT(7), matrixB(124), matrixZ(124));
	MAC125	: MAC				PORT MAP (KEY(0), matrixA(9), matrixAT(8), matrixB(125), matrixZ(125));
	MAC126	: MAC				PORT MAP (KEY(0), matrixA(9), matrixAT(9), matrixB(126), matrixZ(126));
	MAC127	: MAC				PORT MAP (KEY(0), matrixA(9), matrixAT(10), matrixB(127), matrixZ(127));
	MAC128	: MAC				PORT MAP (KEY(0), matrixA(9), matrixAT(11), matrixB(128), matrixZ(128));
	MAC129	: MAC				PORT MAP (KEY(0), matrixA(9), matrixAT(12), matrixB(129), matrixZ(129));
	MAC130	: MAC				PORT MAP (KEY(0), matrixA(10), matrixAT(0), matrixB(130), matrixZ(130));
	MAC131	: MAC				PORT MAP (KEY(0), matrixA(10), matrixAT(1), matrixB(131), matrixZ(131));
	MAC132	: MAC				PORT MAP (KEY(0), matrixA(10), matrixAT(2), matrixB(132), matrixZ(132));
	MAC133	: MAC				PORT MAP (KEY(0), matrixA(10), matrixAT(3), matrixB(133), matrixZ(133));
	MAC134	: MAC				PORT MAP (KEY(0), matrixA(10), matrixAT(4), matrixB(134), matrixZ(134));
	MAC135	: MAC				PORT MAP (KEY(0), matrixA(10), matrixAT(5), matrixB(135), matrixZ(135));
	MAC136	: MAC				PORT MAP (KEY(0), matrixA(10), matrixAT(6), matrixB(136), matrixZ(136));
	MAC137	: MAC				PORT MAP (KEY(0), matrixA(10), matrixAT(7), matrixB(137), matrixZ(137));
	MAC138	: MAC				PORT MAP (KEY(0), matrixA(10), matrixAT(8), matrixB(138), matrixZ(138));
	MAC139	: MAC				PORT MAP (KEY(0), matrixA(10), matrixAT(9), matrixB(139), matrixZ(139));
	MAC140	: MAC				PORT MAP (KEY(0), matrixA(10), matrixAT(10), matrixB(140), matrixZ(140));
	MAC141	: MAC				PORT MAP (KEY(0), matrixA(10), matrixAT(11), matrixB(141), matrixZ(141));
	MAC142	: MAC				PORT MAP (KEY(0), matrixA(10), matrixAT(12), matrixB(142), matrixZ(142));
	MAC143	: MAC				PORT MAP (KEY(0), matrixA(11), matrixAT(0), matrixB(143), matrixZ(143));
	MAC144	: MAC				PORT MAP (KEY(0), matrixA(11), matrixAT(1), matrixB(144), matrixZ(144));
	MAC145	: MAC				PORT MAP (KEY(0), matrixA(11), matrixAT(2), matrixB(145), matrixZ(145));
	MAC146	: MAC				PORT MAP (KEY(0), matrixA(11), matrixAT(3), matrixB(146), matrixZ(146));
	MAC147	: MAC				PORT MAP (KEY(0), matrixA(11), matrixAT(4), matrixB(147), matrixZ(147));
	MAC148	: MAC				PORT MAP (KEY(0), matrixA(11), matrixAT(5), matrixB(148), matrixZ(148));
	MAC149	: MAC				PORT MAP (KEY(0), matrixA(11), matrixAT(6), matrixB(149), matrixZ(149));
	MAC150	: MAC				PORT MAP (KEY(0), matrixA(11), matrixAT(7), matrixB(150), matrixZ(150));
	MAC151	: MAC				PORT MAP (KEY(0), matrixA(11), matrixAT(8), matrixB(151), matrixZ(151));
	MAC152	: MAC				PORT MAP (KEY(0), matrixA(11), matrixAT(9), matrixB(152), matrixZ(152));
	MAC153	: MAC				PORT MAP (KEY(0), matrixA(11), matrixAT(10), matrixB(153), matrixZ(153));
	MAC154	: MAC				PORT MAP (KEY(0), matrixA(11), matrixAT(11), matrixB(154), matrixZ(154));
	MAC155	: MAC				PORT MAP (KEY(0), matrixA(11), matrixAT(12), matrixB(155), matrixZ(155));
	MAC156	: MAC				PORT MAP (KEY(0), matrixA(12), matrixAT(0), matrixB(156), matrixZ(156));
	MAC157	: MAC				PORT MAP (KEY(0), matrixA(12), matrixAT(1), matrixB(157), matrixZ(157));
	MAC158	: MAC				PORT MAP (KEY(0), matrixA(12), matrixAT(2), matrixB(158), matrixZ(158));
	MAC159	: MAC				PORT MAP (KEY(0), matrixA(12), matrixAT(3), matrixB(159), matrixZ(159));
	MAC160	: MAC				PORT MAP (KEY(0), matrixA(12), matrixAT(4), matrixB(160), matrixZ(160));
	MAC161	: MAC				PORT MAP (KEY(0), matrixA(12), matrixAT(5), matrixB(161), matrixZ(161));
	MAC162	: MAC				PORT MAP (KEY(0), matrixA(12), matrixAT(6), matrixB(162), matrixZ(162));
	MAC163	: MAC				PORT MAP (KEY(0), matrixA(12), matrixAT(7), matrixB(163), matrixZ(163));
	MAC164	: MAC				PORT MAP (KEY(0), matrixA(12), matrixAT(8), matrixB(164), matrixZ(164));
	MAC165	: MAC				PORT MAP (KEY(0), matrixA(12), matrixAT(9), matrixB(165), matrixZ(165));
	MAC166	: MAC				PORT MAP (KEY(0), matrixA(12), matrixAT(10), matrixB(166), matrixZ(166));
	MAC167	: MAC				PORT MAP (KEY(0), matrixA(12), matrixAT(11), matrixB(167), matrixZ(167));
	MAC168	: MAC				PORT MAP (KEY(0), matrixA(12), matrixAT(12), matrixB(168), matrixZ(168));

	PROCESS(KEY, SW, matrixZ)
		
		
	BEGIN
		IF KEY(0) = '0' THEN
			matrixA <= ((14,39,117,89,111,73,79,102,52,81,123,70,39),(82,29,125,85,51,60,102,39,120,106,19,15,58),(124,31,32,23,19,69,60,61,10,33,72,1,91),(96,112,32,111,90,12,63,77,47,105,115,38,90),(13,35,23,78,57,109,122,89,21,116,86,123,113),(27,14,80,69,9,23,106,26,115,31,6,73,112),(53,70,64,118,121,17,6,113,30,8,5,116,66),(12,113,71,94,98,116,2,95,66,107,54,11,34),(90,36,81,124,73,41,105,14,127,109,87,29,2),(84,77,56,81,21,81,110,110,123,104,113,39,54),(75,102,44,79,61,55,90,125,52,45,4,120,12),(20,20,105,41,20,44,108,74,72,62,76,34,111),(38,97,124,5,97,87,85,106,12,31,87,6,77));
			matrixAT <= ((14,82,124,96,13,27,53,12,90,84,75,20,38),(39,29,31,112,35,14,70,113,36,77,102,20,97),(117,125,32,32,23,80,64,71,81,56,44,105,124),(89,85,23,111,78,69,118,94,124,81,79,41,5),(111,51,19,90,57,9,121,98,73,21,61,20,97),(73,60,69,12,109,23,17,116,41,81,55,44,87),(79,102,60,63,122,106,6,2,105,110,90,108,85),(102,39,61,77,89,26,113,95,14,110,125,74,106),(52,120,10,47,21,115,30,66,127,123,52,72,12),(81,106,33,105,116,31,8,107,109,104,45,62,31),(123,19,72,115,86,6,5,54,87,113,4,76,87),(70,15,1,38,123,73,116,11,29,39,120,34,6),(39,58,91,90,113,112,66,34,2,54,12,111,77));	
			matrixB <= (69,96,71,89,127,108,96,121,64,65,62,91,73,9,67,113,48,47,53,96,66,7,63,17,9,8,107,45,112,33,114,48,102,70,52,47,34,81,17,38,15,61,1,104,82,68,53,69,110,12,25,46,111,89,54,0,107,81,127,124,36,17,99,117,75,125,72,48,67,31,104,64,98,94,57,81,15,16,111,16,127,119,88,41,75,125,22,50,120,6,81,75,7,78,38,35,115,114,37,66,106,64,91,97,75,102,84,112,65,76,87,22,45,100,19,18,89,27,25,109,18,116,19,116,33,103,31,29,78,8,24,12,86,20,32,53,31,13,51,36,100,56,44,13,8,54,24,101,73,115,120,56,23,63,39,93,77,50,108,56,106,58,121,74,70,88,19,49,83);
		
		END IF;
		
		display <= matrixZ(CONV_INTEGER(unsigned(SW)));
		
	END PROCESS;

	
  
  
END bhv;