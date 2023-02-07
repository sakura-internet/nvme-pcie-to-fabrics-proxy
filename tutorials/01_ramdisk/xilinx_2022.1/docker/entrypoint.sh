#!/bin/bash -xe

INTERNAL_USER=user
if [ -n ${USER_ID+x} -a -n ${GROUP_ID+x} ]; then
    echo usermod -u $USER_ID -d /home/${INTERNAL_USER} -o -m ${INTERNAL_USER}
    echo groupmod -g $GROUP_ID ${INTERNAL_USER}
    usermod -u $USER_ID -o -d /home/${INTERNAL_USER} -m ${INTERNAL_USER}
    groupmod -g $GROUP_ID ${INTERNAL_USER}
fi

CMDLINE="$@"
su ${INTERNAL_USER} -c "$CMDLINE"
exit $?
