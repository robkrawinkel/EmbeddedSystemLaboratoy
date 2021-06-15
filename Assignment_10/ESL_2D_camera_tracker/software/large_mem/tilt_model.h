/**********************************************************
 * This file is generated by 20-sim ANSI-C Code Generator
 *
 *  file:  xxmodel.h
 *  subm:  PositionControllerTilt
 *  model: PositionControllerTilt
 *  expmt: Jiwy
 *  date:  June 11, 2021
 *  time:  3:58:29 PM
 *  user:  20-sim 4.8 Campus License
 *  from:  Universiteit Twente
 *  build: 4.8.3.10415
 **********************************************************/

/* This file describes the model functions
   that are supplied for computation.

   The model itself is the xxmodel.c file
*/

#ifndef tilt_MODEL_H
#define tilt_MODEL_H



/* Simulation variables */
extern double tilt_start_time;
extern double tilt_finish_time;
extern double tilt_step_size;
extern double tilt_time;
extern int tilt_steps;
extern char tilt_initialize;
extern char tilt_major;
extern char tilt_stop_simulation;

/* Model size constants */
#define tilt_constants_size 0
#define tilt_parameters_size 7
#define tilt_initialvalues_size 3
#define tilt_variables_size 12
#define tilt_states_size 3

/* Variable arrays */
extern double tilt_P[];
extern double tilt_I[];
extern double tilt_V[];
extern double tilt_s[];
extern double tilt_R[];


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
void tilt_ModelInitialize (void);
/* Initialize specific model values */
void tilt_ModelInitialize_parameters(void);
void tilt_ModelInitialize_initialvalues(void);
void tilt_ModelInitialize_states(void);
void tilt_ModelInitialize_variables(void);

/* Computation methods */
void tilt_CalculateDynamic (void);
void tilt_CalculateOutput (void);


#endif

