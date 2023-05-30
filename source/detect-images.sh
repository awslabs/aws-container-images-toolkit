#!/usr/bin/env bash

set -o errtrace
set -o pipefail

function detect() {

tdir=$(dirname $TARGET_DIR)/$(basename $TARGET_DIR)

# iterate over all Dockerfiles / Containerfiles and list images:
filelist=($(find ${tdir} -type f -name Dockerfile\* -o -name Containerfile\*))

# capture the public registry list
registrylist=$(cat public_registries.conf)

for dockerfile in ${filelist[*]}; do
  images=$(grep "^FROM" $dockerfile | grep -E -o [^[:space:]]+:[^[:space:]]+) 
  for image in $images; do
     for registry in $registrylist; do
      if ! echo $image | awk -F '[/:]' '{print $1}' | grep -q '\.'; then
        echo "$dockerfile $image"
        break
      elif echo $image | grep -q $registry ; then
        echo "$dockerfile $image"
        break
      fi
    done
  done
done
}

### MAIN
TARGET_DIR=${1:-$PWD}

detect
