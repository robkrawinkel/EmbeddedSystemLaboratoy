//-----------------------------------------------------------------------------
// Description : Uart Interrupt Handler & Q Buffer For NiosII
// Vision : V1.0
// Filename : InterruptHandlerForUart.h 
// Copyright 2006, Cheong Min LEE
// Email: lcm2559@yahoo.co.kr
// The test may be run in NiosII standalone mode
//-----------------------------------------------------------------------------
 
#ifndef _INTERRUPTHANDLERFORUART_H_
#define _INTERRUPTHANDLERFORUART_H_
 
/************************************************** ***************************
* Public function prototypes
************************************************** **************************/
void InitUart0(unsigned int BaudRate);

void IsrUart0();

unsigned char EmptyUart0();

unsigned char GetUart0(void);

unsigned char PutUart0(unsigned char in_char);

 
#endif //_INTERRUPTHANDLERFORUART_H_