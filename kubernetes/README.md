# Kubernetes

For Kubernetes clusters such as Amazon EKS, use the following script provided.
The script will output all publicly hosted docker images found in the cluster.

The script will use your current kubectl context and return a list of image names in alphabetical order.

```
$ ./detect-images.sh

grafana/grafana:6.0.0
mongo
prom/alertmanager:v0.20.0
prom/node-exporter:v0.18.1
prom/prometheus:v2.17.2
rabbitmq:3.6.8
redis:alpine
sentry:9.1.2
```

The script works with existing `kubectl` and your current `KUBECONFIG` and context.
If you keep separate files for your clusters you can combine them into one `KUBECONFIG` variable with colon separators.

```
export KUBECONFIG=$HOME/.kube/config:$HOME/.kube/eksctl/clusters/cluster1
```

If you would like to iterate over all contexts in your `KUBECONFIG` then you can use a loop similar to the example below.

```
for CONTEXT in $(kubectl config get-contexts --output name); do
  kubectl config use-context $CONTEXT >/dev/null && ./detect-images.sh \
    | sed "s/^/$CONTEXT /"
done

admin@cluster1.us-west-2.eksctl.io grafana/grafana:6.0.0
admin@cluster1.us-west-2.eksctl.io mongo
admin@cluster1.us-west-2.eksctl.io prom/alertmanager:v0.20.0
admin@cluster1.us-west-2.eksctl.io prom/node-exporter:v0.18.1
admin@cluster1.us-west-2.eksctl.io prom/prometheus:v2.17.2
admin@cluster1.us-west-2.eksctl.io rabbitmq:3.6.8
admin@cluster1.us-west-2.eksctl.io redis:alpine
admin@cluster1.us-west-2.eksctl.io sentry:9.1.2
```

If you have multiple regions or AWS profiles with clusters you can also use additional for loops to get containers from all your clusters.
Clusters that cannot be reached will silently fail.

```
for AWS_PROFILE in stage prod dev; do
  for AWS_REGION in us-east-1 us-west-2; do
    for CONTEXT in $(kubectl config get-contexts --output name); do
      kubectl config use-context $CONTEXT >/dev/null && ./detect-images.sh \
        | sed "s/^/$AWS_PROFILE $AWS_REGION $CONTEXT /"
    done
  done
done

stage us-west-2 admin@cluster1.us-west-2.eksctl.io grafana/grafana:6.0.0
stage us-west-2 admin@cluster1.us-west-2.eksctl.io mongo
stage us-west-2 admin@cluster1.us-west-2.eksctl.io prom/alertmanager:v0.20.0
stage us-west-2 admin@cluster1.us-west-2.eksctl.io prom/node-exporter:v0.18.1
stage us-west-2 admin@cluster1.us-west-2.eksctl.io prom/prometheus:v2.17.2
stage us-west-2 admin@cluster1.us-west-2.eksctl.io rabbitmq:3.6.8
stage us-west-2 admin@cluster1.us-west-2.eksctl.io redis:alpine
stage us-west-2 admin@cluster1.us-west-2.eksctl.io sentry:9.1.2
```

Note that at the current point we filter images based on detecting
a FQDN in the first field of the image name. This may not be a perfect
matching strategy, but we hope it will work for the large majority of cases.
