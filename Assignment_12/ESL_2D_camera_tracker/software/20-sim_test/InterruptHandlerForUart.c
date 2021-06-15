#include "system.h"
#include "altera_avalon_uart_regs.h"
 
#define RX_BUFFER_SIZE_0 1024
#define TX_BUFFER_SIZE_0 1024
 
unsigned short TxHead_0=0; 
unsigned short TxTail_0=0;
unsigned char tx_buffer_0[TX_BUFFER_SIZE_0];
 
unsigned short RxHead_0=0;
unsigned short RxTail_0=0;
unsigned char rx_buffer_0[RX_BUFFER_SIZE_0];
 
void InitUart0(unsigned int BaudRate)
{
    unsigned int divisor;
    
    divisor = (ALT_CPU_FREQ/BaudRate) + 1;
    IOWR_ALTERA_AVALON_UART_DIVISOR(UART_0_BASE, divisor);
    IOWR_ALTERA_AVALON_UART_CONTROL(UART_0_BASE, ALTERA_AVALON_UART_CONTROL_RRDY_MSK);
}
 
void IsrUart0(void* context, unsigned int id)
{
    int sr;
    
    sr = IORD_ALTERA_AVALON_UART_STATUS(UART_0_BASE);

    if(sr & ALTERA_AVALON_UART_STATUS_RRDY_MSK) {
        rx_buffer_0[RxHead_0] = IORD_ALTERA_AVALON_UART_RXDATA(UART_0_BASE);
        IOWR_ALTERA_AVALON_UART_STATUS(UART_0_BASE, 0);
        if (++RxHead_0 > (RX_BUFFER_SIZE_0 - 1)) {
            RxHead_0 = 0;
        }
    }

    if(sr & ALTERA_AVALON_UART_STATUS_TRDY_MSK) {
        if(IORD_ALTERA_AVALON_UART_CONTROL(UART_0_BASE) & ALTERA_AVALON_UART_CONTROL_TRDY_MSK) {
            if (TxTail_0 != TxHead_0) {
                IOWR_ALTERA_AVALON_UART_TXDATA(UART_0_BASE, tx_buffer_0[TxTail_0]);
                if (++TxTail_0 > (TX_BUFFER_SIZE_0 - 1)) {
                    TxTail_0 = 0;
                }
            }
            else {
                IOWR_ALTERA_AVALON_UART_CONTROL(UART_0_BASE, ALTERA_AVALON_UART_CONTROL_RRDY_MSK);
            }
        }
    }
}
 
unsigned char EmptyUart0()
{
    if(RxHead_0 == RxTail_0) {
        return 1;
    }
    
    return 0;
} 
    
unsigned char GetUart0(void)
{
    unsigned char rxChar; 
    
    /* buffer is empty */
    
    rxChar=rx_buffer_0[RxTail_0];
    if (++RxTail_0 > (RX_BUFFER_SIZE_0 - 1)) {
        RxTail_0 = 0;
    }
    
    return rxChar;
}
 
unsigned char PutUart0(unsigned char in_char)
{
    unsigned short size;
    unsigned int z;
    
    z = IORD_ALTERA_AVALON_UART_STATUS(UART_0_BASE) & ALTERA_AVALON_UART_STATUS_TRDY_MSK;
    
    if ((TxHead_0==TxTail_0) && z) {
        IOWR_ALTERA_AVALON_UART_TXDATA(UART_0_BASE, in_char);
    } else {
        if (TxHead_0 >= TxTail_0) {
            size = TxHead_0 - TxTail_0;
        } else {
            size = ((TX_BUFFER_SIZE_0 - 1) - TxTail_0) + TxHead_0;
        }

        if (size > (TX_BUFFER_SIZE_0 - 3)) {
            return (-1);
        }
        
        tx_buffer_0[TxHead_0] = in_char;

        if (++TxHead_0 > (TX_BUFFER_SIZE_0-1)) {
            TxHead_0 = 0;
        }

        z = IORD_ALTERA_AVALON_UART_CONTROL(UART_0_BASE) | ALTERA_AVALON_UART_CONTROL_TRDY_MSK;
        IOWR_ALTERA_AVALON_UART_CONTROL(UART_0_BASE, z);
    }

    return(1);
}
