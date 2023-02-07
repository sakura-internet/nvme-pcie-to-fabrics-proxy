#!/bin/bash -xe
sudo bash -c "/etc/init.d/xrdp start && tail -F /var/log/xrdp-sesman.log"
