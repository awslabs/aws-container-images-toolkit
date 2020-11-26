#!/usr/bin/env bash
set -eu

function listEcsClusters() {
    starting_token=$1

    cmd="aws ecs list-clusters --max-items 30 --output json --query={NextToken:NextToken,clusterArns:clusterArns[*]}"
    if [[ "x$starting_token" = "x" ]]; then
        output=$($cmd)
    else
        output=$($cmd --starting-token $starting_token)  
    fi
    echo $output
}

function listEcsTasksInCluster() {
    cluster=$1
    starting_token=$2

    cmd="aws ecs list-tasks --cluster $cluster --max-items 100 --output json --query={NextToken:NextToken,taskArns:taskArns[*]}"
    if [[ "x$starting_token" = "x" ]]; then
        output=$($cmd)
    else
        output=$($cmd --starting-token $starting_token)  
    fi
    echo $output
}

clusters=""
next_token=""
while [[ ! "x$next_token" = "xnull" ]]
do
    output=$(listEcsClusters "$next_token")
    next_token=$(echo $output | grep -Eo '"NextToken": [^,]*' | grep -Eo '[^ :]*$' | sed 's/"//g')
    cluster_arns=$(echo $output | grep -Eo '"clusterArns": \[.*\]' | grep -Eo '"arn:[^,]*"' | sed 's/"//g')
    clusters="$cluster_arns $clusters"
done

if [[ -z "${clusters// }" ]]; then
    exit 0
fi

for cluster in $clusters; do
    cluster_images=""
    next_token=""
    while [[ ! "x$next_token" = "xnull" ]]
    do
        output=$(listEcsTasksInCluster $cluster "$next_token")
        next_token=$(echo $output | grep -Eo '"NextToken": [^,]*' | grep -Eo '[^ :]*$' | sed 's/"//g')
        task_arns=$(echo $output | grep -Eo '"taskArns": \[.*\]' | grep -Eo '"arn:[^,]*"' | sed 's/"//g' || echo "")
        if [[ -z "$task_arns" ]]; then
            break
        fi
        task_images=$(aws ecs describe-tasks --cluster $cluster --tasks $task_arns --query="tasks[].containers[].image | sort(@) | join(' ', @)" --output text)
        cluster_images="$task_images $cluster_images"
    done

    images=$(echo $cluster_images | tr -s " " "\n" | sort -u)
    dhimages=()

    for i in ${images[*]};
    do
        if ! echo $i | awk -F '[/:]' '{print $1}' | grep -q '\.' ; then
            dhimages+=("$i")
        elif echo $i | grep -q docker.io ; then
            dhimages+=("$i")
        fi
    done

    if [[ ! -z "${dhimages[*]+"${dhimages[*]}"}" ]]; then
        for image in ${dhimages[*]}; do
            echo "$cluster $image"
        done
    fi
done
