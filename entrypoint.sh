#!/bin/bash

# This won't be executed if keys already exist (i.e. from a volume)
ssh-keygen -A

groupmod --non-unique --gid "$GROUPID" "$GROUP_NAME"
usermod --non-unique --uid "$USERID" --gid "$GROUPID" "$USER_NAME"

# Authorized keys from scp-config should be volume mounted at
# $AUTHORIZED_KEYS_SOURCE_FILE which defaults to /AUTHORIZED_KEYS
# We'll make a copy, so we can change ownership and permissions:
if [[ ! -e "${AUTHORIZED_KEYS_SOURCE_FILE}" ]]
then
    touch $AUTHORIZED_KEYS_SOURCE_FILE
fi
cp $AUTHORIZED_KEYS_SOURCE_FILE $AUTHORIZED_KEYS_TARGET_FILE
chown "${USER_NAME}:${GROUP_NAME}" $AUTHORIZED_KEYS_TARGET_FILE
chmod 600 $AUTHORIZED_KEYS_TARGET_FILE

# Run sshd on container start
exec /usr/sbin/sshd -D -e
