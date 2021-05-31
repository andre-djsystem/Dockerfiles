#!/bin/bash
Ver=1.7
docker image build \
  -t djsystem/dockins:latest \
  -t djsystem/dockins:$Ver \
  -f Dockerfile \
  --build-arg "BUILD_DATE=$(date)" \
  --build-arg "DESCRIPTION=Jenkins version with Docker-in-Docker." \
  --build-arg "COMMIT=Jenkins updated." \
  --build-arg "VERSION=$Ver" \
  --no-cache .
