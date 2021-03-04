FROM alpine:latest
RUN apk update
RUN apk add --no-cache bash expect openssh-client perl-socket6 msmtp
RUN adduser -D -s /bin/sh rancid
RUN apk add --no-cache --virtual .builddeps build-base alpine-sdk autoconf automake gcc make 
RUN  cd /usr/bin && ln -s aclocal aclocal-1.14 && ln -s automake automake-1.14 && \
     cd /root && \
# Downloading the lastest from UPSTREAM
     wget https://shrubbery.net/pub/rancid/rancid-3.13.tar.gz && \
     tar xzf rancid-*.tar.gz && \
     cd rancid-3.13/ && \
     chown -R rancid /home/rancid && \
     ./configure --prefix=/home/rancid --mandir=/usr/share/man --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc/rancid --with-git --datarootdir=/usr/share && \
     make install
# setup sample config, default cron, 20 minute polling
RUN cp /usr/share/rancid/rancid.conf.sample /etc/rancid && \
# Cron every 4 hours
    echo '0 */4 * * * /usr/bin/rancid-run >/home/rancid/var/logs/cron.log 2>/home/rancid/var/logs/cron.err' > /etc/rancid/rancid.cron
# Creating clogin configuration file
RUN touch /home/rancid/.cloginrc
# Creating msmtp configuration file
RUN touch /etc/msmtprc
# Creating aliases configuration file
RUN touch /etc/aliases

# Volume
VOLUME /home/rancid
VOLUME /etc/rancid
VOLUME /etc/msmtprc
VOLUME /etc/aliases
# write README file
# advise on git config/read from ENV and adjust accordingly
# advise to add entry to GROUPS list in rancid.conf, run rancid-cvs as 'rancid' user to pre-create folders
ENTRYPOINT ["/init"]
