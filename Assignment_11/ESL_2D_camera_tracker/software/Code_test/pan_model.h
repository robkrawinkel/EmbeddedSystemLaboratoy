/**********************************************************
 * This file is generated by 20-sim ANSI-C Code Generator
 *
 *  file:  xxmodel.h
 *  subm:  PositionControllerPan
 *  model: PositionControllerPan
 *  expmt: Jiwy
 *  date:  June 11, 2021
 *  time:  3:58:16 PM
 *  user:  20-sim 4.8 Campus License
 *  from:  Universiteit Twente
 *  build: 4.8.3.10415
 **********************************************************/

/* This file describes the model functions
   that are supplied for computation.

   The model itself is the xxmodel.c file
*/

#ifndef pan_MODEL_H
#define pan_MODEL_H

/* Our own include files */
//#include "xxtypes.h"

/* Simulation variables */
extern double pan_start_time;
extern double pan_finish_time;
extern double pan_step_size;
extern double pan_time;
extern int pan_steps;
extern char pan_initialize;
extern char pan_major;
extern char pan_stop_simulation;

/* Model size constants */
#define pan_constants_size 0
#define pan_parameters_size 7
#define pan_initialvalues_size 3
#define pan_variables_size 10
#define pan_states_size 3

/* Variable arrays */
extern double pan_P[];
extern double pan_I[];
extern double pan_V[];
extern double pan_s[];
extern double pan_R[];


/* The names of the variables as used in the arrays above
   uncomment this if you need the names (see source file too)
extern XXString xx_parameter_names[];
extern XXString xx_initial_value_names[];
extern XXString xx_variable_names[];
extern XXString xx_state_names[];
extern XXString xx_rate_names[];
*/

/* Initialization methods */
/* Initialize complete model */
void pan_ModelInitialize (void);
/* Initialize specific model values */
void pan_ModelInitialize_parameters(void);
void pan_ModelInitialize_initialvalues(void);
void pan_ModelInitialize_states(void);
void pan_ModelInitialize_variables(void);

/* Computation methods */
void pan_CalculateDynamic (void);
void pan_CalculateOutput (void);


#endif

