# Amazon ECS

For Amazon ECS clusters, use the following script provided.
The script will output all publicly hosted docker images found in the clusters.

The script will use your current AWS CLI credentials to find ECS clusters and return a list of image names in alphabetical order.

```
$ ./detect-images.sh

arn:aws:ecs:us-west-2:123456789012:cluster/myECSCluster amazon/aws-xray-daemon
arn:aws:ecs:us-west-2:123456789012:cluster/exampleCluster amazon/aws-xray-daemon:latest
arn:aws:ecs:us-west-2:123456789012:cluster/exampleCluster nginx:latest
```

The script works with existing `aws` command and your current AWS CLI credentials.
If you would like to iterate over all configured AWS profiles then you can use a loop similar to the example below.

```
for prof in $(aws configure list-profiles); do
  export AWS_PROFILE=$prof && ./detect-images.sh \
    | sed "s/^/$prof /"
done

profile1 arn:aws:ecs:us-east-1:123456789012:cluster/myECSCluster amazon/aws-xray-daemon
profile1 arn:aws:ecs:us-east-1:123456789012:cluster/exampleCluster amazon/aws-xray-daemon:latest
profile1 arn:aws:ecs:us-east-1:123456789012:cluster/exampleCluster nginx:latest
profile2 arn:aws:ecs:us-west-2:123456789012:cluster/myDemoCluster adam9098/ecsdemo-crystal
profile2 arn:aws:ecs:us-west-2:123456789012:cluster/myDemoCluster adam9098/ecsdemo-frontend
profile2 arn:aws:ecs:us-west-2:123456789012:cluster/myDemoCluster brentley/ecsdemo-nodejs:cdk
```

If you have multiple regions or AWS profiles with clusters you can also use additional for loops to get containers from all your clusters.

```
for prof in $(aws configure list-profiles); do
  export AWS_PROFILE=$prof
  for region in us-east-1 eu-west-1 us-west-2; do
    export AWS_REGION=$region && ./detect-images.sh \
    | sed "s/^/$prof $region /"
  done
done

profileStg us-east-1 arn:aws:ecs:us-east-1:123456789012:cluster/myDemoCluster httpd:2.4
profileStg us-east-1 arn:aws:ecs:us-east-1:123456789012:cluster/myDemoCluster nginx:latest
profileStg us-west-2 arn:aws:ecs:us-west-2:123456789012:cluster/myWebServiceCluster adam9098/ecsdemo-crystal
profileStg us-west-2 arn:aws:ecs:us-west-2:123456789012:cluster/myWebServiceCluster adam9098/ecsdemo-frontend
profileStg us-west-2 arn:aws:ecs:us-west-2:123456789012:cluster/myWebServiceCluster brentley/ecsdemo-nodejs:cdk
profileProd us-west-2 arn:aws:ecs:us-west-2:210987654321:cluster/myWebServiceCluster adam9098/ecsdemo-crystal
profileProd us-west-2 arn:aws:ecs:us-west-2:210987654321:cluster/myWebServiceCluster adam9098/ecsdemo-frontend
profileProd us-west-2 arn:aws:ecs:us-west-2:210987654321:cluster/myWebServiceCluster brentley/ecsdemo-nodejs:cdk
```

Note that at the current point we filter images based on detecting
a FQDN in the first field of the image name except `docker.io`. This may not be a perfect
matching strategy, but we hope it will work for the large majority of cases.
