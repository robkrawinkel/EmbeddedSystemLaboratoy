#include <stdio.h>
#include <math.h>
#include <fcntl.h>      // Contains file controls like O_RDWR
#include <errno.h>      // Error integer and strerror() function
#include <termios.h>    // Contains POSIX terminal control definitions
#include <unistd.h>     // write(), read(), close()
#include <cstdint>
#include <stdint.h>
#include <chrono>
#include <iostream>

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
#define pi 3.14159265359

// Set the UART properties
#define UART_device_name "/dev/ttyO0"
#define UART_bus_speed B115200

#define ANGLE_const 1.7321

int frameSizeX;         // Variables to store the size of the frame captured by the camera
int frameSizeY;
int posX;               // Variables to store the location of the green screen on the display in pixels from top left (0,0)
int posY;
double relativePosX;    // Variable to store the location of the green screen relative to the middle of the frame
double relativePosY;
double tempX;
double tempY;
int8_t deltaRotX;       // Variable to store the relative rotation angle
int8_t deltaRotY;

// Function to send two data bytes over the UART bus
void sendUART(int UART_port, int8_t msg0, int8_t msg1) {
    int8_t UART_msg[3];

    UART_msg[0] = msg0;
    UART_msg[1] = msg1;
    UART_msg[2] = '\n';

    write(UART_port, UART_msg, sizeof(UART_msg));
}

int main( int argc, char** argv )
{
    // ------------------------------------------------------------- UART setup
    // From: https://blog.mbedded.ninja/programming/operating-systems/linux/linux-serial-ports-using-c-cpp/
    int UART_port = open(UART_device_name, O_RDWR);

    if (UART_port == 0) {
        printf("port opening failed\n");
    }
    
    // struct termios tty;

    // // Get the current UART settings
    // if(tcgetattr(UART_port, &tty) != 0) {
    //     printf("Error %i from tcgetattr: %s\n", errno, strerror(errno));
    // }

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

    // // Set in/out baud rate
    // cfsetispeed(&tty, UART_bus_speed);
    // cfsetospeed(&tty, UART_bus_speed);
    // //cfsetspeed(&tty, UART_bus_speed);     // Combined in and output setting

    // // Save tty settings, also checking for error
    // if (tcsetattr(UART_port, TCSANOW, &tty) != 0) {
    //     printf("Error %i from tcsetattr: %s\n", errno, strerror(errno));
    // }

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

    // Store the frame size
    frameSizeX = imgTmp.cols;
    frameSizeY = imgTmp.rows;

    while (true)
    {
        auto startTime = chrono::duration_cast<chrono::milliseconds>(chrono::system_clock::now().time_since_epoch()).count();

        Mat imgOriginal;
        bool bSuccess = cap.read(imgOriginal); // read a new frame from video

        if (!bSuccess) {
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
        if (dArea > 1000000)
        {
            //calculate the position of the ball 0,0 is in the upperleft corner of the display
            posX = dM10 / dArea;
            posY = dM01 / dArea;        

            // Position relative to the middle of the display
            relativePosX = ((double)posX - (double)frameSizeX / 2.0) / (double)frameSizeX;
            relativePosY = ((double)posY - (double)frameSizeY / 2.0) / (double)frameSizeY;

            // Angle relative to the centre of the camera view
            tempX = atan(relativePosX * 2.0 * ANGLE_const) / pi * 180.0;    
            tempY = atan(relativePosY * 2.0 * ANGLE_const) / pi * 180.0;

            deltaRotX = tempX;
            deltaRotY = tempY;

            sendUART(UART_port, deltaRotX, deltaRotY);
        } else {
            sendUART(UART_port, -128, -128);
        }

        auto endTime = chrono::duration_cast<chrono::milliseconds>(chrono::system_clock::now().time_since_epoch()).count();


        printf("PosX: %d\t PosY: %d\t Area: %f\t frameSizeX: %d\t relativePosX: %f\t tempX: %f\t deltaRotX: %d\n", posX, posY, dArea, frameSizeX, relativePosX, tempX, deltaRotX);
    }

    return 0;
}