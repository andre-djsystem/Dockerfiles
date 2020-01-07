FROM jenkins/jenkins:lts

# necessário porque a imagem do jenkins usa o usuário jenkins como padrão
USER root
# Metadados da imagem 
LABEL maintainer="tiagomunhoz@djsystem.com.br"
ARG BUILD_DATE
ARG COMMIT
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="front-compiler" \
      org.label-schema.description="Baseada na imagem original do jenkins com debian, contém o docker e docker-compose no modo docker-in-docker" \
      org.label-schema.version=$VERSION \
      org.label-schema.commit="$COMMIT" \
      org.label-schema.schema-version="1.1"

# Setting MY timezone
ARG TZ=America/Sao_Paulo
RUN ln -sfv /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime &&\
    echo "$TZ" > /etc/timezone

# Allowing Jenkins's user to manage docker
ARG gid=994
RUN groupadd -g "$gid" docker
RUN gpasswd -a jenkins docker

# Installing docker client
RUN apt-get update && \
    apt-get -y install apt-transport-https \
      ca-certificates \
      curl \
      gnupg2 \
      software-properties-common && \
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey &&\
		apt-key add /tmp/dkey && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get -y install docker-ce &&\
		rm -rf /var/lib/apt/lists/* /tmp/dkey

# Installing a new fresh docker-compose that support version 3 yml file
RUN curl -L https://github.com/docker/compose/releases/download/1.25.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose &&\
    chmod +x /usr/local/bin/docker-compose

# Back in to a non root user
USER jenkins
