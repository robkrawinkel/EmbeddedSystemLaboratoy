/**
 * @file rt_gpmc_fpga.h
 * @brief Real-Time General Purpose Memory Controller driver for usage on the RaMStix board.
 * @author Jan Jaap Kempenaar, University of Twente
 * @addtogroup gpmc_fpga
 * @{
 * @addtogroup c_gpmc_fpga_userdriver GPMC userspace driver
 * @brief Userspace data definitions and read/write functions.
 * @{
 *
 * Userspace driver for usage with the Xenomai RTDM GPMC FPGA linux kernel module. The module supports both NATIVE and POSIX skin based on compiler flags.
 * During compilation the driver defaults to POSIX skin. In order to compile for NATIVE Xenomai skin add <code>-DXENO_NATIVE</code> to the compile flags.
 *
 * The GPMC kernel module uses a 16-bit register alignment when reading or writing data.
 * When using a 32-bit read or write action, the lower register contains the least significant bytes.
 * For example, when writing the following 32-bit hexadecimal value: 0x55667788 with an offset of 1, it will result in the following
 * data contents of the registers:
 *
 * offset   |   content
 * ---------|----------
 * 0        | 0x0000 (not set)
 * 1        | 0x7788
 * 2        | 0x5566
 * 3        | 0x0000 (not set)
 *
 * See also the following code example:
 * @code
// System files
#include <stdio.h>

// Driver files.
#include "rt_gpmc_fpga.h"

int main(int argc, char* argv[])
{
    // Open real-time device.
    int fd = openGPMCFPGA();
    // Validate.
    if (0 < fd) {
        printf("error");
        return 1;
    }
    // Write value 0xaabbccdd to offset 1:
    writeGPMCFPGA32(fd, 1, 0x55667788);
    // Read values back with 16-bit actions.
    printf("Reg 1: %x, Reg 2: %x\n, readGPMCFPGA16(fd, 1), readGPMCFPGA16(fd, 2));
    // Should print: "Reg 1: 7788, Reg 2: 5566"
    close(fd);
    return 0;
}
 * @endcode
 */ 

#ifndef _RT_GPMC_FPGA_H_
#define _RT_GPMC_FPGA_H_

// System files:
#include <linux/fs.h>

#ifdef __XENO__ // only include if compiling for Xenomai
#include <rtdm/rtdm.h>
#endif

#ifndef __XENO__
#undef XENO_NATIVE
#endif

#if !defined(XENO_NATIVE) && !defined(__KERNEL__)// Only required for POSIX.
// include posix ioctl.
#include <sys/ioctl.h>
#include <unistd.h>
#endif

/**
 * Device detail definitions.
 */
#define DEVICE_NAME_RT      "rt_gpmc_fpga"  ///< Driver device name for real-time module
#define DEVICE_NAME_NRT     "gpmc_fpga"     ///< Driver device name for normal module.
#define GPMC_FPGA_MAJOR     0               ///< Device major number. (note leave 0, other /dev/ file not created.)
/**
 * @brief basic structure GPMC FPGA data structure.
 */
struct gpmc_fpga_data {
    unsigned int offset;    ///< Register offset value.
    unsigned int data;      ///< Data field.
};

/**
 * @brief Advanced structure for 64-bit reads.
 */
struct gpmc_fpga_data64 {
    unsigned int offset;            ///< Register offset value.
    union {
        unsigned short shorts[4];   ///< 2-byte short values.
        unsigned int ints[2];       ///< 4-byte integer values.
        unsigned long longval;      ///< 8-byte long value.
    } data;                         ///< Data components.
};

#define IOCTL_SET_U16  _IOW(GPMC_FPGA_MAJOR, 0, struct gpmc_fpga_data)      ///< 16-bit read action id
#define IOCTL_GET_U16 _IOWR(GPMC_FPGA_MAJOR, 1, struct gpmc_fpga_data)      ///< 16-bit write action id
#define IOCTL_SET_U32  _IOW(GPMC_FPGA_MAJOR, 2, struct gpmc_fpga_data)      ///< 32-bit read action id
#define IOCTL_GET_U32 _IOWR(GPMC_FPGA_MAJOR, 3, struct gpmc_fpga_data)      ///< 32-bit write action id
#define IOCTL_SET_U64  _IOW(GPMC_FPGA_MAJOR, 4, struct gpmc_fpga_data64)    ///< 64-bit read action id
#define IOCTL_GET_U64 _IOWR(GPMC_FPGA_MAJOR, 5, struct gpmc_fpga_data64)    ///< 64-bit unused write action. Maybe for future use on 64-bit architectures.

#endif // _RT_GPMC_FPGA_H_

/**
 * @}
 * @}
 */
