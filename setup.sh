#!/bin/bash

# ---PROLOGUE---
cd ~
sudo apt update
sudo apt upgrade

# increase swap space temporarily. This is important for compiling OpenCV, but
# is also nice to have for the whole process.
if [ "$1" != "-ns" ];
then
    sudo sed -i -e 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/g' /etc/dphys-swapfile
    sudo systemctl restart dphys-swapfile
fi

# list of subsystems for which packages need to be installed
subsystems = (common people_counting database error_signaling)

# ---PACKAGE INSTALLATION---
sudo apt install "rpi_ws281x adafruit-circuitpython-neopixel mariadb-server python3 cmake build-essential pkg-config git libjpeg-dev libtiff-dev libjasper-dev libpng-dev libwebp-dev libopenexr-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libdc1394-22-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev libgtk-3-dev libqtgui4 libqtwebkit4 libqt4-test python3-pyqt5 libatlas-base-dev liblapacke-dev gfortran libhdf5-dev libhdf5-103 python3-dev python3-pip python3-numpy"


# ---OPENCV COMPILATION AND INSTALLATION---
# retrieve the necessary repositories
git clone https://github.com/opencv/opencv.git
git clone https://github.com/opencv/opencv_contrib.git

# make a build folder in our OpenCV
mkdir ~/opencv/build
cd ~/opencv/build

# generate makefile
cmake_options = "-D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
    -D ENABLE_NEON=ON \
    -D ENABLE_VFPV3=ON \
    -D BUILD_TESTS=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D CMAKE_SHARED_LINKER_FLAGS=-latomic \
    -D BUILD_EXAMPLES=OFF"

cmake $cmake_options ..

# do the make
make -j$(nproc)

# do the install
sudo make install

# update library links
sudo ldconfig

# ---CLEANUP---
# put our swap size back to normal
if [ "$1" != "-ns" ];
then
    sudo sed -i -e 's/CONF_SWAPSIZE=2048/CONF_SWAPSIZE=100/g' /etc/dphys-swapfile
    sudo systemctl restart dphys-swapfile
fi

# remove the files we made
cd ~
rm -rf ~/opencv
rm -rf ~/opencv_contrib
