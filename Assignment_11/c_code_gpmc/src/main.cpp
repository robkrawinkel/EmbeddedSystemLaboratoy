/**
 * @file example.cpp
 * @brief cpp example file.
 * @uathor Jan Jaap Kempenaar, University of Twente.
 */

 
#include <iostream>
#include "gpmc_driver_cpp.h"

//20-sim
#include <stdio.h>

/* 20-sim submodel class include file */
#include "PositionControllerTilt.h"
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
int main(int argc, char* argv[])
{
  if (2 != argc)
  {
    std::cout << "Usage: " << argv[0] << " <device_name>" << std::endl;
    return 1;
  }
  
  std::cout << "GPMC driver cpp-example" << std::endl;
  // Create GPMC device driver object
  std::cout << "Opening gpmc_fpga..." << std::endl;
  gpmc_driver Device(argv[1]);
  
  if (!Device.isValid())
  {
    std::cerr << "Error opening gpmc_fpga device: %s" << std::endl;
    return 1;
  }
  // define the (16-bit) variable to send/receive
  unsigned short value0 = 100;
  unsigned short value1 = 100;
  
  	XXDouble u [3 + 1];
	XXDouble y [1 + 1];

	/* initialize the inputs and outputs with correct initial values */
	u[0] = 0.0;		/* corr */
	u[1] = 0.0;		/* in */
	u[2] = 0.0;		/* position */

	y[0] = 0.0;		/* out */


	PositionControllerTilt my20simSubmodel;

	/* initialize the submodel itself and calculate the outputs for t=0.0 */
	my20simSubmodel.Initialize(u, y, 0.0);
	printf("Time: %f\n", my20simSubmodel.GetTime() );

	
	//variables for GPMC communication
	uint32_t nReadOut = 0;
	uint16_t stepCount0 = 0;
	uint16_t stepCount1 = 0;
	uint16_t stepCount0Old = 0;
	uint16_t stepCount1Old = 0;
	int8_t PWM0 = 0;
	int8_t PWM1 = 0;
	uint32_t avalondSend = 0;
	
	
	
	/* simple loop, the time is incremented by the integration method */
	while (my20simSubmodel.state != PositionControllerTilt::finished)
	{
		value0 = Device.getValue(0);
		value1 = Device.getValue(1);
		
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
		if(my20simSubmodel.GetTime() >= 1){
			u[1] = 0.5*pi;

		}
		if(my20simSubmodel.GetTime() >= 5){
			u[1] = 1.5*pi;

		}
		if(my20simSubmodel.GetTime() >= 10){

			u[1] = 0.5*pi;

		}
		
		
		/* Call the 20-sim submodel to calculate the output */
		u[2] = Stepcount0ToSI(stepCount0);
		double temp = y[0];
		
		/* call the submodel to calculate the output */
		my20simSubmodel.Calculate (u, y);
		printf("Time: %f\n", my20simSubmodel.GetTime() );
		
		PWM0 = y[0]*70;
		int16_t temp16 = 0;
		
		
		//send data back
		value0 = PWM0 << 8 || PWM1;
		value1 = temp16;
		setGPMCValue(fd, value0, 2);
		setGPMCValue(fd, value1, 3);
		
		stepCount0Old = stepCount0;
		stepCount1Old = stepCount1;
	}

	/* perform the final calculations */
	my20simSubmodel.Terminate (u, y);

	/* and we are done */
	return 0;
  
  
  
 
  
  std::cout << "Exiting..." << std::endl;
  return 0;
}
