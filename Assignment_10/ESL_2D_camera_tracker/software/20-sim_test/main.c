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
#include <stdint.h>

#include <alt_types.h>
#include <io.h>
#include "system.h"
#include "sys/alt_irq.h"
#include "InterruptHandlerForUart.h"


#include "sys/alt_stdio.h"

#include "altera_avalon_uart_regs.h"
#include "altera_avalon_uart.h"
#include "altera_avalon_uart_fd.h"


//uart baudrate
#define BAUD_RATE_0 115200


/* 20-sim include files */
#include "xxsubmod.h"

#define pi 3.1415926538
uint16_t maxStepCount0 = 1115;
uint16_t maxStepCount1 = 221;

void InitUart()
{
    int context_uart0;

    InitUart0(BAUD_RATE_0);

    //alt_ic_isr_register(UART_0_IRQ_INTERRUPT_CONTROLLER_ID,UART_0_IRQ,&context_uart1,IsrUart1,NULL); // install UART1 ISR
    alt_irq_register(UART_0_IRQ,&context_uart0,IsrUart0); // install UART0 ISR

    //alt_ic_irq_enable (UART_0_IRQ_INTERRUPT_CONTROLLER_ID,UART_0_IRQ);
    alt_irq_enable (UART_0_IRQ);
}

double Stepcount1ToSI(int16_t steps)
{
	double stepsPerRotation = maxStepCount1/170*360;
	return steps/stepsPerRotation*2*pi;

}

double Stepcount0ToSI(int16_t steps)
{
	double stepsPerRotation = maxStepCount0/325*360;
	return steps/stepsPerRotation*2*pi;
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
	XXInitializeSubmodel (&u, &y, xx_time);
	
	//end initialize 20-sim
	
	//variables for avalon communication
	int32_t nReadOut = 0;
	uint16_t stepCount0 = 0;
	uint16_t stepCount1 = 0;
	uint16_t stepCount0Old = 0;
	uint16_t stepCount1Old = 0;
	int8_t PWM0 = 0;
	int8_t PWM1 = 0;
	int32_t avalondSend = 0;
	while( (xx_stop_simulation == XXFALSE) ) {

		//avalon bus communication
		nReadOut = IORD(ESL_NIOS_II_IP_0_BASE, 0x00);
		unsigned int readID = nReadOut >> 29;
		nReadOut = nReadOut << 3;
		switch (readID)​{
			case 1:
				stepCount0 = nReadOut >> (32-11);
				int32_t temp32 = 0;
				temp32 = nReadOut << 11;
				stepCount1 = temp32 >> (32-11);
				break;
			case 2:
				maxStepCount0 = nReadOut >> (32-11);
				int32_t temp32 = 0;
				temp32 = nReadOut << 11;
				maxStepCount1 = temp32 >> (32-11);
				break;
			default:
				// default statements
		}
		
		
		

		if(stepCount0 != stepCount0Old || stepCount1 != stepCount1Old)
			printf("stepCount0: %d\t stepCount1: %d \n\r", stepCount0, stepCount1);
		
		//generate inputs
		u[1] = 0;
		if(xx_time >= 1){
			u[1] = 0.5*pi;

		}
		if(xx_time >= 5){
			u[1] = 1.5*pi;

		}
		if(xx_time >= 10){
			u[1] = 0.5*pi;

		}
		
		
		/* Call the 20-sim submodel to calculate the output */
		u[2] = Stepcount0ToSI(stepCount0);
		double temp = y[0];
		
		printf("%f\n",temp);

		XXCalculateSubmodel (&u, &y, xx_time);
		PWM0 = y[0]*20;
		int16_t temp16 = 0;
		avalondSend = PWM0 << 24 | PWM1 <<16 | temp16;
		//printf("%x\n",avalondSend);
		IOWR(ESL_NIOS_II_IP_0_BASE, 0x00,avalondSend);
		
		if(!EmptyUart0()){
			ch = GetUart0();
			printf("received message: %c\n",ch);
			PutUart0(ch);
			PutUart0('\r');
			PutUart0('\n');
			
			
		}
		
		stepCount0Old = stepCount0;
		stepCount1Old = stepCount1;
		xx_time+=0.003;
	} 

	/* Perform the final 20-sim calculations */
	XXTerminateSubmodel (&u, &y, xx_time);

return 0;

}
