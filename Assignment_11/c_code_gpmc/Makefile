#
# Folder definitions
# 
PWD:=$(shell pwd)
SOURCE_DIR:=$(PWD)/src
INCLUDE_DIR:=$(PWD)/include
BUILD_DIR:=$(PWD)/build
OBJECT_DIR=$(BUILD_DIR)/obj
KERNEL_MODULE_DIR=$(PWD)/../kernel_module

#
# Source files
#
SOURCE_FILES_C=$(SOURCE_DIR)/main.c $(SOURCE_DIR)/gpmc_driver_c.c
SOURCE_FILES_CPP=$(SOURCE_DIR)/example_cpp.cpp $(SOURCE_DIR)/gpmc_driver_cpp.cpp

#
# Object files
#
OBJECT_FILES_C=$(patsubst %.c,%.o,$(patsubst $(SOURCE_DIR)/%, $(OBJECT_DIR)/%, $(SOURCE_FILES_C)))
OBJECT_FILES_CPP=$(patsubst %.cpp,%.o,$(patsubst $(SOURCE_DIR)/%, $(OBJECT_DIR)/%, $(SOURCE_FILES_CPP)))

#
# Commands
#
CROSS_COMPILE=arm-linux-gnueabihf-
CXX=$(CROSS_COMPILE)g++
CC=$(CROSS_COMPILE)gcc
RM=rm -f
MKDIR=mkdir -p

#
# Flags
# You can define your own libraries and flags here.
#
LIBS=
LDFLAGS=
CFLAGS=-I$(INCLUDE_DIR) -I$(KERNEL_MODULE_DIR)/include -Wall
CPPFLAGS=

#
# Targets
#
.PHONY: all c cpp clean
all: cpp c

# Compile .cpp files to .o (object) files.
$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.cpp
	$(MKDIR) $(BUILD_DIR) $(OBJECT_DIR)
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) -o $@ $<

# Compile .c files to .o (object) files.
$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.c
	$(MKDIR) $(BUILD_DIR) $(OBJECT_DIR) $(MAKE_DIR)
	$(CC) -c $(CFLAGS) -o $@ $<

# Compile c-example.	
c: $(OBJECT_FILES_C)
	$(CC) $(LDFLAGS) $^ $(LIBS) -o gpmc_example_$@

# Compile c++ example
cpp: $(OBJECT_FILES_CPP)
	$(CXX) $(LDFLAGS) $^ $(LIBS) -o gpmc_example_$@

# Remove build directory and compiled applications.
clean:
	$(RM) gpmc_example_c gpmc_example_cpp
	$(RM) -r $(BUILD_DIR)
