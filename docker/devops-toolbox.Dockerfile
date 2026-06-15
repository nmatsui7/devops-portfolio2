FROM ubuntu:24.04

ARG TARGETARCH
ARG KUBECTL_VERSION=v1.30.6
ARG HELM_VERSION=v3.16.3
ARG ARGOCD_VERSION=v2.13.1
ARG K6_VERSION=v1.7.1
ARG TRIVY_VERSION=0.71.1
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

# CLI versions are pinned for reproducibility. If a build fails with curl exit
# code 22, one of the upstream release URLs may have changed or become
# unavailable; echoing each URL makes the failing download visible.
RUN set -eux; \
    BUILD_ARCH="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "${BUILD_ARCH}" in \
        amd64) TOOL_ARCH=amd64; TRIVY_ARCH=64bit ;; \
        arm64) TOOL_ARCH=arm64; TRIVY_ARCH=ARM64 ;; \
        *) echo "Unsupported architecture: ${BUILD_ARCH}" >&2; exit 1 ;; \
    esac; \
    KUBECTL_URL="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TOOL_ARCH}/kubectl"; \
    HELM_URL="https://get.helm.sh/helm-${HELM_VERSION}-linux-${TOOL_ARCH}.tar.gz"; \
    ARGOCD_URL="https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-${TOOL_ARCH}"; \
    K6_URL="https://github.com/grafana/k6/releases/download/${K6_VERSION}/k6-${K6_VERSION}-linux-${TOOL_ARCH}.tar.gz"; \
    TRIVY_URL="https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-${TRIVY_ARCH}.tar.gz"; \
    YQ_URL="https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${TOOL_ARCH}"; \
    echo "Downloading kubectl from ${KUBECTL_URL}"; \
    curl -fsSL "${KUBECTL_URL}" -o /usr/local/bin/kubectl; \
    chmod +x /usr/local/bin/kubectl; \
    echo "Downloading Helm from ${HELM_URL}"; \
    curl -fsSL "${HELM_URL}" -o /tmp/helm.tar.gz; \
    tar -xzf /tmp/helm.tar.gz -C /tmp; \
    install -m 0755 "/tmp/linux-${TOOL_ARCH}/helm" /usr/local/bin/helm; \
    echo "Downloading Argo CD CLI from ${ARGOCD_URL}"; \
    curl -fsSL "${ARGOCD_URL}" -o /usr/local/bin/argocd; \
    chmod +x /usr/local/bin/argocd; \
    echo "Downloading k6 from ${K6_URL}"; \
    curl -fsSL "${K6_URL}" -o /tmp/k6.tar.gz; \
    tar -xzf /tmp/k6.tar.gz -C /tmp; \
    install -m 0755 "/tmp/k6-${K6_VERSION}-linux-${TOOL_ARCH}/k6" /usr/local/bin/k6; \
    echo "Downloading Trivy from ${TRIVY_URL}"; \
    curl -fsSL "${TRIVY_URL}" -o /tmp/trivy.tar.gz; \
    tar -xzf /tmp/trivy.tar.gz -C /tmp trivy; \
    install -m 0755 /tmp/trivy /usr/local/bin/trivy; \
    echo "Downloading yq from ${YQ_URL}"; \
    curl -fsSL "${YQ_URL}" -o /usr/local/bin/yq; \
    chmod +x /usr/local/bin/yq; \
    rm -rf \
        /tmp/helm.tar.gz \
        /tmp/linux-${TOOL_ARCH} \
        /tmp/k6.tar.gz \
        /tmp/k6-${K6_VERSION}-linux-${TOOL_ARCH} \
        /tmp/trivy.tar.gz \
        /tmp/trivy

WORKDIR /workspace

CMD ["/bin/bash"]
