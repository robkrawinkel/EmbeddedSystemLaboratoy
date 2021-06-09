
module ESL_NIOS_II_system (
	clk_clk,
	esl_nios_ii_ip_0_user_interface_LED,
	esl_nios_ii_ip_0_user_interface_GPIO_0,
	esl_nios_ii_ip_0_user_interface_KEY,
	esl_nios_ii_ip_0_user_interface_SW,
	reset_reset_n,
	uart_0_external_connection_rxd,
	uart_0_external_connection_txd);	

	input		clk_clk;
	output	[7:0]	esl_nios_ii_ip_0_user_interface_LED;
	inout	[33:0]	esl_nios_ii_ip_0_user_interface_GPIO_0;
	input	[1:0]	esl_nios_ii_ip_0_user_interface_KEY;
	input	[3:0]	esl_nios_ii_ip_0_user_interface_SW;
	input		reset_reset_n;
	input		uart_0_external_connection_rxd;
	output		uart_0_external_connection_txd;
endmodule
