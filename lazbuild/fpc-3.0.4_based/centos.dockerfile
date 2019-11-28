FROM centos:7
LABEL maintainer 'Tiago Tarifa Munhoz <tiagomunhoz@djsystem.com.br>'

# Where the sources came from
ARG DirSrc=./sources

# Fix MY timezone. 
ARG TZ=America/Sao_Paulo
RUN ln -sfv /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime &&\
    echo "$TZ" > /etc/timezone

# A non root user for compile packages
RUN useradd -m -s /bin/bash pascal

# This allow a cross compiling environment
# https://wiki.lazarus.freepascal.org/Cross_compiling
RUN printf '#!/bin/bash\nld -A elf32-i386 $@\n' > /usr/bin/i386-linux-ld &&\
		printf '#!/bin/bash\nas --32 $@\n' > /usr/bin/i386-linux-as &&\
		chmod +x /usr/bin/i386-linux-as /usr/bin/i386-linux-ld 

# Sources and compiler of FreePascal
COPY $DirSrc/fpc-3.0.4-1.x86_64.rpm /tmp
COPY $DirSrc/fpc-src-3.0.4-1.x86_64.rpm /tmp

# Install all needed packages, including FreePascal
RUN yum install -y \
      https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN	yum update -y &&\
    yum install -y make automake mingw64-gcc mingw32-gcc gcc gcc-c++ zlib.i686 \
		  libxml2 openssl libxslt ncurses-libs.i686 xmlsec1-openssl /tmp/*.rpm

# Fix the "windres" not found problem
RUN ln -s /usr/bin/x86_64-w64-mingw32-windres /usr/bin/windres

# ACBr project use these symlinks 
WORKDIR /lib64
RUN test -e libxmlsec1.so \
    || ln -s libxmlsec1.so.1 libxmlsec1.so
RUN test -e libxmlsec1-openssl.so \
                || ln -s libxmlsec1-openssl.so.1 libxmlsec1-openssl.so
RUN test -e libxslt.so \
                || ln -s libxslt.so.1 libxslt.so
RUN test -e libxml2.so \
                || ln -s libxml2.so.2 libxml2.so
RUN test -e libexslt.so \
                || ln -s libexslt.so.0 libexslt.so
RUN test -e libssl.so \
                || ln -s libssl.so.1.0.2 libssl.so
RUN test -e libcrypto.so \
                || ln -s libcrypto.so.1.0.2 libcrypto.so
RUN /sbin/ldconfig

# Build compilers for another archtecture
WORKDIR /usr/share/fpcsrc/3.0.4
# Linux i386
RUN make build CPU_TARGET=i386 INSTALL_PREFIX=/usr &&\
    make crossinstall CPU_TARGET=i386 INSTALL_PREFIX=/usr &&\
		make clean
# Windows 64
RUN make build OS_TARGET=win64 CPU_TARGET=x86_64 INSTALL_PREFIX=/usr &&\
    make crossinstall OS_TARGET=win64 CPU_TARGET=x86_64 INSTALL_PREFIX=/usr &&\
		make clean
# Windows 32
RUN make build OS_TARGET=win32 CPU_TARGET=i386 INSTALL_PREFIX=/usr &&\
    make crossinstall OS_TARGET=win32 CPU_TARGET=i386 INSTALL_PREFIX=/usr &&\
		make clean

# Install Lazarus sources and compile the Lazbuild
ARG LazSrc=lazarus-1.8.4.tar.gz
ADD "$DirSrc"/"$LazSrc" /usr/lib64
RUN mkdir -p /etc/lazarus
ADD "$DirSrc"/environmentoptions.xml /etc/lazarus
RUN chown root.root -R /usr/lib64/lazarus /etc/lazarus
WORKDIR /usr/lib64/lazarus
RUN make clean &&\
    make lazbuild &&\
		ln -s "$PWD/lazbuild" /usr/bin/lazbuild

# Housekeeping
RUN yum clean all &&\
    find /usr/share/doc -type f -delete &&\
    find /usr/share/licenses -type f -delete &&\
		rm -f /tmp/*.rpm \
		      /tmp/*.tar.gz \
					/tmp/*.log \
					/usr/share/fpcsrc/3.0.4/compiler/*.exe

USER pascal
WORKDIR /home/pascal
