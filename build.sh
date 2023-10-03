#!/usr/bin/env bash

set -ex

# username of the docker hub or if you are using a different registry repo.
USERNAME=nascenia

# image name
IMAGE=timetrackr

docker build --compress  -t $USERNAME/$IMAGE:latest .