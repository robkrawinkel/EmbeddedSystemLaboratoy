//-----------------------------------------------------------------------------
//
// 
//
//-----------------------------------------------------------------------------

//standard packages
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include <io.h>
#include "system.h"

//uart packages
//#include <alt_types.h>
#include "sys/alt_irq.h"
#include "InterruptHandlerForUart.h"
#include "sys/alt_stdio.h"

//avalon packages
#include "altera_avalon_uart_regs.h"
#include "altera_avalon_uart.h"
#include "altera_avalon_uart_fd.h"


//defines
#define BAUD_RATE_0 115200
#define pi 3.1415
#define maxPWMPan 70
#define maxPWMTilt 30


/* 20-sim include files */
#include "pan_submod.h"
#include "tilt_submod.h"


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
	double pan_u [3 + 1];
	double pan_y [1 + 1];
	double tilt_u[3 + 1];
	double tilt_y[1 + 1];
	int messageID = 2; //three different messages are received over UART, this counts them
	int panAngle;
	int tiltAngle;
	
	
	/* Initialize the inputs and outputs with correct initial values */
	pan_u[0] = 0.0;		/* corr */
	pan_u[1] = 0.0;		/* in */
	pan_u[2] = 0.0;		/* position */

	pan_y[0] = 0.0;		/* out */
	
	tilt_u[0] = 0.0;		/* corr */
	tilt_u[1] = 0.0;		/* in */
	tilt_u[2] = 0.0;		/* position */

	tilt_y[0] = 0.0;		/* out */




	/* Initialize the submodel itself */
	pan_InitializeSubmodel (&pan_u, &pan_y, pan_time);
	tilt_InitializeSubmodel(&tilt_u, &tilt_y, pan_time);
	
	//reset calibration
	IOWR(ESL_NIOS_II_IP_0_BASE, 0x00,0b00000000000000001000000000000000);
	IOWR(ESL_NIOS_II_IP_0_BASE, 0x00,0b00000000000000000000000000000000);
	
	
	//variables
	uint32_t nReadOut = 0;
	uint16_t stepCount0 = 0;
	uint16_t stepCount1 = 0;
	uint16_t stepCount0Old = 0;
	uint16_t stepCount1Old = 0;
	int8_t PWM0 = 0;
	int8_t PWM1 = 0;
	uint32_t avalondSend = 0;
	while( (pan_stop_simulation == 0) ) {

		//avalon bus communication
		nReadOut = IORD(ESL_NIOS_II_IP_0_BASE, 0x00);
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
		
		
		//receive UART data as input
		if(!EmptyUart0()){
			ch = GetUart0();
			printf("received message: %c\n",ch);
			//PutUart0(ch);
			switch(messageID){
				case 0: //set pan
					panAngle = (int)ch;						
					messageID++;
					break;
				case 1: //set tilt
					tiltAngle = (int)ch;						
					messageID++;
					break;
				default: //line break
					if(ch == '\n'){
						messageID = 0;
						
						//check if an object is detected
						if (panAngle != -128 || tiltAngle != -128){
							pan_u[0] += panAngle/360*2*pi;
							tilt_u[0] += tiltAngle/360*2*pi;
						}
					}
				}
			
		}
		
		//generate inputs
		pan_u[1] = 0;
		if(pan_time >= 1){
			pan_u[1] = 0.5*pi;

		}
		if(pan_time >= 5){
			pan_u[1] = 1.5*pi;

		}
		if(pan_time >= 10){

			pan_u[1] = 0.5*pi;

		}
		
		tilt_u[1] = pan_u[1];

		
		/* Call the 20-sim submodel to calculate the output */
		pan_u[2] = Stepcount0ToSI(stepCount0);
		tilt_u[2] = Stepcount1ToSI(stepCount1);

		pan_CalculateSubmodel (&pan_u, &pan_y, pan_time);
		tilt_CalculateSubmodel(&tilt_u, &tilt_y,pan_time);
		PWM0 = pan_y[0]*maxPWMPan;
		PWM1 = tilt_y[0]*maxPWMTilt;
		int16_t temp16 = 0;
		avalondSend = PWM0 << 24 | PWM1 <<16 | temp16;
		//printf("%x\n",avalondSend);
		IOWR(ESL_NIOS_II_IP_0_BASE, 0x00,avalondSend);
		

		
		stepCount0Old = stepCount0;
		stepCount1Old = stepCount1;
		pan_time+=0.0013;
	} 

	/* Perform the final 20-sim calculations */
	pan_TerminateSubmodel (&pan_u, &pan_y, pan_time);
	tilt_TerminateSubmodel(&tilt_u,&tilt_y,pan_time);

return 0;

}
