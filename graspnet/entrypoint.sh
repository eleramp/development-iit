#!/bin/bash
set -eu -o pipefail

if [ ! -x "$(which setup_gpnet.sh)" ] ; then
    echo "==> File setup_gpnet.sh not found."
    exit 1
fi

# Initialize the container
echo "==> Configuring Graspnet image"
setup_gpnet.sh
echo "==> Graspnet container ready"

# If a CMD is passed, execute it
echo "== execute command $@"
exec "$@"
