FROM debian:jessie

# This will be provided via a volume mount:
ENV AUTHORIZED_KEYS_SOURCE_FILE=/AUTHORIZED_KEYS
# As we can't change the ownership of a volume mount in the entrypoint.sh,
# we'll copy $AUTHORIZED_KEYS_SOURCE_FILE to $AUTHORIZED_KEYS_TARGET_FILE
ENV AUTHORIZED_KEYS_TARGET_FILE=/authorized_keys

ENV USER_NAME=mydata
ENV GROUP_NAME=mydata

RUN apt-get update \
 && apt-get install -y openssh-server \
 && groupadd $GROUP_NAME \
 && useradd --create-home --shell /bin/bash $USER_NAME -g $GROUP_NAME \
 && echo "AuthorizedKeysFile /authorized_keys" >>/etc/ssh/sshd_config \
 && echo "KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1" >>/etc/ssh/sshd_config \
 && mkdir /var/run/sshd && chmod 0755 /var/run/sshd

ADD entrypoint.sh /

EXPOSE 22

ENTRYPOINT /entrypoint.sh
