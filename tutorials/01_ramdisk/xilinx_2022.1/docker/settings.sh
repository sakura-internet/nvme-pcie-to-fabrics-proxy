#!/bin/bash
XILINX_VERSION=2022.1

source /opt/Xilinx/Vitis/${XILINX_VERSION}/settings64.sh
source /opt/Xilinx/PetaLinux/${XILINX_VERSION}/settings.sh
export LC_ALL="C"
export QT_X11_NO_MITSHM=1
echo "---- xilinx-tools:${XILINX_VERSION} container shell ----"
if !(type vivado > /dev/null 2>&1); then
	echo "command 'vivado' not found. try '$ /root/install.sh' to install tools on /opt"
else
	echo "'vivado' and some xilinx tools successfully introduced on your PATH"
fi
xhost +
