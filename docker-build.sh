#!/bin/bash

if ! docker start melondev; then
    echo "Container not found, creating..."
    (docker run --rm --name melondev --mount type=bind,source=${PWD},target=/melonos melonos-dev ./build.sh)
    run_status=$?
fi