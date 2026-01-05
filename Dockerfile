FROM ubuntu:24.04


# installing packages for Lighttpd (to serve frontend) and System monitoring, including MRTG
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  cron \
  libcrypt-hcesha-perl \
  libcrypt-des-perl \
  libdigest-hmac-perl \
  libnet-snmp-perl \
  libsnmp-dev \
  lighttpd \
  snmp \
  snmpd \
  rrdtool \
  net-tools \
  mrtg \
  snmp \
  snmp-mibs-downloader \
  software-properties-common \
  sysstat \
 && sed -i -e 's/= "\/var\/www\/html/= "\/var\/www\//g' /etc/lighttpd/lighttpd.conf \
 && sed -i -e 's/= 80/= 681/g' /etc/lighttpd/lighttpd.conf \
 && lighty-enable-mod auth \
 && lighty-enable-mod ssi 
# && lighty-enable-mod ssi \
# && mkdir -p /opt/mrtg

COPY etc/mrtg/mrtg.cfg /etc/mrtg/
COPY scripts/cron1m.sh /etc/mrtg/
COPY scripts/cron5m.sh /etc/mrtg/
COPY scripts/init.sh /etc/mrtg/
COPY scripts/update.sh /etc/mrtg/
COPY cron.d/mrtg /etc/cron.d/

RUN chmod +x /etc/mrtg/*.sh
RUN ls -l /etc/mrtg/
RUN echo "Europe/Paris" > /etc/timezone
RUN echo "alias ssh='ssh -o StrictHostKeyChecking=accept-new'" >> /etc/bash.bashrc

EXPOSE 681
CMD ["bash", "-c", "/opt/mrtg/cfgmaker.sh && lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]

