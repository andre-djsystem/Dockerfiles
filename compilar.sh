#!/bin/bash
Imagens="\
lazbuild182:lazarus-1.8.2.tar.gz
lazbuild184:lazarus-1.8.4.tar.gz
lazbuild204:lazarus-2.0.4.tar.gz
lazbuild206:lazarus-2.0.6.tar.gz"
BUILD_DATE="$(date)"

VERSION='1.4'
COMMIT="Added support to lazarus 1.8.2 too. Changed description label."
Tags=''

for dist in centos opensuse; do
  while read linha; do
  	docker image build \
  		-t djsystem/${linha%%:*}-"$dist:$VERSION" \
  		-t djsystem/${linha%%:*}-"$dist":latest \
  		-f ./lazbuild/fpc-3.0.4_based/"$dist".dockerfile \
      --build-arg BUILD_DATE="$BUILD_DATE" \
  		--build-arg COMMIT="$COMMIT" \
  		--build-arg VERSION="$VERSION" \
  		--build-arg LazSrc=${linha##*:} \
  		--build-arg DirSrc=./sources .
    Tags="$Tags djsystem/${linha%%:*}-$dist:$VERSION djsystem/${linha%%:*}-$dist:latest"
  done <<<"$Imagens"
done

echo "$Tags"
