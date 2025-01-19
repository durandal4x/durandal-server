#!/usr/bin/env bash
docker run -v $(pwd):/opt/build --rm -it durandal:latest /opt/build/bin/build

