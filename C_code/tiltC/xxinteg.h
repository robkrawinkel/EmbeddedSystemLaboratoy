/**********************************************************
 * This file is generated by 20-sim ANSI-C Code Generator
 *
 *  file:  xxinteg.h
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

#ifndef XX_INTEG_H
#define XX_INTEG_H

/* 20-sim include files */
#include "xxtypes.h"

/* the chosen integration method */
#define Discrete_METHOD

/* the integration methods */
void XXDiscreteInitialize (void);
void XXDiscreteTerminate (void);
void XXDiscreteStep (void);

extern XXBoolean xx_major;

#endif

