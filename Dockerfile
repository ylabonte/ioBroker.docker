FROM node:14-alpine

# Install ioBroker
RUN apk add --no-cache --virtual .gyp acl avahi bash build-base curl git linux-headers \
    make gcc g++ pkgconfig python python-dev udev unzip libcap shadow sudo \
    ffmpeg \
  && curl -sL https://iobroker.net/install.sh | bash - \
  && test -d /home/iobroker || mkdir -p /home/iobroker/bin \
  && iobroker start \
  && sleep 60s \
  && iobroker stop

# Declare persistent volumes
VOLUME /opt/iobroker/backups
VOLUME /etc/letsencrypt

# Copy scripts
COPY ./scripts/* /home/iobroker/bin/
COPY ./docker-entrypoint.sh /entrypoint.sh

# Set timezone and permissions
RUN printf "TZ='Europe/Berlin'\nexport TZ\n" >> /home/iobroker/.profile \
  # Set owner of iobroker directories
  && chown -R iobroker. /home/iobroker \
  # Preserve execution permissions for our scripts
  && chmod -R 0775 /home/iobroker/bin /entrypoint.sh

# Switch to the iobroker user (created by iobroker's install script)
WORKDIR /home/iobroker

ENV HOME /home/iobroker
ENV PATH ${HOME}/bin:${PATH}

# Define the entrypoint
ENTRYPOINT ["/bin/bash"]
CMD ["-c", "/entrypoint.sh"]

# Listening ports
EXPOSE 8081 8082 8083 8084
