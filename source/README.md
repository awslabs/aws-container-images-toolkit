# From source

If you have a directory that contains files named `Dockerfile*`, for example in a Git repo,
you can use the following script provided.

The script will recurse the target directory, looking for `Dockerfile*` and probe them for `FROM xxx` statements
and list all container images hosted on Docker Hub. This assumes any referenced images have an associated tag. 

For example, `amazonlinux:2` or `amazonlinux:latest` will be discovered. `amazonlinux` will be missed.

And example usage (with the tests in this repo) looks as follows:

```
$ ./detect-images.sh test/
Now scanning directory ./test to find container images hosted in Docker Hub.

Looking at: ./test/Dockerfile.go-app
Results:
  golang:1.14
===

Looking at: ./test/Dockerfile.go-app-multi-stage
Results:
  golang:1.7.3
  alpine:latest
===

Looking at: ./test/Dockerfile.jessie-node
Results:
  buildpack-deps:jessie
===

Looking at: ./test/Dockerfile.k8s-apiserver
===

Looking at: ./test/Dockerfile.ubuntu-postgresql
Results:
  ubuntu:16.04
===

DONE!
```



