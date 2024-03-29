FROM alpine:3.8

ARG CLOUD_SDK_VERSION=258.0.0
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION

ENV TERRAFORM_VERSION=0.12.7
ENV KUBERNETES_VERSION=v1.13.7
ENV AUTHENTICATOR_VERSION=1.13.7
ENV HELM_VERSION=v2.14.3
ENV ISTIO_VERSION=1.2.4

# Defaults with certs
RUN set -x && \
    apk add --no-cache curl ca-certificates

# Install dependencies
RUN apk add wget && \
    apk add unzip && \
    apk add make && \
    apk add openssh && \
    apk -Uuv add groff less python py-pip && \
    apk add --no-cache gnupg && \
    apk add --no-cach libc6-compat


# Install gcloud
ENV PATH /google-cloud-sdk/bin:$PATH
RUN apk --no-cache add \
        curl \
        python \
        py-crcmod \
        bash \
        libc6-compat \
        openssh-client \
        git \
        gnupg

RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version

# Install aws-cli
RUN pip install awscli && \
    apk --purge -v del py-pip && \
    rm /var/cache/apk/* && \
    aws --version

# Install fly for concourse
RUN curl -o fly http://concourse.algotrade.net/api/v1/cli?arch=amd64&platform=linux && \
    mv ./fly /usr/local/bin/fly && \
    chmod 0777 /usr/local/bin/fly

# Install aws-iam-authenticator
RUN curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/${AUTHENTICATOR_VERSION}/2019-06-11/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x ./aws-iam-authenticator && \
    cp ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator && \
    echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc && \
    rm ./aws-iam-authenticator && \
    aws-iam-authenticator help

# Install Terraform
RUN curl -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    terraform --version

# Install kubectl
RUN curl -o kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    cp ./kubectl /usr/local/bin/kubectl && \
    rm ./kubectl && \
    kubectl version --client

# Install helm
RUN curl -o helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -xvf helm.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf linux-amd64/ && \
    chmod +x /usr/local/bin/helm && \
    helm version --client

# Install istio
RUN curl -L https://git.io/getLatestIstio | ISTIO_VERSION=${ISTIO_VERSION} sh - && \
    mv istio-${ISTIO_VERSION}/bin/istioctl /usr/local/bin/ && \
    rm -rf istio-${ISTIO_VERSION}

# Set workdir to infrastructure directory
WORKDIR /var/infrastructure
