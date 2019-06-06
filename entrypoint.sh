#!/bin/bash

# Copy shared keys from S3 bucket
cp /data/scp/ssh_host_* /etc/ssh/
chmod 0600 /etc/ssh/ssh_host_*

if [ ! -f /etc/ssh/ssh_host_key ]; then
  # This won't be executed if keys already exist
  echo "Generating SSH keys..."
  ssh-keygen -A
  cp /etc/ssh/ssh_host_* /data/scp/
fi

groupmod --non-unique --gid "${GROUPID}" "${GROUP_NAME}"
usermod --non-unique --home "${DATADIR}" --uid "${USERID}" --gid "${GROUPID}" "${USER_NAME}"

# Copy authorized keys from ENV variable
echo "${AUTHORIZED_KEYS}" >$AUTHORIZED_KEYS_FILE
chown "${USER_NAME}:${GROUP_NAME}" $AUTHORIZED_KEYS_FILE

# Run sshd on container start
exec /usr/sbin/sshd -D -e
