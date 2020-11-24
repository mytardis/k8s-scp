FROM alpine:latest

RUN apk add --no-cache openssh-server-pam openssh-client

# This will be provided via a volume mount:
ENV AUTHORIZED_KEYS_SOURCE_FILE=/AUTHORIZED_KEYS

# As we can't change the ownership of a volume mount in the entrypoint.sh,
# we'll copy $AUTHORIZED_KEYS_SOURCE_FILE to $AUTHORIZED_KEYS_TARGET_FILE
ENV AUTHORIZED_KEYS_TARGET_FILE=/authorized_keys

ENV USER_NAME=mydata
ENV USERID=1001
ENV GROUP_NAME=mydata
ENV GROUPID=1001

RUN addgroup $GROUP_NAME -g $GROUPID && \
    adduser $USER_NAME -u $USERID -G $GROUP_NAME -D

COPY sshd_config /etc/ssh/

EXPOSE 22

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/sbin/sshd", "-D"]
