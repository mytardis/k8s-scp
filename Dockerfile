FROM debian:jessie AS base

RUN apt-get update

# https://github.com/openssh/openssh-portable/blob/master/README.privsep
RUN mkdir /var/empty && \
    chown root:sys /var/empty && \
    chmod 755 /var/empty && \
    groupadd sshd && \
    useradd -g sshd -c 'sshd privsep' -d /var/empty -s /bin/false sshd

RUN apt-get install -y build-essential libssl-dev zlib1g-dev libselinux1-dev libpam0g-dev git autoconf make && \
    git clone https://github.com/rapier1/openssh-portable/ && \
    cd openssh-portable && \
    autoreconf configure.ac && \
    ./configure \ 
        --sysconfdir=/etc/ssh \
        --prefix=/usr \
        --sysconfdir=/etc/ssh \
        --libexecdir=/usr/lib/ssh \
        --mandir=/usr/share/man \
        --with-pid-dir=/run \
        --with-mantype=doc \
        --disable-lastlog \
        --disable-strip \
        --disable-wtmp \
        --with-pam \
        --with-none \
        --with-privsep-path=/var/empty \
        --with-xauth=/usr/bin/xauth \
        --with-privsep-user=sshd \
        --with-md5-passwords \
        --with-ssl-engine && \
    make && \
    make install && \
    apt-get remove -y build-essential && \
    rm /etc/ssh/ssh_host_* && cd .. && rm -rf openssh-portable

FROM base AS scp

# This will be provided via a volume mount:
ENV AUTHORIZED_KEYS_SOURCE_FILE=/AUTHORIZED_KEYS

# As we can't change the ownership of a volume mount in the entrypoint.sh,
# we'll copy $AUTHORIZED_KEYS_SOURCE_FILE to $AUTHORIZED_KEYS_TARGET_FILE
ENV AUTHORIZED_KEYS_TARGET_FILE=/authorized_keys

ENV USER_NAME=mydata
ENV USERID=1001
ENV GROUP_NAME=mydata
ENV GROUPID=1001

RUN groupadd $GROUP_NAME -g $GROUPID && \
    useradd --create-home --shell /bin/bash $USER_NAME -u $USERID -g $GROUP_NAME

COPY sshd_config /etc/ssh/

EXPOSE 22

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
