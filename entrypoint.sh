#!/bin/bash

# This won't be executed if keys already exist (i.e. from a volume)
ssh-keygen -A

groupmod --non-unique --gid "$GROUPID" "$GROUP_NAME"
usermod --non-unique --home "$DATADIR" --shell /usr/bin/rssh --uid "$USERID" --gid "$GROUPID" "$USER_NAME"

# Copy authorized keys from ENV variable
echo "$AUTHORIZED_KEYS" >$AUTHORIZED_KEYS_FILE
chown "${USER_NAME}:${GROUP_NAME}" $AUTHORIZED_KEYS_FILE

# Run sshd on container start
exec /usr/sbin/sshd -D -e
