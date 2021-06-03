//-----------------------------------------------------------------------------
//Description : Uart Interrupt Handler & Q Buffer For NiosII
//Vision : V1.0
//Filename : UartMain.c 
// Copyright 2006, Cheong Min LEE
// Email: lcm2559@yahoo.co.kr
// The test may be run in NiosII standalone mode
//-----------------------------------------------------------------------------
 
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <alt_types.h>
#include <io.h>
#include "system.h"
#include "sys/alt_irq.h"
#include "InterruptHandlerForUart.h"

#define BAUD_RATE_0 115200 
#define BAUD_RATE_1 115200 

void InitUart()
{
    int context_uart1,context_uart2;

    InitUart1(BAUD_RATE_0);
    InitUart2(BAUD_RATE_1); 

    alt_irq_register(UART1_IRQ,&context_uart1,IsrUart1 ); // install UART1 ISR
    alt_irq_register(UART2_IRQ,&context_uart2,IsrUart2 ); // install UART2 ISR

    alt_irq_enable (UART1_IRQ); 
    alt_irq_enable (UART2_IRQ); 
}


int main()
{
unsigned char ch;
printf("\n\nHello NiosII!!!!!\n"); 

InitUart();

while(1) {
    if(!EmptyUart1()) { 
        ch = GetUart1(); 
        PutUart2(ch);
    }
    if(!EmptyUart2()) { 
        ch = GetUart2(); 
        PutUart1(ch);
    }
} //while

return 0;

}

 

 