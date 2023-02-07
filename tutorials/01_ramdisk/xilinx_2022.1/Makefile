################################################################################
# Makefile for providing xilinx tools introduced environment via docker
#
# usage:
#   $ make docker      # get console on xilinx-tools container with X forwarding to client X server
#                      # `xeyes` to test X forwarding
#   $ make docker-xrdp # get console on xilinx-tools container with Xfce virtual desktop accessible on localhost:13389
#   $ make clean       # cleanup generated files
#
# supported VendorID / ProductID
#   10c4:ea70 = CP2105 Dual UART Bridge
#   0403:6014 = FT232H Single HS USB-UART
#   0403:6010 = FT2232C/D/H Dual UART/FIFO IC
#   0403:6011 = FT4232H Quad High Speed USB to UART/MPSSE IC
################################################################################

.PHONY: default docker docker-xrdp docker-build docker-force-rebuild docker-pull docker-push docker-clean

# dump variables
#@$(foreach v,$(.VARIABLES),$(info $v=$($v)))

SCRIPT_DIR     := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PROJ_ROOT      := .
INSTALL_ROOT   := /opt

IMAGE_NAME     := xilinx-tools

IMAGE_TAG      := 2022.1
INTERNAL_USER  := user
BUILD_REQUIRED := \
	$(shell if ! (type docker > /dev/null 2>&1); then echo 0; \
	elif ! (docker inspect $(IMAGE_NAME):$(IMAGE_TAG) > /dev/null 2>&1); then echo 1; \
	else echo 0 ; \
	fi )

default: docker

# get vivado & xsdk & petalinux PATH introduced shell on a container, suitable for Linux Desktop and WSL2 where GUI tools run on host X server directly.
docker:
	@if !(type docker > /dev/null 2>&1); then echo "command 'docker' not found." ; exit 1 ; fi
	@if [ $(BUILD_REQUIRED) -eq 1 ]; then echo "container image $(IMAGE_NAME):$(IMAGE_TAG) not found, try \`make docker-build\` or \`make docker-pull\` to get it." ; exit 1 ; fi
	docker run --rm --net host -it -w $(SCRIPT_DIR) \
		-v $(SCRIPT_DIR)/$(PROJ_ROOT)/:$(SCRIPT_DIR)/$(PROJ_ROOT)/ \
		-v ${INSTALL_ROOT}:/opt -e USER_ID=`id -u` -e GROUP_ID=`id -g` \
		$(shell if [ -n "`lsusb -d 10c4:ea70`" ] ; then echo "--device `lsusb -d 10c4:ea70`" | perl -pe 's!Bus\s(\d{3})\sDevice\s(\d{3}).*!/dev/bus/usb/\1/\2!' ; fi) \
		$(shell if [ -n "`lsusb -d 0403:6014`" ] ; then echo "--device `lsusb -d 0403:6014`" | perl -pe 's!Bus\s(\d{3})\sDevice\s(\d{3}).*!/dev/bus/usb/\1/\2!' ; fi) \
		$(shell if [ -n "`lsusb -d 0403:6010`" ] ; then echo "--device `lsusb -d 0403:6010`" | perl -pe 's!Bus\s(\d{3})\sDevice\s(\d{3}).*!/dev/bus/usb/\1/\2!' ; fi) \
		$(shell if [ -n "`lsusb -d 0403:6011`" ] ; then echo "--device `lsusb -d 0403:6011`" | perl -pe 's!Bus\s(\d{3})\sDevice\s(\d{3}).*!/dev/bus/usb/\1/\2!' ; fi) \
		$(shell if [ -e /dev/ttyUSB0 ] ; then echo "--device /dev/ttyUSB0"; fi) \
		$(shell if [ -e /dev/ttyUSB1 ] ; then echo "--device /dev/ttyUSB1"; fi) \
		$(shell if [ -e /dev/ttyUSB2 ] ; then echo "--device /dev/ttyUSB2"; fi) \
		$(shell if [ -e /dev/ttyUSB3 ] ; then echo "--device /dev/ttyUSB3"; fi) \
		$(shell if [ -e /dev/ttyUSB4 ] ; then echo "--device /dev/ttyUSB4"; fi) \
		$(shell if [ -e /dev/ttyUSB5 ] ; then echo "--device /dev/ttyUSB5"; fi) \
		-e DISPLAY=$(DISPLAY) -v /tmp/.X11-unix:/tmp/.X11-unix -v $(HOME)/.Xauthority:/home/$(INTERNAL_USER)/.Xauthority \
		$(IMAGE_NAME):$(IMAGE_TAG) bash && true

