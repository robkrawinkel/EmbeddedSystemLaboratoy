/**
 * @file example.c
 * @brief c example file.
 * @author Jan Jaap Kempenaar, Sander Grimm, University of Twente.
 */

#include "stdio.h"
#include "gpmc_driver_c.h"

#include <fcntl.h>      // open()
#include <unistd.h>     // close()
#include <time.h>

int main(int argc, char* argv[])
{
  int fd; // File descriptor.
  if (2 != argc)
  {
    printf("Usage: %s <device_name>\n", argv[0]);
    return 1;
  }
  
  printf("GPMC driver c-example\n");
  
  // open connection to device.
  printf("Opening gpmc_fpga...\n");
  fd = open(argv[1], 0);
  if (0 > fd)
  {
    printf("Error, could not open device: %s.\n", argv[1]);
    return 1;
  }
  
  // define the (16-bit) variable to send/receive
  unsigned short value = 100;

  
  // write the value to idx 2
  int idx = 2;
  setGPMCValue(fd, value, idx);
  printf("Set value of %i to idx %d.\n", value, idx);  

  // read the value back from idx 1
  idx = 1;
  value = getGPMCValue(fd, idx);
  printf("read back : %i from idx %d\n", value, idx);

  // read the value back from idx 0
  idx = 0;
  value = getGPMCValue(fd, idx);
  printf("read back : %i from idx %d\n", value, idx);

  long int startTime = 0;
  long int endTime = 0;

  startTime = time(0);
  for (int i = 0; i < 10000000; i++) {
    getGPMCValue(fd, idx);
  }
  endTime = time(0);
  printf("Read GPMC 10000000 times, took: %d s", endTime-startTime);

  printf("Exiting...\n");
  // close connection to free resources.
  close(fd);
  return 0;
}
