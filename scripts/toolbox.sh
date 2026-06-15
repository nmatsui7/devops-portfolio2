#!/usr/bin/env bash
set -euo pipefail

IMAGE="${DEVOPS_TOOLBOX_IMAGE:-devops-toolbox:volume2}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKER_SOCKET_ENABLED=0

usage() {
    cat <<EOF
Usage: ./scripts/toolbox.sh [--with-docker-socket]

Starts an interactive Linux DevOps toolbox shell in /workspace.

Options:
  --with-docker-socket  Mount /var/run/docker.sock so Docker-aware tools inside
                        the toolbox can talk to the host Docker daemon.
                        Security warning: this effectively grants root-level
                        control over the host Docker daemon.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --with-docker-socket)
            DOCKER_SOCKET_ENABLED=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "Toolbox image '$IMAGE' was not found."
    echo "Build it first:"
    echo "  docker build -t $IMAGE -f docker/devops-toolbox.Dockerfile ."
    exit 1
fi

DOCKER_ARGS=(
    run
    --rm
    -it
    --name devops-toolbox-volume2
    -v "$PROJECT_ROOT:/workspace"
    -w /workspace
)

# Minikube kubeconfig often references cert/key files by absolute host paths
# under $HOME/.minikube. This read-only mount lets kubectl inside the toolbox
# load those credentials.
MINIKUBE_MOUNT_ARGS=()
if [ -d "$HOME/.minikube" ]; then
    MINIKUBE_MOUNT_ARGS+=(-v "$HOME/.minikube:$HOME/.minikube:ro")
fi

# On macOS, Docker Desktop runs inside a VM so 127.0.0.1 inside the container
# points to the VM's loopback, not the host macOS loopback. We work around this
# by rewriting the kubeconfig to reach the minikube container directly over
# Docker's internal network. The minikube TLS certificate includes "minikube"
# in its SAN list, so connecting by container name passes verification.
# On Linux we can simply use --network=host.
if [[ "$(uname)" == "Darwin" ]]; then
    if [ -f "$HOME/.kube/config" ]; then
        TMP_KUBECONFIG="$(mktemp /tmp/devops-toolbox-kubeconfig.XXXXXX)"
        # Rewrite 127.0.0.1:<host-port> -> minikube:8443 (container's
        # internal API-server port).
        sed 's/127\.0\.0\.1:[0-9]*/minikube:8443/g' "$HOME/.kube/config" > "$TMP_KUBECONFIG"
        DOCKER_ARGS+=(-v "$TMP_KUBECONFIG:/root/.kube/config:ro")
        DOCKER_ARGS+=("${MINIKUBE_MOUNT_ARGS[@]}")
    fi
else
    # Linux: share the host network namespace so 127.0.0.1 works as-is.
    DOCKER_ARGS+=(--network=host)
    if [ -d "$HOME/.kube" ]; then
        DOCKER_ARGS+=(-v "$HOME/.kube:/root/.kube:ro")
    fi
    DOCKER_ARGS+=("${MINIKUBE_MOUNT_ARGS[@]}")
fi

if [ "$DOCKER_SOCKET_ENABLED" -eq 1 ]; then
    if [ ! -S /var/run/docker.sock ]; then
        echo "Docker socket requested, but /var/run/docker.sock was not found." >&2
        exit 1
    fi

    cat <<EOF
Security warning:
  Mounting /var/run/docker.sock lets processes inside this toolbox control the
  host Docker daemon. Only use --with-docker-socket when you understand and
  accept that trust boundary.
EOF
    DOCKER_ARGS+=(-v /var/run/docker.sock:/var/run/docker.sock)
fi

# Start detached so we can attach extra networks before the user starts typing.
DOCKER_ARGS+=(-d)
CONTAINER_ID="$(docker "${DOCKER_ARGS[@]}" "$IMAGE")"

# Connect to the minikube Docker network so "minikube:8443" resolves.
if docker network inspect minikube >/dev/null 2>&1; then
    docker network connect minikube "$CONTAINER_ID" >/dev/null 2>&1 || true
fi

# Attach interactively.
docker attach "$CONTAINER_ID"

if [[ -n "${TMP_KUBECONFIG:-}" ]]; then
    rm -f "$TMP_KUBECONFIG"
fi
