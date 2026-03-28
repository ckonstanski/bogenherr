#!/bin/bash -e

. env.sh

builddir='tmp'
container='bogenherr'

rm -rf ${builddir}
mkdir ${builddir}
rsync -aq data ${builddir}
pushd ${builddir} 2>/dev/null

tar Jcvf docker-start.tar.xz data/
docker stop ${container} || true
docker container prune -f
docker rmi --force ${container} || true

DOCKER_BUILDKIT=0 docker compose \
    --progress "plain" \
    --ansi "never" \
    build \
    --no-cache \
    --pull

popd 2>/dev/null
rm -rf tmp

exit 0
