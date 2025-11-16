#!/bin/bash -e

. env.sh

docker compose --ansi "never" up -d

exit 0
