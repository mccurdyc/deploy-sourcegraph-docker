#!/usr/bin/env bash
set -e
source ./replicas.sh

# Description: Handles repository metadata (not Git data) lookups and updates from external code hosts and other similar services.
#
# Disk: 128GB / non-persistent SSD
# Network: 100mbps
# Liveness probe: n/a
# Ports exposed to other Sourcegraph services: 3182/TCP 6060/TCP
# Ports exposed to the public internet: none
#
VOLUME="$HOME/sourcegraph-docker/repo-updater-disk"
./ensure-volume.sh $VOLUME 100
docker run --detach \
    --name=repo-updater \
    --network=sourcegraph \
    --restart=always \
    --cpus=4 \
    --memory=4g \
    -e GOMAXPROCS=1 \
    -e SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090 \
    -e JAEGER_AGENT_HOST=jaeger \
    -e GITHUB_BASE_URL=http://github-proxy:3180 \
    -v $VOLUME:/mnt/cache \
    index.docker.io/sourcegraph/repo-updater:3.21.0@sha256:47b9aef0d635aa78c5f249227b8107f5f09d60003c74fbe85f9a5af21a489922

echo "Deployed repo-updater service"
