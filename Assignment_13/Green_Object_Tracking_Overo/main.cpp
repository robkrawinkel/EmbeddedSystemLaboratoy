#include <stdio.h>
#include <math.h>
#include <fcntl.h>      // Contains file controls like O_RDWR
#include <errno.h>      // Error integer and strerror() function
#include <termios.h>    // Contains POSIX terminal control definitions
#include <unistd.h>     // write(), read(), close()

#include <opencv2/opencv.hpp>

//#include "opencv2/opencv.hpp"
//#include "opencv2/highgui/highgui.hpp"
//#include "opencv2/imgproc/imgproc.hpp"


// Tweak the HSV values in that order:
//  Set the ranges to maximum for all, try to narrow H first, don't create black spots in the tracked object
//  Repeat for S and then V to find the ideal ranges

using namespace cv;
using namespace std;

// Set threshold values of the image to track the green phone screen
#define iLowH 35
#define iHighH 102

#define iLowS 131
#define iHighS 255

#define iLowV 0
#define iHighV 255

// Set the camera properties
#define viewAngleX 120  // FOV in degree
#define viewAngleY 120  // FOV in degree

// Set the UART properties
#define UART_device_name "/dev/ttyO0"
#define UART_bus_speed B115200

int main( int argc, char** argv )
{
    // ------------------------------------------------------------- UART setup
    // From: https://blog.mbedded.ninja/programming/operating-systems/linux/linux-serial-ports-using-c-cpp/
    int UART_port = open(UART_device_name, O_RDWR);
    
    struct termios tty;

    // Get the current UART settings
    if(tcgetattr(UART_port, &tty) != 0) {
        printf("Error %i from tcgetattr: %s\n", errno, strerror(errno));
    }

    // // Set the UART settings
    // tty.c_cflag &= ~PARENB;         // Clear parity bit, disabling parity (most common)
    // tty.c_cflag &= ~CSTOPB;         // Clear stop field, only one stop bit used in communication (most common)
    // tty.c_cflag &= ~CSIZE           // Clear all the size bits, then use the statement below
    // tty.c_cflag |= CS8;             // 8 bits per byte (most common)
    // tty.c_cflag &= ~CRTSCTS;        // Disable RTS/CTS hardware flow control (most common)
    // tty.c_cflag |= CREAD | CLOCAL;  // Turn on READ & ignore ctrl lines (CLOCAL = 1)

    // tty.c_lflag &= ~ICANON;         // Disable Canonical mode
    // tty.c_lflag &= ~ECHO;           // Disable echo
    // tty.c_lflag &= ~ECHOE;          // Disable erasure
    // tty.c_lflag &= ~ECHONL;         // Disable new-line echo
    // tty.c_lflag &= ~ISIG;           // Disable interpretation of INTR, QUIT and SUSP

    // tty.c_iflag &= ~(IXON | IXOFF | IXANY);                             // Turn off s/w flow ctrl
    // tty.c_iflag &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL);    // Disable any special handling of received bytes

    // tty.c_oflag &= ~OPOST;          // Prevent special interpretation of output bytes (e.g. newline chars)
    // tty.c_oflag &= ~ONLCR;          // Prevent conversion of newline to carriage return/line feed

    // tty.c_cc[VTIME] = 10;           // Wait for up to 1s (10 deciseconds), returning as soon as any data is received.
    // tty.c_cc[VMIN] = 0;

    // Set in/out baud rate
    cfsetispeed(&tty, UART_bus_speed);
    cfsetospeed(&tty, UART_bus_speed);
    //cfsetspeed(&tty, UART_bus_speed);     // Combined in and output setting

    // Save tty settings, also checking for error
    if (tcsetattr(UART_port, TCSANOW, &tty) != 0) {
        printf("Error %i from tcsetattr: %s\n", errno, strerror(errno));
    }

    // // Read and write examples
    // unsigned char msg[] = { 'H', 'e', 'l', 'l', 'o', '\r' };
    // write(UART_port, msg, sizeof(msg));
    //
    // char read_buf [256];
    // int n = read(UART_port, &read_buf, sizeof(read_buf));

    // ------------------------------------------------------------- OpenCV setup
    VideoCapture cap(0); //capture the video from webcam

    if ( !cap.isOpened() )  // if not success, exit program
    {
        printf("Cannot open the web cam\n");
        return -1;
    }

    //Capture a temporary image from the camera
    Mat imgTmp;
    cap.read(imgTmp); 

    int frameX = imgTmp.cols;
    int frameY = imgTmp.rows;


    while (true)
    {
        Mat imgOriginal;

        bool bSuccess = cap.read(imgOriginal); // read a new frame from video



        if (!bSuccess) //if not success, break loop
        {
            printf("Cannot read a frame from video stream\n");

            break;
        }

        Mat imgHSV;

        cvtColor(imgOriginal, imgHSV, COLOR_BGR2HSV); //Convert the captured frame from BGR to HSV

        Mat imgThresholded;

        inRange(imgHSV, Scalar(iLowH, iLowS, iLowV), Scalar(iHighH, iHighS, iHighV), imgThresholded); //Threshold the image

        //morphological opening (removes small objects from the foreground)
        erode(imgThresholded, imgThresholded, getStructuringElement(MORPH_ELLIPSE, Size(5, 5)) );
        dilate( imgThresholded, imgThresholded, getStructuringElement(MORPH_ELLIPSE, Size(5, 5)) ); 

        //morphological closing (removes small holes from the foreground)
        dilate( imgThresholded, imgThresholded, getStructuringElement(MORPH_ELLIPSE, Size(5, 5)) ); 
        erode(imgThresholded, imgThresholded, getStructuringElement(MORPH_ELLIPSE, Size(5, 5)) );

        //Calculate the moments of the thresholded image
        Moments oMoments = moments(imgThresholded);

        double dM01 = oMoments.m01;
        double dM10 = oMoments.m10;
        double dArea = oMoments.m00;

        // if the area <= 10000, I consider that the there are no object in the image and it's because of the noise, the area is not zero 
        if (dArea > 10000)
        {
            //calculate the position of the ball 0,0 is in the upperleft corner of the display
            int posX = dM10 / dArea;
            int posY = dM01 / dArea;        

            int relativeX = (posX - frameX / 2) / frameX;   // Position relative to the middle of the display
            int relativeY = (posY - frameY / 2) / frameY;

            int8_t deltaX = atan(relativeX * 2 * tan(viewAngleX/2));
            int8_t deltaY = atan(relativeY * 2 * tan(viewAngleY/2));

        }

    }

    return 0;
}