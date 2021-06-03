//-----------------------------------------------------------------------------
//Description : Uart Interrupt Handler & Q Buffer For NiosII
//Vision : V1.0
//Filename : InterruptHandlerForUart.h 
// Copyright 2006, Cheong Min LEE
// Email: lcm2559@yahoo.co.kr
// The test may be run in NiosII standalone mode
//-----------------------------------------------------------------------------
 
#ifndef _INTERRUPTHANDLERFORUAR_H_
#define _INTERRUPTHANDLERFORUAR_H_
 
/************************************************** ***************************
* Public function prototypes
************************************************** **************************/
void InitUart1(unsigned int BaudRate);
void InitUart2(unsigned int BaudRate);
void IsrUart1();
void IsrUart2();
unsigned char EmptyUart1();
unsigned char EmptyUart2();
unsigned char GetUart1(void);
unsigned char GetUart2(void);
unsigned char PutUart1(unsigned char in_char);
unsigned char PutUart2(unsigned char in_char);
 
#endif //_INTERRUPTHANDLERFORUAR_H_