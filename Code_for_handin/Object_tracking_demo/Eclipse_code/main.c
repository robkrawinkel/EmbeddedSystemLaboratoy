//-----------------------------------------------------------------------------
// 
// ESL demo, accepting uart communication from the OVero fire for the required
// angle that needs to be reached by the motors.
// A simple proportional controller is used to turn the motors. The required PWM
// values are send to the FPGA over the avalon bus.
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

#define pi 3.1415926538

uint16_t maxStepCount0 = 1115;
uint16_t maxStepCount1 = 221;

void InitUart()
{
    int context_uart0;

    InitUart0(BAUD_RATE_0);

    alt_irq_register(UART_0_IRQ,&context_uart0,IsrUart0); // install UART0 ISR

    alt_irq_enable (UART_0_IRQ);
}

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

	//Force a recalibration of the quadrature encoders on the NIOS II FPGA side
	IOWR(ESL_NIOS_II_IP_0_BASE, 0x00,0b00000000000000001000000000000000);
	IOWR(ESL_NIOS_II_IP_0_BASE, 0x00,0b00000000000000000000000000000000);
	
	//initialize relevant communication
	InitUart();


	
	//Avalon communication variables
	uint32_t nReadOut = 0;
	uint32_t avalondSend = 0;
	
	//UART variables
	int8_t ch;
	int8_t messageID = 2;
	
	
	//quadrature encoder variables
	uint16_t stepCount0 = 0;
	uint16_t stepCount1 = 0;
	uint16_t stepCount0Old = 0;
	uint16_t stepCount1Old = 0;
	int8_t panAngle = 0;
	int8_t tiltAngle = 0;
	
	//motor driver variables
	int8_t PWM0 = 0;
	int8_t PWM1 = 0;
	int8_t PID_counter = 0;	

	
	while(1) {

		//avalon bus communication
		nReadOut = IORD(ESL_NIOS_II_IP_0_BASE, 0x00);
		uint8_t readID = nReadOut >> 29;
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
		
		//reset the PWM values to 0 after 50 cycles, to prevent the motor from running if no data is received
		if(PID_counter++ > 50){
			PWM0 = 0;
			PWM1 = 0;
			PID_counter = 0;
		}
		
		//receive UART data as input
		if(!EmptyUart0()){
			ch = GetUart0();
			//store sequential received messages as different variables
			switch(messageID){
				case 0: //set pan
					panAngle = ch;
					messageID++;
					break;
				case 1: //set tilt
					tiltAngle = ch;
					messageID++;
					break;
				default: //line break
					if(ch == '\n'){
						messageID = 0;
						//set the PWM values if an angle is received over the uart bus. Uses minimum values due to high resistances in the physical setup.
						if(panAngle != -128)
							PWM0 = -panAngle/2;
						if(tiltAngle != -128)
							PWM1 = -tiltAngle/20;
						if(PWM0 > 0 && PWM0 < 40)
							PWM0 = 40;
						if(PWM0 < 0 && PWM0 > -40)
							PWM0 = -40;
						if(PWM1 > 0 && PWM1 < 5)
							PWM1 = 5;
						if(PWM1 < 0 && PWM1 > -5)
							PWM1 = -5;
					}
					break;
				}

		}

		//send the PWM values over the avalon bus
		int16_t temp16 = 0;
		avalondSend = PWM0 << 24 | PWM1 <<16 | temp16;
		IOWR(ESL_NIOS_II_IP_0_BASE, 0x00,avalondSend);
		
		stepCount0Old = stepCount0;
		stepCount1Old = stepCount1;
	} 

	return 0;

}
