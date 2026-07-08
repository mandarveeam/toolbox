# -----------------------------------------------------------------------------
# OpenShift Toolbox with ttyd
# -----------------------------------------------------------------------------

FROM python:3.12-slim-bookworm

ARG OC_VERSION=4.19.4
ARG HELM_VERSION=v3.19.0
ARG TTYD_VERSION=1.7.7

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /home/toolbox

# -----------------------------------------------------------------------------
# Install packages
# -----------------------------------------------------------------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        curl \
        wget \
        git \
        vim \
        nano \
        less \
        jq \
        unzip \
        zip \
        tar \
        ca-certificates \
        openssl \
        python3-pip && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Install OpenShift CLI (oc + kubectl)
# -----------------------------------------------------------------------------

RUN curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_VERSION}/openshift-client-linux-${OC_VERSION}.tar.gz \
    | tar -xz -C /usr/local/bin oc kubectl && \
    chmod +x /usr/local/bin/oc /usr/local/bin/kubectl

# -----------------------------------------------------------------------------
# Install Helm
# -----------------------------------------------------------------------------

RUN curl -fsSL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
    | tar -xz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf linux-amd64

# -----------------------------------------------------------------------------
# Install ttyd
# -----------------------------------------------------------------------------

RUN wget -O /usr/local/bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

# -----------------------------------------------------------------------------
# Python packages
# -----------------------------------------------------------------------------

RUN pip install --no-cache-dir \
        yq \
        pyyaml

# -----------------------------------------------------------------------------
# Create user
# -----------------------------------------------------------------------------

RUN useradd -m -s /bin/bash toolbox

USER toolbox

WORKDIR /home/toolbox

EXPOSE 7681

CMD ["ttyd", "-W", "-p", "7681", "-t", "fontSize=22", "bash"]
