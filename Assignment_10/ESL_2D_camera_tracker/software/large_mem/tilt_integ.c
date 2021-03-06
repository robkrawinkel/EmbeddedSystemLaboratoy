/**********************************************************
 * This file is generated by 20-sim ANSI-C Code Generator
 *
 *  file:  xxinteg.c
 *  subm:  PositionControllerTilt
 *  model: PositionControllerTilt
 *  expmt: Jiwy
 *  date:  June 11, 2021
 *  time:  3:58:29 PM
 *  user:  20-sim 4.8 Campus License
 *  from:  Universiteit Twente
 *  build: 4.8.3.10415
 **********************************************************/

/* This file describes the integration methods
   that are supplied for computation.

   Currently the following methods are supported:
   * Euler
   * RungeKutta2
   * RungeKutta4
   but it is easy for the user to add their own
   integration methods with these two as an example.
*/

/* the system include files */
#include <stdlib.h>
#include <string.h>
#include <math.h>

/* our own include files */
#include "tilt_integ.h"
#include "tilt_model.h"

/* global variables prototypes */
extern double tilt_time;
extern double tilt_step_size;

#define tilt_STATE_SIZE 3

/*********************************************************************
 * Discrete integration method
 *********************************************************************/

/* the initialization of the Discrete integration method */
void tilt_DiscreteInitialize (void)
{
	/* nothing to be done */
	tilt_major = 1;
}

/* the Discrete integration method itself */
void tilt_DiscreteStep (void)
{
	int index;

	/* for each of the supplied states */
	for (index = 0; index < tilt_STATE_SIZE; index++)
	{
		/* just a move of the new state */
		tilt_s [index] = tilt_R [index];
	}
	/* increment the simulation time */
	tilt_time += tilt_step_size;

	tilt_major = 1;

	/* evaluate the dynamic part to calculate the new rates */
	tilt_CalculateDynamic ();
}

