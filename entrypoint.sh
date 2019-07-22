#!/bin/bash

# This won't be executed if keys already exist (i.e. from a volume)
ssh-keygen -A

groupmod --non-unique --gid "$GROUPID" "$GROUP_NAME"
usermod --non-unique --uid "$USERID" --gid "$GROUPID" "$USER_NAME"

# Authorized keys from scp-config should be volume mounted at
# $AUTHORIZED_KEYS_FILE which defaults to /authorized_keys
touch $AUTHORIZED_KEYS_FILE
chown "${USER_NAME}:${GROUP_NAME}" $AUTHORIZED_KEYS_FILE
chmod 600 $AUTHORIZED_KEYS_FILE

# Run sshd on container start
exec /usr/sbin/sshd -D -e
