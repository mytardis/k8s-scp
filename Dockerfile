FROM debian:jessie

ENV AUTHORIZED_KEYS_FILE=/authorized_keys
ENV USERID=0
ENV GROUPID=0
ENV USER_NAME=mydata
ENV GROUP_NAME=mydata

RUN apt-get update \
 && apt-get install -y openssh-server \
 && groupadd --non-unique --gid $GROUPID $GROUP_NAME \
 && useradd --non-unique --uid $USERID --gid $GROUPID --create-home --shell /bin/bash $USER_NAME \
 && echo "AuthorizedKeysFile /authorized_keys" >>/etc/ssh/sshd_config \
 && echo "KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1" >>/etc/ssh/sshd_config \
 && mkdir /var/run/sshd && chmod 0755 /var/run/sshd

ADD entrypoint.sh /

EXPOSE 22

CMD ["/entrypoint.sh"]
