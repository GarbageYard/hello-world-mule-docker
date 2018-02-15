FROM openjdk:8u151-jre-slim

ENV MULE_VERSION=3.9.0 \
    # Parent directory in which the Mule installation directory will be located.
    INSTALLATION_PARENT=/opt \
    # Name of Mule installation directory.
    INSTALLATION_DIRECTORY_NAME=mule-standalone \
    # User and group that the Mule ESB instance will be run as, in order not to run as root.
    RUN_AS_USER=mule

ENV MULE_DOWNLOAD_URL=https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz \
    MULE_HOME="$INSTALLATION_PARENT/$INSTALLATION_DIRECTORY_NAME"

    # Add user (and group) which will run Mule ESB in the container.
RUN groupadd -f ${RUN_AS_USER} && \
    useradd --system --home /home/${RUN_AS_USER} -g ${RUN_AS_USER} ${RUN_AS_USER} && \
    # Updates for Debian.
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y wget curl procps && \
    # Clean up.
    apt-get autoclean && apt-get --purge -y autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    # Download and unpack Mule ESB.
    cd ${INSTALLATION_PARENT} && \
    wget ${MULE_DOWNLOAD_URL} && \
    tar xvzf mule-standalone-*.tar.gz && \
    rm mule-standalone-*.tar.gz && \
    mv mule-standalone-* ${INSTALLATION_DIRECTORY_NAME}

COPY hello-example.zip ${MULE_HOME}/apps/

    # Set the owner of all Mule-related files to the user which will be used to run Mule.
RUN chown -R ${RUN_AS_USER}:${RUN_AS_USER} ${MULE_HOME}

WORKDIR ${MULE_HOME}

# Default when starting the container is to start Mule ESB.
CMD ${MULE_HOME}/bin/mule console

EXPOSE 8888
