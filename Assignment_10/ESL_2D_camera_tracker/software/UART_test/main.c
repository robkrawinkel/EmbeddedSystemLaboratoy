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

//packages
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <alt_types.h>
#include <io.h>
#include "system.h"
#include "sys/alt_irq.h"
#include "InterruptHandlerForUart.h"


//uart baudrate
#define BAUD_RATE_0 115200
#define BAUD_RATE_1 115200


/* 20-sim include files */
#include "xxsubmod.h"

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

//initialize 20-sim
XXDouble u [3 + 1];
	XXDouble y [1 + 1];

	/* Initialize the inputs and outputs with correct initial values */
	u[0] = 0.0;		/* corr */
	u[1] = 0.0;		/* in */
	u[2] = 0.0;		/* position */

	y[0] = 0.0;		/* out */


	/* Initialize the submodel itself */
	XXInitializeSubmodel (u, y, xx_time);
	
	//end initialize 20-sim
	
	//variables for avalon communication
	int32_t nReadOut = 0;
	int16_t stepCount0 = 0;
	int16_t stepCount1 = 0;
	int16_t stepCount0Old = 0;
	int16_t stepCount1Old = 0;
	int8_t PWM0 = 0;
	int8_t PWM1 = 0;
	int32_t avalondSend = 0;

	while( (xx_stop_simulation == XXFALSE) ) {

		//avalon bus communication
		nReadOut = IORD(ESL_NIOS_II_IP_0_BASE, 0x00);

		stepCount0 = nReadOut >> 32-11;
		int32_t temp32 = 0;
		temp32 = nReadOut << 11
		stepCount1 = temp32 >> 32-11;

		if(stepCount0 != stepCount0Old || stepCount1 != stepCount1Old)
			printf("stepCount0: %d\t stepCount1: %d \n\r", stepCount0, stepCount1);
		
		//generate inputs
		if(xx_time >= 5)
			u[1] = 100;
		if(xx_time >= 10)
			u[1] = 200;
		if(xx_time >= 15)
			u[1] = 100;
		
		
		/* Call the 20-sim submodel to calculate the output */
		u[2] = stepCount0;
		
		XXCalculateSubmodel (u, y, xx_time);
		PWM0 = y[0]*100;
		int16_t temp16 = 0;
		avalondSend = PWM0 & PWM1 & temp;
		IOWR(ESL_BUS_DEMO_0_BASE, 0x00,avalondSend);
		
		if(!EmptyUart1()){
			ch = GetUart1();
			printf("received message: %c\n",ch);
			PutUart1(ch);
			PutUart1('\r');
			PutUart1('\n');
			
			
		}
		
		stepCount0Old = stepCount0;
		stepCount1Old = stepCount1;

	} 

	/* Perform the final 20-sim calculations */
	XXTerminateSubmodel (u, y, xx_time)

return 0;

}
