FROM opensuse/leap:15.1
LABEL maintainer 'Tiago Tarifa Munhoz <tiagomunhoz@djsystem.com.br>'

# Metadados da imagem 
LABEL author="Tiago Tarifa Munhoz <tiagomunhoz@djsystem.com.br>"
ARG BUILD_DATE
ARG COMMIT
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="lazbuild cross-compiler" \
      org.label-schema.description="It's compile a lazarus/freepascal project for linux and windows x86 and x86_64" \
      org.label-schema.version=$VERSION \
      org.label-schema.commit="$COMMIT" \
      org.label-schema.schema-version="1.0"

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

#gcc gcc-c++ 
# Install all needed packages, including FreePascal
RUN zypper addrepo -G 'https://download.opensuse.org/repositories/windows:mingw:win32/openSUSE_Leap_15.1/windows:mingw:win32.repo' &&\
		zypper addrepo -G 'https://download.opensuse.org/repositories/windows:mingw:win64/openSUSE_Leap_15.1/windows:mingw:win64.repo' &&\
		zypper --non-interactive in --allow-unsigned-rpm make automake \
		  mingw32-cross-gcc mingw64-cross-gcc zlib libxml2 binutils \
			openssl libxslt libncurses6 libxmlsec1-openssl1 mingw64-gcc \
			libopenssl1_0_0 libXtst6 gdk-pixbuf-devel atk-devel cairo-devel \
			libX11-devel gtk2-devel glib2-devel pango-devel libgdk_pixbuf-2_0-0 \
			libgtk-2_0-0 libgobject-2_0-0 glib2 libgthread-2_0-0 libgmodule-2_0-0 \
			libpango-1_0-0 libcairo2 libatk-1_0-0 \
			https://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20x86_64%20RPM/Lazarus%201.8.4/fpc-src-3.0.4-1.x86_64.rpm \
			https://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20x86_64%20RPM/Lazarus%201.8.4/fpc-3.0.4-1.x86_64.rpm &&\
		find /var/cache/zypp/packages -type f -exec rpm -i -v --nodeps {} \; &&\
    find /usr/share/doc -type f -delete &&\
    find /usr/share/man -type f -delete &&\
    find /usr/share/pkgconfig -type f -delete &&\
    find /usr/share/licenses -type f -delete &&\
		zypper cc -a &&\
		rm -rf /usr/share/fpcsrc/3.0.4/compiler/*.exe \
		  /usr/share/gtk-doc/* \
			/usr/share/info/*

# Fix the "windres" not found problem
RUN ln -s /usr/bin/x86_64-w64-mingw32-windres /usr/bin/windres

# ACBr project use these symlinks 
WORKDIR /usr/lib64
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

USER pascal
WORKDIR /home/pascal
