FROM jenkins/jenkins:lts

# Switch jenkins to root user
USER root

# Metadata
LABEL maintainer="tiagomunhoz@djsystem.com.br"
ARG BUILD_DATE
ARG COMMIT
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="front-compiler" \
      org.label-schema.description="Based on original Jenkins container, it has docker client and docker-compose." \
      org.label-schema.version=$VERSION \
      org.label-schema.commit="$COMMIT" \
      org.label-schema.schema-version="1.1"

# Setting MY timezone (but you can change if you want to).
ARG TZ=America/Sao_Paulo

# Docker group
ARG gid=994

RUN ln -sfv /usr/share/zoneinfo/$TZ /etc/localtime &&\
    echo "$TZ" > /etc/timezone &&\
    groupadd -g "$gid" docker && gpasswd -a jenkins docker &&\
    apt-get update && \
    apt-get -y install apt-transport-https \
      ca-certificates \
      curl \
      gnupg2 \
      software-properties-common && \
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey &&\
		apt-key add /tmp/dkey && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get -y install docker-ce jq &&\
    curl -L https://github.com/docker/compose/releases/download/1.25.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose &&\
    chmod +x /usr/local/bin/docker-compose &&\
		rm -rf /var/lib/apt/lists/* /tmp/dkey

# Back on jenkins
USER jenkins