# exec a container with xfce4 desktop inside allows you to access it via RDP client, suitable for headless server and Docker on Mac.
# leave running console on current terminal, access localhost:13389 and then use credential username=user and password=password
docker-xrdp:
	@if !(type docker > /dev/null 2>&1); then echo "command 'docker' not found." ; exit 1 ; fi
	@if [ $(BUILD_REQUIRED) -eq 1 ]; then echo "container image $(IMAGE_NAME):$(IMAGE_TAG) not found, try \`make docker-build\` or \`make docker-pull\` to get it." ; exit 1 ; fi
	docker run --rm -it -w $(SCRIPT_DIR) \
		-p 13389:3389 \
		-v $(SCRIPT_DIR)/$(PROJ_ROOT)/:$(SCRIPT_DIR)/$(PROJ_ROOT)/ \
		-v ${INSTALL_ROOT}:/opt -e USER_ID=`id -u` -e GROUP_ID=`id -g` \
		$(shell if [ -n "`lsusb -d 10c4:ea70`" ] ; then echo "--device `lsusb -d 10c4:ea70`" | perl -pe 's!Bus\s(\d{3})\sDevice\s(\d{3}).*!/dev/bus/usb/\1/\2!' ; fi) \
		$(shell if [ -n "`lsusb -d 0403:6014`" ] ; then echo "--device `lsusb -d 0403:6014`" | perl -pe 's!Bus\s(\d{3})\sDevice\s(\d{3}).*!/dev/bus/usb/\1/\2!' ; fi) \
		$(shell if [ -n "`lsusb -d 0403:6010`" ] ; then echo "--device `lsusb -d 0403:6010`" | perl -pe 's!Bus\s(\d{3})\sDevice\s(\d{3}).*!/dev/bus/usb/\1/\2!' ; fi) \
		$(shell if [ -n "`lsusb -d 0403:6011`" ] ; then echo "--device `lsusb -d 0403:6011`" | perl -pe 's!Bus\s(\d{3})\sDevice\s(\d{3}).*!/dev/bus/usb/\1/\2!' ; fi) \
		$(shell if [ -e /dev/ttyUSB0 ] ; then echo "--device /dev/ttyUSB0"; fi) \
		$(shell if [ -e /dev/ttyUSB1 ] ; then echo "--device /dev/ttyUSB1"; fi) \
		$(shell if [ -e /dev/ttyUSB2 ] ; then echo "--device /dev/ttyUSB2"; fi) \
		$(shell if [ -e /dev/ttyUSB3 ] ; then echo "--device /dev/ttyUSB3"; fi) \
		$(shell if [ -e /dev/ttyUSB4 ] ; then echo "--device /dev/ttyUSB4"; fi) \
		$(shell if [ -e /dev/ttyUSB5 ] ; then echo "--device /dev/ttyUSB5"; fi) \
		$(IMAGE_NAME):$(IMAGE_TAG) && true

# manipulate docker image
docker-build:
	@if !(type docker > /dev/null 2>&1); then echo "command 'docker' not found." ; exit 1 ; fi
	time docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

docker-force-rebuild:
	@if !(type docker > /dev/null 2>&1); then echo "command 'docker' not found." ; exit 1 ; fi
	time docker build -t $(IMAGE_NAME):$(IMAGE_TAG) --no-cache .

docker-pull:
	@if !(type docker > /dev/null 2>&1); then echo "command 'docker' not found." ; exit 1 ; fi
	time docker pull $(IMAGE_NAME):$(IMAGE_TAG)

docker-push:
	@if !(type docker > /dev/null 2>&1); then echo "command 'docker' not found." ; exit 1 ; fi
	time docker push $(IMAGE_NAME):$(IMAGE_TAG)

# remove docker image
docker-clean:
	@if !(type docker > /dev/null 2>&1); then echo "command 'docker' not found." ; exit 1 ; fi
	@if !(docker inspect $(IMAGE_NAME):$(IMAGE_TAG) > /dev/null 2>&1); then echo "no '$(IMAGE_NAME):$(IMAGE_TAG)' image, do nothing."; exit 1 ; fi
	docker image rm $(IMAGE_NAME):$(IMAGE_TAG)
