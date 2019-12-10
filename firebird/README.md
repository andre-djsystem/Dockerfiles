# Firebird 2.5 SuperServer with collate UNICODE_CI_AI suport

  This is a unofficial patch for Jacob Alberty's image of Firebird 2.5 SuperServer:
* [Dockerhub](https://hub.docker.com/r/jacobalberty/firebird)
* [GitHub](https://github.com/jacobalberty/firebird-docker/blob/2.5-ss/Dockerfile)

## Arguments:
* TZ: TimeZone (Default: America/Sao_Paulo);
* LC: Locale   (Default: pt_BR.UTF-8);

## How to build and use
* Make a directory:
```
mkdir -p $HOME/my_amazing_dir && cd $HOME/my_amazing_dir
```
* Sync Mr. Alberty sources:
```
git clone --branch 2.5-ss https://github.com/jacobalberty/firebird-docker.git .
```
* Sync this sources to a temporary folder:
```
git clone https://github.com/andre-djsystem/Dockerfiles.git tmp
```
* Apply this patch:
```
patch Dockerfile < tmp/firebird/fix.patch
```
* Build the image:
```
docker image build -t my_beloved_firebird:latest --build-arg TZ=America/Sao_Paulo --build-arg LC=pt_BR.UTF-8 .
```
* Run it as your need:
```
docker container run --name firebird -v Database.fdb:/opt/firebird/database.fdb -p 3050:3050 --env ISC_PASSWORD=my_ultra_secret_password_of_firebird my_beloved_firebird
```

## DockerHub image
  A complete image built with pt_BR locale and Sao_Paulo timezone is avaliabe [here](https://hub.docker.com/repository/docker/djsystem/firebird25-ss)

