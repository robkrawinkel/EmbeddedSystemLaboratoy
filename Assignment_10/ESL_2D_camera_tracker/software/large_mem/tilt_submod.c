/**********************************************************
 * This file is generated by 20-sim ANSI-C Code Generator
 *
 *  file:  xxsubmod.c
 *  subm:  PositionControllerTilt
 *  model: PositionControllerTilt
 *  expmt: Jiwy
 *  date:  June 11, 2021
 *  time:  3:58:29 PM
 *  user:  20-sim 4.8 Campus License
 *  from:  Universiteit Twente
 *  build: 4.8.3.10415
 **********************************************************/

/* Standard include files */
#include <stdlib.h>

/* 20-sim include files */
#include "tilt_model.h"
#include "tilt_integ.h"
//#include "pan_funcs.h"
#include "tilt_submod.h"

/* The submodel I/O variables */
int tilt_number_of_inputs = 3;
int tilt_number_of_outputs = 1;

/* the names of the submodel io variables
   uncomment this part if you need these names
XXString xx_input_names[] = {
	"corr",
	"in",
	"position"
,	NULL
};
XXString xx_output_names[] = {
	"out"
,	NULL
};
*/
/* This function sets the input variables from the input vector */
void tilt_CopyInputsToVariables (double *u)
{
	/* Copy the input vector to the input variables */
	tilt_V[8] = u[0];		/* corr */
	tilt_V[9] = u[1];		/* in */
	tilt_V[10] = u[2];		/* position */

}

/* This function uses the output variables to fill the output vector */
void tilt_CopyVariablesToOutputs (double *y)
{
	/* Copy the output variables to the output vector */
	y[0] = 	tilt_V[11];		/* out */

}

/* The initialization function for submodel */
void tilt_InitializeSubmodel (double *u, double *y, double t)
{
	/* Initialization phase (allocating memory) */
	tilt_initialize = 1;
	tilt_steps = 0;
	tilt_ModelInitialize ();
	tilt_DiscreteInitialize ();

	/* Copy the inputs */
	tilt_time = t;
	tilt_CopyInputsToVariables (u);

	/* Calculate the model for the first time */
	tilt_CalculateDynamic ();
	tilt_CalculateOutput ();

	/* Set the outputs */
	tilt_CopyVariablesToOutputs (y);

	/* End of initialization phase */
	tilt_initialize = 0;
}

/* The function that calculates the submodel */
void tilt_CalculateSubmodel (double *u, double *y, double t)
{
	/* Copy the inputs */
	tilt_time = t;
	tilt_CopyInputsToVariables (u);

	/* Calculate the model */
	tilt_DiscreteStep ();
	tilt_CalculateOutput ();

	/* Copy the outputs */
	tilt_CopyVariablesToOutputs (y);
}

/* The termination function for submodel */
void tilt_TerminateSubmodel (double *u, double *y, double t)
{
	/* Copy the inputs */
	tilt_time = t;
	tilt_CopyInputsToVariables (u);

	/* Set the outputs */
	tilt_CopyVariablesToOutputs (y);
}

