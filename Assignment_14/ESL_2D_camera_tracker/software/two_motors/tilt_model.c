/**********************************************************
 * This file is generated by 20-sim ANSI-C Code Generator
 *
 *  file:  xxmodel.c
 *  model: PositionControllerTilt
 *  expmt: Jiwy
 *  date:  June 11, 2021
 *  time:  3:58:29 PM
 *  user:  20-sim 4.8 Campus License
 *  from:  Universiteit Twente
 *  build: 4.8.3.10415
 **********************************************************/

/* This file contains the actual model variables and equations */

/* Note: Alias variables are the result of full optimization
   of the model in 20-sim. As a result, only the real variables
   are used in the model for speed. The user may also include
   the alias variables by adding them to the end of the array:

   double tilt_variables[NUMBER_VARIABLES + NUMBER_ALIAS_VARIABLES + 1];
   XXString tilt_variable_names[] = {
     VARIABLE_NAMES, ALIAS_VARIABLE_NAMES, NULL
   };

   and calculate them directly after the output equations:

   void XXCalculateOutput (void)
   {
     OUTPUT_EQUATIONS
     ALIAS_EQUATIONS
   }
*/

/* system include files */
#include <stdlib.h>
#include <math.h>
#include <string.h>

/* 20-sim include files */
#include "tilt_model.h"
//#include "pan_funcs.h"

/* the global variables */
double tilt_start_time = 0.0;
double tilt_finish_time = 20.0;
double tilt_step_size = 0.01;
double tilt_time = 0.0;
int tilt_steps = 0;
char tilt_initialize = 1;
char tilt_major = 1;
char tilt_stop_simulation = 0;

/* the variable arrays */
double tilt_P[tilt_parameters_size];		/* parameters */
double tilt_I[tilt_initialvalues_size];		/* initial values */
double tilt_V[tilt_variables_size];		/* variables */
double tilt_s[tilt_states_size];		/* states */
double tilt_R[tilt_states_size];		/* rates (or new states) */

/* the names of the variables as used in the arrays above
   uncomment this part if these names are needed
XXString tilt_parameter_names[] = {
	"corrGain\\K",
	"PID1\\kp",
	"PID1\\tauD",
	"PID1\\beta",
	"PID1\\tauI",
	"SignalLimiter2\\minimum",
	"SignalLimiter2\\maximum"
,	NULL
};
XXString tilt_initial_value_names[] = {
	"PID1\\uD_previous_initial",
	"PID1\\error_previous_initial",
	"PID1\\uI_previous_initial"
,	NULL
};
XXString tilt_variable_names[] = {
	"corrGain\\input",
	"corrGain\\output",
	"PID1\\output",
	"",
	"PlusMinus1\\output",
	"PlusMinus2\\plus1",
	"PlusMinus2\\minus1",
	"SignalLimiter2\\output",
	"corr",
	"in",
	"position",
	"out"
,	NULL
};
XXString tilt_state_names[] = {
	"PID1\\uD_previous",
	"PID1\\error_previous",
	"PID1\\uI_previous"
,	NULL
};
XXString tilt_rate_names[] = {
	"",
	"PID1\\error",
	""
,	NULL
};
*/

#if (7 > 8192) && defined _MSC_VER
#pragma optimize("", off)
#endif
void tilt_ModelInitialize_parameters(void)
{
	/* set the parameters */
	tilt_P[0] = 0.0;		/* corrGain\K */
	tilt_P[1] = 1.6;		/* PID1\kp */
	tilt_P[2] = 0.05;		/* PID1\tauD */
	tilt_P[3] = 0.001;		/* PID1\beta */
	tilt_P[4] = 10.5;		/* PID1\tauI */
	tilt_P[5] = -0.99;		/* SignalLimiter2\minimum */
	tilt_P[6] = 0.99;		/* SignalLimiter2\maximum */

}
#if (7 > 8192) && defined _MSC_VER
#pragma optimize("", on)
#endif

void tilt_ModelInitialize_initialvalues(void)
{
	/* set the initial values */
	tilt_I[0] = 0.0;		/* PID1\uD_previous_initial */
	tilt_I[1] = 0.0;		/* PID1\error_previous_initial */
	tilt_I[2] = 0.0;		/* PID1\uI_previous_initial */

}

