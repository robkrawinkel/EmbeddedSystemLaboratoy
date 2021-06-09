/**********************************************************
 * This file is generated by 20-sim ANSI-C Code Generator
 *
 *  file:  xxmain.c
 *  subm:  PositionControllerTilt
 *  model: PositionControllerTilt
 *  expmt: Jiwy
 *  date:  June 3, 2021
 *  time:  10:13:42 AM
 *  user:  20-sim 4.8 Campus License
 *  from:  Universiteit Twente
 *  build: 4.8.3.10415
 **********************************************************/

/* This file is a demo application of how the submodel function can 
 * be used. It uses the global time variables that are used by both
 * the submodel and the integration method.
 *
 * PLEASE NOTE: THIS IS AN EXAMPLE WHERE ALL INPUTS ARE ZERO ! 
 * USE YOUR OWN INPUTS INSTEAD!! ALSO THE SUBMODEL MIGHT SIMPLY 
 * NOT WORK CORRECTLY WITH INPUTS THAT ARE ZERO.
 */

/* 20-sim include files */
#include "xxsubmod.h"

/*GPMC files*/
#include "stdio.h"
#include "gpmc_driver_c.h"

#include <fcntl.h>      // open()
#include <unistd.h>     // close()
#include <time.h>

/* The main function */
int main(int argc, char* argv[])
{
	if (2 != argc)
  {
    printf("Usage: %s <device_name>\n", argv[0]);
    return 1;
  }
  
	printf("GPMC driver combination with 20-sim");
	
	// open connection to device.
  printf("Opening gpmc_fpga...\n");
  fd = open(argv[1], 0);
  if (0 > fd)
  {
    printf("Error, could not open device: %s.\n", argv[1]);
    return 1;
  }
  
  // define the (16-bit) variable to send/receive
  unsigned short value0 = 100;
  unsigned short value1 = 100;
  
  /////////////////////  Start 20-sim model ///////////////////////
  
	XXDouble u [3 + 1];
	XXDouble y [1 + 1];

	/* Initialize the inputs and outputs with correct initial values */
	u[0] = 0.0;		/* corr */
	u[1] = 0.0;		/* in */
	u[2] = 0.0;		/* position */

	y[0] = 0.0;		/* out */


	/* Initialize the submodel itself */
	XXInitializeSubmodel (u, y, xx_time);
	
	//variables for GPMC communication
	uint32_t nReadOut = 0;
	uint16_t stepCount0 = 0;
	uint16_t stepCount1 = 0;
	uint16_t stepCount0Old = 0;
	uint16_t stepCount1Old = 0;
	int8_t PWM0 = 0;
	int8_t PWM1 = 0;
	uint32_t avalondSend = 0;

	/* Simple loop, the time is incremented by the integration method */
	while ( (xx_stop_simulation == XXFALSE) )
	{
		// receive data from idx 0 and 1
		value0 = getGPMCValue(fd, 0);
		value1 = getGPMCValue(fd,1);
		nReadOut = value0 << 16 || value1;
		
		unsigned int readID = nReadOut >> 29;
		nReadOut = nReadOut << 3;
		uint32_t temp32;

		switch(readID) {
			case 1:
				stepCount0 = nReadOut >> (32-11);

				temp32 = nReadOut << 11;
				stepCount1 = temp32 >> (32-11);
				break;
			case 2:
				maxStepCount0 = nReadOut >> (32-11);
				temp32 = nReadOut << 11;
				maxStepCount1 = temp32 >> (32-11);
				printf(".....................Received new calibration values!:\t");
				printf("stepCount0_max: %d\t stepCount1_max: %d \n\r", maxStepCount0, maxStepCount1);
				break;
			default:
				// default statements
				printf("Received incorrect message");
				break;
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
		
		/* Call the submodel to calculate the output */
		XXCalculateSubmodel (u, y, xx_time);
		PWM0 = y[0]*70;
		int16_t temp16 = 0;
		
		
		//send data back
		value0 = PWM0 << 8 || PWM1;
		value1 = temp16;
		setGPMCValue(fd, value0, 2);
		setGPMCValue(fd, value1, 3);
		
		stepCount0Old = stepCount0;
		stepCount1Old = stepCount1;
		xx_time+=0.0013;
	}

	/* Perform the final calculations */
	XXTerminateSubmodel (u, y, xx_time);
	
	printf("Exiting...\n");
	// close connection to free resources.
	close(fd);

	/* and we are done */
	return 0;
}

