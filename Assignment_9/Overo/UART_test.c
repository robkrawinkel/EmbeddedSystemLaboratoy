#include <stdio.h>
#include <string.h>
#include <fcntl.h>      // open()
#include <unistd.h>     // close()
#include <stdint.h>

#define device_name "/dev/ttyO0"

int main(){
	int fd; // File descriptor.

	printf("UART c-example\n");

	fd = open(device_name, O_RDWR | O_NOCTTY | O_NDELAY);
	if (0 > fd)
	{
		printf("Error, could not open device: %s.\n", argv[1]);
		return 1;
	}

	// define the (16-bit) variable to send/receive
	unsigned short value = 100;


	// write the value to idx 2
	// int idx = 2;
	//ioctl(fd, IOCTL_SET_U16, &value);
	//printf("Set value of %i\n", value);  
	
	n = write(fd, "ATZ\r", 4);
	if (n < 0)
		fputs("write() of 4 bytes failed!\n", stderr);

	// read the value back from idx 0
	// idx = 2;
	ioctl(fd, IOCTL_GET_U16, &value);
	printf("read back : %i from idx %d\n", value, idx);


	printf("Exiting...\n");
	// close connection to free resources.
	close(fd);
	return 0;
}
