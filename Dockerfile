FROM debian:jessie

ENV DATADIR=/var/store
ENV AUTHORIZED_KEYS_FILE=/authorized_keys
ENV USERID=0
ENV GROUPID=0
ENV USER_NAME=mydata
ENV GROUP_NAME=mydata

RUN apt-get update \
 && apt-get install -y openssh-server rssh rsync \
 && rm -f /etc/ssh/ssh_host_* \
 && groupadd --non-unique --gid $GROUPID $GROUP_NAME \
 && useradd --non-unique --uid $USERID --gid $GROUPID --no-create-home --home-dir $DATADIR --shell /usr/bin/rssh $USER_NAME \
 && echo "AuthorizedKeysFile $AUTHORIZED_KEYS_FILE" >>/etc/ssh/sshd_config \
 && echo "KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1" >>/etc/ssh/sshd_config \
 && touch $AUTHORIZED_KEYS_FILE \
 && chown $USER_NAME $AUTHORIZED_KEYS_FILE \
 && chmod 0600 $AUTHORIZED_KEYS_FILE \
 && mkdir /var/run/sshd && chmod 0755 /var/run/sshd \
 && echo "allowscp" >> /etc/rssh.conf \
 && echo "allowsftp" >> /etc/rssh.conf \
 && echo "allowrsync" >> /etc/rssh.conf

ADD entrypoint.sh /

EXPOSE 22

CMD ["/entrypoint.sh"]
