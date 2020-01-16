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

# Install all needed packages, including FreePascal
RUN zypper addrepo -G 'https://download.opensuse.org/repositories/windows:mingw:win32/openSUSE_Leap_15.1/windows:mingw:win32.repo' &&\
    zypper addrepo -G 'https://download.opensuse.org/repositories/windows:mingw:win64/openSUSE_Leap_15.1/windows:mingw:win64.repo' &&\
    zypper --non-interactive in --allow-unsigned-rpm --no-recommends make \
		  automake mingw32-cross-gcc mingw64-cross-gcc zlib libxml2 binutils openssl \
		  libxslt libncurses6 libxmlsec1-openssl1 mingw64-gcc libopenssl1_0_0 libXtst6\
      glibc-devel gcc gcc-c++ \
      https://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20x86_64%20RPM/Lazarus%201.8.4/fpc-src-3.0.4-1.x86_64.rpm \
      https://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20x86_64%20RPM/Lazarus%201.8.4/fpc-3.0.4-1.x86_64.rpm &&\
    zypper download atk-devel cairo-devel damageproto-devel dbus-1-x11 \
      desktop-file-utils fixesproto-devel fontconfig fontconfig-devel \
			freetype2-devel gdk-pixbuf-devel gdk-pixbuf-query-loaders girepository-1_0 \
			glib2-devel glib2-tools graphite2-devel gtk2-devel gtk2-tools \
			harfbuzz-devel kbproto-devel libX11-devel libX11-xcb1 libXau-devel \
			libXcomposite1 libXcursor1 libXdamage-devel libXdamage1 libXext-devel \
			libXfixes-devel libXfixes3 libXft-devel libXft2 libXi6 libXinerama1 \
			libXrandr2 libXrender-devel libXrender1 libXxf86vm-devel libXxf86vm1 \
      libatk-1_0-0 libavahi-client3 libavahi-common3 libbz2-devel \
			libcairo-gobject2 libcairo-script-interpreter2 libcairo2 libcups2 \
			libdatrie1 libdbus-1-3 libdrm-devel libdrm2 libedit0 libexpat-devel \
			libexpat1 libfreetype6 libgbm1 libgdk_pixbuf-2_0-0 libgio-2_0-0 \
			libgirepository-1_0-1 libglib-2_0-0 libglvnd libglvnd-devel \
			libgmodule-2_0-0 libgobject-2_0-0 libgraphite2-3 libgthread-2_0-0 \
      libgtk-2_0-0 libharfbuzz-icu0 libharfbuzz0 libicu-devel libicu60_2 \
      libicu60_2-ledata libjbig2 libjpeg8 libpango-1_0-0 libpciaccess0 \
			libpcre16-0 libpcrecpp0 libpcreposix0 libpixman-1-0 libpixman-1-0-devel \
			libpng16-16 libpng16-compat-devel libpng16-devel libpython3_6m1_0 \
			libstdc++-devel libthai-data libthai0 libtiff5 libxcb-composite0 \
			libxcb-damage0 libxcb-devel libxcb-dpms0 libxcb-dri2-0 libxcb-dri3-0 \
			libxcb-glx0 libxcb-present0 libxcb-randr0 libxcb-record0 libxcb-render0 \
			libxcb-res0 libxcb-screensaver0 libxcb-shape0 libxcb-shm0 libxcb-sync1 \
			libxcb-xf86dri0 libxcb-xfixes0 libxcb-xinerama0 libxcb-xinput0 libxcb-xkb1 \
			libxcb-xtest0 libxcb-xv0 libxcb-xvmc0 libxshmfence1 pango-devel pcre-devel \
			pkg-config pthread-stubs-devel python-rpm-macros python3-base \
			renderproto-devel typelib-1_0-Atk-1_0 typelib-1_0-GdkPixbuf-2_0 \
			typelib-1_0-Gtk-2_0 typelib-1_0-Pango-1_0 xextproto-devel \
			xf86vidmodeproto-devel xproto-devel zlib-devel &&\
    find /var/cache/zypp/packages -type f -exec rpm -i --nodeps --excludedocs --nofiledigest --noscripts --notriggers {} \; &&\
    zypper cc -a &&\
    rm -rf /usr/share/fpcsrc/3.0.4/compiler/*.exe \
      /usr/share/doc/* \
      /usr/share/gtk-doc/* \
      /usr/share/info/* \
      /usr/share/man/* \
      /usr/share/pkgconfig/* \
      /var/cache/zypp/packages \
      /usr/share/licenses/* 

# Fix the "windres" not found problem
RUN ln -s /usr/bin/x86_64-w64-mingw32-windres /usr/bin/windres

# ACBr project use these symlinks 
WORKDIR /usr/lib64
RUN test -e libxmlsec1.so \
      || ln -s libxmlsec1.so.1 libxmlsec1.so &&\
    test -e libxmlsec1-openssl.so \
      || ln -s libxmlsec1-openssl.so.1 libxmlsec1-openssl.so &&\
    test -e libxslt.so \
      || ln -s libxslt.so.1 libxslt.so &&\
    test -e libxml2.so \
      || ln -s libxml2.so.2 libxml2.so &&\
    test -e libexslt.so \
      || ln -s libexslt.so.0 libexslt.so &&\
    test -e libssl.so \
      || ln -s libssl.so.1.0.2 libssl.so &&\
    test -e libcrypto.so \
      || ln -s libcrypto.so.1.0.2 libcrypto.so &&\
    /sbin/ldconfig

# Build compilers for another archtecture
ADD "$DirSrc"/fpc.cfg /etc
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
RUN ln -s /usr/lib/fpc/3.0.4/ppcross386 /usr/bin/ppcross386 &&\
    ln -s /usr/lib/fpc/3.0.4/ppcrossx64 /usr/bin/ppcrossx64

# Install Lazarus sources and compile the Lazbuild
ARG LazSrc=lazarus-1.8.4.tar.gz
ADD "$DirSrc"/"$LazSrc" /usr/lib64
RUN mkdir -p /etc/lazarus
ADD "$DirSrc"/environmentoptions.xml /etc/lazarus
RUN chown root.root -R /usr/lib64/lazarus /etc/lazarus
WORKDIR /usr/lib64/lazarus
RUN make clean &&\
    make lazbuild &&\
		make clean &&\
		ln -s "$PWD/lazbuild" /usr/bin/lazbuild

USER pascal
WORKDIR /home/pascal
