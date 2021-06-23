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

#include "sys/alt_stdio.h"

#include "altera_avalon_uart_regs.h"
#include "altera_avalon_uart.h"
#include "altera_avalon_uart_fd.h"


/* 20-sim include files */
#include "xxsubmod.h"

#define pi 3.1415926538

uint16_t maxStepCount0 = 1115;
uint16_t maxStepCount1 = 221;

//function to convert the stepcount output of the FPGA encoder to radian degrees (for the pan motor)
double Stepcount0ToSI(int16_t steps)
{
	double stepsPerRotation = maxStepCount0/325*360;
	return steps/stepsPerRotation*2*pi;
}

//function to convert the stepcount output of the FPGA encoder to radian degrees (for the tilt motor)
double Stepcount1ToSI(int16_t steps)
{
	double stepsPerRotation = maxStepCount1/170*360;
	return steps/stepsPerRotation*2*pi;

}

int main()
{
	printf("\n\nHello NiosII!!!!!\n");
	
	//reset quadrature encoders on the FPGA
	IOWR(ESL_NIOS_II_IP_0_BASE, 0x00,0b00000000000000001000000000000000);
	IOWR(ESL_NIOS_II_IP_0_BASE, 0x00,0b00000000000000000000000000000000);

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
	uint32_t nReadOut = 0;
	uint32_t avalondSend = 0;
	
	//quadrature encoder variables
	uint16_t stepCount0 = 0;
	uint16_t stepCount1 = 0;
	uint16_t stepCount0Old = 0;
	uint16_t stepCount1Old = 0;
	
	//motor driver variables
	int8_t PWM0 = 0;
	int8_t PWM1 = 0;


	while( (xx_stop_simulation == XXFALSE) ) {

		//avalon bus communication
		nReadOut = IORD(ESL_NIOS_II_IP_0_BASE, 0x00);
		unsigned int readID = nReadOut >> 29;
		nReadOut = nReadOut << 3;
		uint32_t temp32;
		
		//differentiate between two different types of messages received, the maximum stepcount or current stepcount, using bitshifting
		switch(readID) {
			case 1://read current stepcount
				stepCount0 = nReadOut >> (32-11);
				temp32 = nReadOut << 11;
				stepCount1 = temp32 >> (32-11);
				break;
			case 2://read maximum stepcount
				maxStepCount0 = nReadOut >> (32-11);
				temp32 = nReadOut << 11;
				maxStepCount1 = temp32 >> (32-11);
				printf(".....................Received new calibration values!:\t");
				printf("stepCount0_max: %d\t stepCount1_max: %d \n\r", maxStepCount0, maxStepCount1);
				break;
			default:
				// incorrect message received
				printf("Received incorrect message");
				break;
		}
		
		
		//print updated stepcount for debugging
		if(stepCount0 != stepCount0Old || stepCount1 != stepCount1Old)
			printf("stepCount0: %d\t stepCount1: %d \n\r", stepCount0, stepCount1);
		
		
		//generate inputs, based on time
		u[1] = 0;
		if(xx_time >= 1){
			u[1] = 0.5*pi;
		}
		if(xx_time >= 15){
			u[1] = 1.5*pi;
		}
		if(xx_time >= 20){
			u[1] = 0.5*pi;
		}

		/* Call the 20-sim submodel to calculate the output */
		u[2] = Stepcount0ToSI(stepCount0);
		double temp = y[0];
		


		XXCalculateSubmodel (&u, &y, xx_time);
		//multiply the output by the maximum dutycycle
		PWM0 = y[0]*70;

		//send the PWM values over the avalon bus
		int16_t temp16 = 0;
		avalondSend = PWM0 << 24 | PWM1 <<16 | temp16;
		IOWR(ESL_NIOS_II_IP_0_BASE, 0x00,avalondSend);

		//update stepcounter and time
		stepCount0Old = stepCount0;
		stepCount1Old = stepCount1;
		xx_time+=0.0013;
	} 

	/* Perform the final 20-sim calculations */
	XXTerminateSubmodel (&u, &y, xx_time);

	return 0;

}