void tilt_ModelInitialize_states(void)
{
	/* set the states */
	tilt_s[0] = tilt_I[0];		/* PID1\uD_previous */
	tilt_s[1] = tilt_I[1];		/* PID1\error_previous */
	tilt_s[2] = tilt_I[2];		/* PID1\uI_previous */

}

void tilt_ModelInitialize_variables(void)
{
	/* initialize the variable memory to zero */
	memset(tilt_V, 0, tilt_variables_size * sizeof(double));
}

/* this method is called before calculation is possible */
void tilt_ModelInitialize (void)
{
	tilt_ModelInitialize_parameters();
	tilt_ModelInitialize_variables();
	tilt_ModelInitialize_initialvalues();
	tilt_ModelInitialize_states();
}

/* This function calculates the dynamic equations of the model.
 * These equations are called from the integration method
 * to calculate the new model rates (that are then integrated).
 */
void tilt_CalculateDynamic (void)
{
	/* PID1\factor = 1 / (sampletime + PID1\tauD * PID1\beta); */
	tilt_V[3] = 1.0 / (tilt_step_size + tilt_P[2] * tilt_P[3]);

	/* corrGain\input = corr; */
	tilt_V[0] = tilt_V[8];

	/* PlusMinus2\plus1 = in; */
	tilt_V[5] = tilt_V[9];

	/* PlusMinus2\minus1 = position; */
	tilt_V[6] = tilt_V[10];

	/* corrGain\output = corrGain\K * corrGain\input; */
	tilt_V[1] = tilt_P[0] * tilt_V[0];

	/* PID1\error = PlusMinus2\plus1 - PlusMinus2\minus1; */
	tilt_R[1] = tilt_V[5] - tilt_V[6];

	/* PID1\uD = PID1\factor * (((PID1\tauD * PID1\uD_previous) * PID1\beta + (PID1\tauD * PID1\kp) * (PID1\error - PID1\error_previous)) + (sampletime * PID1\kp) * PID1\error); */
	tilt_R[0] = tilt_V[3] * (((tilt_P[2] * tilt_s[0]) * tilt_P[3] + (tilt_P[2] * tilt_P[1]) * (tilt_R[1] - tilt_s[1])) + (tilt_step_size * tilt_P[1]) * tilt_R[1]);

	/* PID1\uI = PID1\uI_previous + (sampletime * PID1\uD) / PID1\tauI; */
	tilt_R[2] = tilt_s[2] + (tilt_step_size * tilt_R[0]) / tilt_P[4];

	/* PID1\output = PID1\uI + PID1\uD; */
	tilt_V[2] = tilt_R[2] + tilt_R[0];

	/* PlusMinus1\output = corrGain\output + PID1\output; */
	tilt_V[4] = tilt_V[1] + tilt_V[2];

	/* SignalLimiter2\output = (if PlusMinus1\output < SignalLimiter2\minimum then SignalLimiter2\minimum else (if PlusMinus1\output > SignalLimiter2\maximum then SignalLimiter2\maximum else PlusMinus1\output end) end); */
	tilt_V[7] = ((tilt_V[4] < tilt_P[5]) ? 
		/* SignalLimiter2\minimum */
		tilt_P[5]
	:
		/* (if PlusMinus1\output > SignalLimiter2\maximum then SignalLimiter2\maximum else PlusMinus1\output end) */
		((tilt_V[4] > tilt_P[6]) ? 
			/* SignalLimiter2\maximum */
			tilt_P[6]
		:
			/* PlusMinus1\output */
			tilt_V[4]
		)
	);


	/* increment the step counter */
	tilt_steps++;
}

/* This function calculates the output equations of the model.
 * These equations are not needed for calculation of the rates
 * and are kept separate to make the dynamic set of equations smaller.
 * These dynamic equations are called often more than one time for each
 * integration step that is taken. This makes model computation much faster.
 */
void tilt_CalculateOutput (void)
{
	/* out = SignalLimiter2\output; */
	tilt_V[11] = tilt_V[7];

}


