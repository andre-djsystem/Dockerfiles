FROM jenkins/jenkins:lts

USER root

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
    apt-get -y install docker-ce

# Housekeeping
RUN rm -rf /var/lib/apt/lists/* /tmp/dkey

# Back in to a non root user
USER jenkins
