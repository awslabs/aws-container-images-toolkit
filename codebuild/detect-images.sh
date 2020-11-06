#!/usr/bin/env bash
set -eu

function listCodeBuildProjects() {
    starting_token=$1

    cmd="aws codebuild list-projects --sort-by NAME --sort-order ASCENDING --max-items 30 --output json --query={NextToken:NextToken,projects:projects[*]}"
    if [[ "x$starting_token" = "x" ]]; then
        output=$($cmd)
    else
        output=$($cmd --starting-token $starting_token)  
    fi
    echo $output
}

project_names=""
next_token=""
while [[ ! "x$next_token" = "xnull" ]]
do
    output=$(listCodeBuildProjects "$next_token")
    next_token=$(echo $output | grep -Eo '"NextToken": [^,]*' | grep -Eo '[^ :]*$' | sed 's/"//g')
    projects=$(echo $output | grep -Eo '"projects": \[.*\]' | sed 's/"projects": \[//g' | grep -Eo '"[^,]*"' | sed 's/"//g')
    project_names="$projects $project_names"
done

if [[ -z "${project_names// }" ]]; then
    exit 0
fi

for project in $project_names; do
    images=$(aws codebuild batch-get-projects --names "$project" --query="projects[].environment | [?!(starts_with(image,'aws/codebuild/'))].image | sort(@) | join(' ', @)" --output text)
    dhimages=()
    for i in ${images[*]};
    do
        if ! echo $i | awk -F '[/:]' '{print $1}' | grep -q '\.' ; then
            dhimages+=("$i")
        elif echo $i | grep -q docker.io ; then
            dhimages+=("$i")
        fi
    done

    if [[ ! -z "${dhimages[@]+"${dhimages[@]}"}" ]]; then
        for image in ${dhimages[*]}; do
            echo "$project $image"
        done
    fi
done
