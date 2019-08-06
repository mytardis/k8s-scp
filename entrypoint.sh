#!/bin/bash

# Copy shared keys from S3 bucket
cp /data/scp/ssh_host_* /etc/ssh/
chmod 0600 /etc/ssh/ssh_host_*
if [ ! -f /etc/ssh/ssh_host_key ]; then
# This won't be executed if keys already exist (i.e. from a volume)
  echo "Generating SSH keys..."
  ssh-keygen -A
  cp /etc/ssh/ssh_host_* /data/scp/
fi

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
