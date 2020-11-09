#!/usr/bin/env bash

# set -o errexit
set -o errtrace
set -o pipefail

### DEPENDENCIES CHECKS

if ! [ -x "$(command -v kubectl)" ]; then
  echo "Pre-flight check failed: kubectl is not installed."
  echo "Please install kubectl using https://kubernetes.io/docs/tasks/tools/install-kubectl/ and try again?" >&2
  exit 1
fi

function detectForMachine() {
# could be an inactive cluster so let's first check if we can use it:
  kubectl version &>/dev/null
  outcome=$?
  if [ $outcome -eq 0 ]; then
    # Note that the following is based on the command from the upstream docs, see:
    # https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/
    dhimages=()
    allimages=$(kubectl get pods --all-namespaces -o jsonpath="{..image}" | tr -s " " "\n" | sort -u)

    for i in ${allimages[*]}
    do
      if ! echo $i | awk -F '[/:]' '{print $1}' | grep -q '\.' ; then
          dhimages+=("$i")
      elif echo $i | grep -q docker.io ; then
          dhimages+=("$i")
      fi
    done
    
    if [[ ! -z "$dhimages" ]]; then
      for image in ${dhimages[*]}; do
        echo "$image"
      done
    fi
  fi
}

### MAIN

# obtain the name of the current cluster:
cluster=$(kubectl config current-context)

if [[ -z "$cluster" ]]; then
  echo "No cluster context configured, exiting."
  exit 2
fi

detectForMachine

