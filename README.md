# terraform-publisher

This small project should help to setup an environment with all the tooling needed
in order to create an `EKS` cluster with `Terraform` together with the ability to use
`kubectl`, `helm` and `istio` commands

A docker run container with:
* aws-authenticator
* terraform
* kubectl
* helm
* istio

## Getting started

`make build` with the replacement of following fields, whereas ORG / REPO and
VERSION are related to docker hub.

* AWS_PROFILE
* ORG
* REPO
* VERSION

cd to your terraform project and run the following command:
```
docker run -it --rm \
  --name ${REPO} \
  -e AWS_ACCESS_KEY_ID=$$(aws configure get aws_access_key_id --profile ${AWS_PROFILE}) \
  -e AWS_SECRET_ACCESS_KEY=$$(aws configure get aws_secret_access_key --profile ${AWS_PROFILE}) \
  -e AWS_DEFAULT_REGION=$$(aws configure get region --profile ${AWS_PROFILE}) \
  -e CLIENT_ID=${CLIENT_ID} \
  -p 8001:8001 \
  --mount src=$(PWD),target=/var/infrastructure,type=bind \
  ${ORG}/${REPO}:${VERSION} /bin/sh
```

Port 8001 is exposed so you can proxy the k8s dashboard if needed
