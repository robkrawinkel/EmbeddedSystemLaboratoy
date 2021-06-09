/**
 * @file gpmc_driver_c.c
 * @brief Implementation file.
 * @author Jan Jaap Kempenaar, Sander Grimm, University of Twente.
 */

#include "gpmc_driver_c.h"
#include "stdio.h"

// GPMC kernel module with definitions.
#include "rt_gpmc_user/rt_gpmc_fpga.h"

#include <fcntl.h>      // open()
#include <sys/ioctl.h>  // ioctl()
#include <unistd.h>     // close()

unsigned short getGPMCValue(int fd, int idx)
{
  // Read from specified address.
  struct gpmc_fpga_data temp;
  temp.offset = idx;
  ioctl(fd, IOCTL_GET_U16, &temp);
  return (short)temp.data;
}


void setGPMCValue(int fd, unsigned short value, int idx)
{
  // create data structure and fill with data.
  struct gpmc_fpga_data temp;
  temp.data = (int)value;
  temp.offset = idx;
  // Set value.
  ioctl(fd, IOCTL_SET_U16, &temp);
}
