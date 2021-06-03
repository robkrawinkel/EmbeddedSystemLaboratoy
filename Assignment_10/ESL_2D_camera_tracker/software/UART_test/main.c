//-----------------------------------------------------------------------------
// 
// ESL demo
// Version: 1.0
// Creator: Rene Moll
// Date: 10th April 2012
//
//-----------------------------------------------------------------------------
//
// Demo application which sets and reads form a register in the demo IP.
// 
// IOWR/IORD are part of the HAL, see the Nios 2 Software developer’s handbook
// for more information.
//
//-----------------------------------------------------------------------------
/*
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>

#include <io.h>
#include "system.h"

//UART interrupt
#include "sys/alt_irq.h"

#include "sys/alt_stdio.h"

#include "altera_avalon_uart_regs.h"
#include "altera_avalon_uart.h"
#include "altera_avalon_uart_fd.h"


#include "alt_types.h"


unsigned char RX;
int RXReceived = 0;
unsigned char TX;


void UARTReceive(void* context) {

	RX = IORD_ALTERA_AVALON_UART_RXDATA(UART_0_BASE);
	//RX = IORD(UART_0_BASE, 0);
	printf("message received\n");

	RXReceived = 1;

	
}

int main()
{
	// Say hello through the debug interface


	// Put 0x08 in the memory of the IP and enable the count down
	// IOWR(ESL_BUS_DEMO_0_BASE, 0x00, 1 << 31 | 0x08);

	// Verify that it is there

	int32_t nReadOut = 0;
	int32_t stepCount0 = 0;
	int32_t stepCount1 = 0;

	//setup for serial communication
    alt_ic_isr_register(UART_0_IRQ_INTERRUPT_CONTROLLER_ID, UART_0_IRQ, UARTReceive, NULL, NULL);

	//IOWR_ALTERA_AVALON_UART_STATUS(UART_0_BASE, 0x0); 					//Clear status register
	//IORD_ALTERA_AVALON_UART_RXDATA(UART_0_BASE); 						//Read the useless value in the empty receive register
	//IOWR_ALTERA_AVALON_UART_DIVISOR(UART_0_BASE, UART_0_FREQ/9600-1);	//Set the baud rate to 115200
	//IOWR_ALTERA_AVALON_UART_CONTROL(UART_0_BASE, 0x80); 				//Enable receive interrupt

	alt_ic_irq_enable(UART_0_IRQ_INTERRUPT_CONTROLLER_ID, UART_0_IRQ);

	IOWR(UART_0_BASE,1,12);

	printf("Hello from Nios II!\n");
	// Now loop forever ...
	while (1) {
		nReadOut = IORD(ESL_NIOS_II_IP_0_BASE, 0x00);

		stepCount0 = nReadOut >> 16;
		stepCount1 = nReadOut & 0x0000FFFF;

		//printf("%x \n\r", nReadOut);
		//printf("nReadOut: %x \t", nReadOut);
		
		//printf("stepCount0: %d\t stepCount1: %d \n\r", stepCount0, stepCount1);

		IOWR(UART_0_BASE,1,'A');
		usleep(1000000);

		if (RXReceived == 1) {
			TX = RX;UART_0_IRQ_INTERRUPT_CONTROLLER_ID,
			IOWR(UART_0_BASE, 1, TX);
			RXReceived = 0;
		}
	
	}



	return 0;
}*/

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <alt_types.h>
#include <io.h>
#include "system.h"
#include "sys/alt_irq.h"
#include "InterruptHandlerForUart.h"

#define BAUD_RATE_0 115200
#define BAUD_RATE_1 115200

void InitUart()
{
    int context_uart1,context_uart2;

    InitUart1(BAUD_RATE_0);
    //InitUart2(BAUD_RATE_1);

    //alt_ic_isr_register(UART_0_IRQ_INTERRUPT_CONTROLLER_ID,UART_0_IRQ,&context_uart1,IsrUart1,NULL); // install UART1 ISR
    alt_irq_register(UART_0_IRQ,&context_uart1,IsrUart1 ); // install UART1 ISR

    //alt_ic_irq_enable (UART_0_IRQ_INTERRUPT_CONTROLLER_ID,UART_0_IRQ);
    alt_irq_enable (UART_0_IRQ);
}


int main()
{
unsigned char ch;
printf("\n\nHello NiosII!!!!!\n");

InitUart();

while(1) {
	//IOWR_ALTERA_AVALON_UART_CONTROL(UART_0_BASE, 'A');
	//PutUart1('a');
	//usleep(10000);
	if(!EmptyUart1()){
		ch = GetUart1();
		printf("received message: %c\n",ch);
		PutUart1(':');
		PutUart1(ch);
		PutUart1('\r');
		PutUart1('\n');
	}
	/*
    if(!EmptyUart1()) {
        ch = GetUart1();
        PutUart2(ch);
    }
    if(!EmptyUart2()) {
        ch = GetUart2();
        PutUart1(ch);
    }*/
} //while

return 0;

}
