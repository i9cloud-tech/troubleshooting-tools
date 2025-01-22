# Tools for k8s troubleshooting

### init.deployment.sh

script that easily creates a deployment file, it receives two parameters
which is the deployment name and image.

**How to use**

```sh
./init.deployment.sh my-app public.ecr.aws/q0a7a5m8/amicci-aws-eks:v1.3
```

### debug-k8s.deployment.yaml

an empty deployment that give you an easy access to an bash console with root access.

Using the docker image: `public.ecr.aws/q0a7a5m8/amicci-aws-eks:v1.3`
you will have awscli, kubectl, helm and argocdcli installed.
