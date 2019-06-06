FROM debian:jessie

ENV DATADIR=/var/store
ENV AUTHORIZED_KEYS_FILE=/authorized_keys
ENV USERID=1000
ENV GROUPID=1000
ENV USER_NAME=mydata
ENV GROUP_NAME=mydata

RUN apt-get update \
	&& apt-get install -y openssh-server rsync \
	&& rm -f /etc/ssh/ssh_host_* \
	&& groupadd --non-unique --gid $GROUPID $GROUP_NAME \
	&& useradd --non-unique --uid $USERID --gid $GROUPID --no-create-home --home-dir $DATADIR $USER_NAME \
	&& echo "AuthorizedKeysFile $AUTHORIZED_KEYS_FILE" >>/etc/ssh/sshd_config \
	&& echo "KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1" >>/etc/ssh/sshd_config \
	&& touch $AUTHORIZED_KEYS_FILE \
	&& chown $USER_NAME $AUTHORIZED_KEYS_FILE \
	&& chmod 0600 $AUTHORIZED_KEYS_FILE \
	&& mkdir /var/run/sshd && chmod 0755 /var/run/sshd

ADD entrypoint.sh /

EXPOSE 22

CMD ["/entrypoint.sh"]
