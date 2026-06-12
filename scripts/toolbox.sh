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

if [ -d "$HOME/.kube" ]; then
    DOCKER_ARGS+=(-v "$HOME/.kube:/root/.kube:ro")
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

exec docker "${DOCKER_ARGS[@]}" "$IMAGE"
