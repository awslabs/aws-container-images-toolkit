# AWS CodeBuild

For AWS CodeBuild projects, use the following script provided.
The script will output all publicly hosted docker images found in the projects.

The script will use your current AWS CLI credentials to find CodeBuild projects and return a list of image names.

```
$ ./detect-images.sh

my-cb-project-1 toricls/everlasting-hey-yo:latest
my-cb-project-2 toricls/everlasting-hey-yo:custom
```

The script works with existing `aws` command and your current AWS CLI credentials.
If you would like to iterate over all configured AWS profiles then you can use a loop similar to the example below.

```
for prof in $(aws configure list-profiles); do
  export AWS_PROFILE=$prof && ./detect-images.sh \
    | sed "s/^/$prof /"
done

profile1 my-cb-project-1 toricls/everlasting-hey-yo:latest
profile1 my-cb-project-2 toricls/everlasting-hey-yo:custom
profile2 another-cb-project docker:dind
```

If you have multiple regions or AWS profiles with projects you can also use additional for loops to get containers from all your projects.

```
for prof in $(aws configure list-profiles); do
  export AWS_PROFILE=$prof
  for region in us-east-1 eu-west-1 us-west-2; do
    export AWS_REGION=$region && ./detect-images.sh \
    | sed "s/^/$prof $region /"
  done
done

profileDev us-east-1 my-cb-project docker:dind
profileStg us-east-1 another-cb-project docker:dind
profileStg us-west-2 another-cb-project docker:dind
profileProd us-east-1 another-cb-project docker:dind
profileProd us-west-2 another-cb-project docker:dind
```

Note that at the current point we filter images based on detecting
a FQDN in the first field of the image name except `docker.io`. This may not be a perfect
matching strategy, but we hope it will work for the large majority of cases.
