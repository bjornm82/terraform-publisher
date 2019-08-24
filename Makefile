AWS_PROFILE ?= personal

ORG ?= bjornmooijekind
REPO ?= terraform-publisher
VERSION ?= 0.1.0

.PHONY: build
build:
	docker build -t ${ORG}/${REPO}:${VERSION} .

.PHONY: run
run:
	docker run -it --rm \
	--name infra \
	-e AWS_ACCESS_KEY_ID=$$(aws configure get aws_access_key_id --profile ${AWS_PROFILE}) \
	-e AWS_SECRET_ACCESS_KEY=$$(aws configure get aws_secret_access_key --profile ${AWS_PROFILE}) \
	-e AWS_DEFAULT_REGION=$$(aws configure get region --profile ${AWS_PROFILE}) \
	-e CLIENT_ID=${CLIENT_ID} \
	-p 8001:8001 \
	-p 8200:8200 \
	--mount src=$(PWD),target=/var/infrastructure,type=bind \
	${ORG}/${REPO}:${VERSION} /bin/sh

docker-push:
	docker push ${ORG}/${REPO}:${VERSION}
