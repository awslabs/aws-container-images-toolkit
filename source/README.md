# From source

If you have a directory that contains files named `Dockerfile*`, for example in a Git repo, you can use the following script provided.

The script will recurse the target directory, looking for `Dockerfile*` and probe them for `FROM xxx` statements and list all container images hosted on Docker Hub.
This assumes any referenced images have an associated tag. 

For example, `amazonlinux:2` or `amazonlinux:latest` will be discovered. `amazonlinux` will be missed.

The script will print out Dockerfile location and image on each line.
If a Dockerfile has multiple `FROM` images each one will be printed.

## Examples

Run the script to recursively detech Dockerfiles in your current directory.

```
./detect-images.sh

./Dockerfile golang:1.15.0
./Dockerfile golangci/golangci-lint:v1.27-alpine
./Dockerfile amazonlinux:2
```

Optionally you can provide a directory you would like the script to search

```
./detect-images.sh ~/src/aws-load-balancer-controller

/home/user/src/aws-load-balancer-controller/Dockerfile golang:1.15.0
/home/user/src/aws-load-balancer-controller/Dockerfile golangci/golangci-lint:v1.27-alpine
/home/user/src/aws-load-balancer-controller/Dockerfile amazonlinux:2
```