#!/bin/bash
Ver=1.1
docker image build \
  -t djsystem/lazbuild-2.0.12:latest \
  -t djsystem/lazbuild-2.0.12:$Ver \
  -f centos.dockerfile \
  --build-arg "BUILD_DATE=$(date)" \
  --build-arg "DESCRIPTION=It can build a software made in Lazarus for CentOS 8" \
  --build-arg "COMMIT=Fix lack of xmlsec1 symbolic link" \
  --build-arg "VERSION=$Ver" \
  --no-cache .
