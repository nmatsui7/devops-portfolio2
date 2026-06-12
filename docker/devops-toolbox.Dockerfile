FROM ubuntu:24.04

ARG TARGETARCH
ARG KUBECTL_VERSION=v1.30.6
ARG HELM_VERSION=v3.16.3
ARG ARGOCD_VERSION=v2.13.1
ARG K6_VERSION=v0.55.0
ARG TRIVY_VERSION=0.57.1
ARG YQ_VERSION=v4.44.5

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ansible \
        ansible-lint \
        bash \
        ca-certificates \
        curl \
        git \
        gnupg \
        jq \
        less \
        python3 \
        python3-pip \
        shellcheck \
        unzip \
        yamllint \
    && rm -rf /var/lib/apt/lists/*

RUN BUILD_ARCH="${TARGETARCH:-$(dpkg --print-architecture)}" \
    && case "${BUILD_ARCH}" in \
        amd64) export TOOL_ARCH=amd64 TRIVY_ARCH=64bit ;; \
        arm64) export TOOL_ARCH=arm64 TRIVY_ARCH=ARM64 ;; \
        *) echo "Unsupported architecture: ${BUILD_ARCH}" >&2; exit 1 ;; \
    esac \
    && curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TOOL_ARCH}/kubectl" -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TOOL_ARCH}.tar.gz" -o /tmp/helm.tar.gz \
    && tar -xzf /tmp/helm.tar.gz -C /tmp \
    && install -m 0755 "/tmp/linux-${TOOL_ARCH}/helm" /usr/local/bin/helm \
    && curl -fsSL "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-${TOOL_ARCH}" -o /usr/local/bin/argocd \
    && chmod +x /usr/local/bin/argocd \
    && curl -fsSL "https://github.com/grafana/k6/releases/download/${K6_VERSION}/k6-${K6_VERSION}-linux-${TOOL_ARCH}.tar.gz" -o /tmp/k6.tar.gz \
    && tar -xzf /tmp/k6.tar.gz -C /tmp \
    && install -m 0755 "/tmp/k6-${K6_VERSION}-linux-${TOOL_ARCH}/k6" /usr/local/bin/k6 \
    && curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-${TRIVY_ARCH}.tar.gz" -o /tmp/trivy.tar.gz \
    && tar -xzf /tmp/trivy.tar.gz -C /tmp trivy \
    && install -m 0755 /tmp/trivy /usr/local/bin/trivy \
    && curl -fsSL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${TOOL_ARCH}" -o /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq \
    && rm -rf /tmp/helm.tar.gz /tmp/linux-${TOOL_ARCH} /tmp/k6.tar.gz /tmp/k6-${K6_VERSION}-linux-${TOOL_ARCH} /tmp/trivy.tar.gz /tmp/trivy

WORKDIR /workspace

CMD ["/bin/bash"]
