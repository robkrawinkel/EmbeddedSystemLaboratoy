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

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>

#include <io.h>
#include "system.h"

int main()
{
	// Say hello through the debug interface
	printf("Hello from Nios II!\n");

	// Put 0x08 in the memory of the IP and enable the count down
	// IOWR(ESL_BUS_DEMO_0_BASE, 0x00, 1 << 31 | 0x08);

	// Verify that it is there

	int32_t nReadOut = 0;
	int16_t stepCount0 = 0;
	int16_t stepCount1 = 0;

	// Now loop forever ...
	while(1){
		nReadOut = IORD(ESL_BUS_DEMO_0_BASE, 0x00);

		stepCount0 = nReadOut >> 16;
		stepCount1 = nReadOut & 0x0000FFFF;

		//printf("%x \n\r", nReadOut);
		printf("stepCount0: %d\t stepCount1: %d \n\r", stepCount0, stepCount1);
	}

	return 0;
}
