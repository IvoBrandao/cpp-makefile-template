#!/bin/bash

# Ensure the script is run as sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Update package list and install the tools
sudo apt update && sudo apt install build-essential gcc g++ make doxygen -y

