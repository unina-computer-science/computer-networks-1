#!/usr/bin/env bash
# Starts the Computer Networks I container.
#
#   ./run.sh                 a shell in the container (throwaway)
#   ./run.sh <command>       runs a command and exits (e.g. ./run.sh gcc --version)
#   ./run.sh build           builds the image
#   ./run.sh lab             starts the two hosts of the project (server and client)
#   ./run.sh server|client   a shell on one of the two hosts
#   ./run.sh stop            stops and removes the two hosts
#
# Variables:
#   CN1_WORKSPACE   the folder with your code on the host (default ~/cn1-workspace)
#   PORTS           ports to publish towards the host, e.g. PORTS="8080 5000"
#   CN1_TEACHER=1   calisay at every shell
#   CN1_IMAGE       the name of the image (default cn1)
#
# They can be written once and for all in cn1.conf, next to this script: see
# cn1.conf.example. What you pass on the command line still wins over the file.
set -euo pipefail

cd "$(dirname "$0")"

# cn1.conf: this machine's preferences, not versioned. The file assigns
# variables and nothing else; the ones already in the environment are kept.
if [ -f cn1.conf ]; then
    while IFS= read -r line; do
        case "$line" in
            ''|'#'*) continue ;;
        esac
        name=${line%%=*}
        value=${line#*=}
        name=${name// /}                              # spaces around the =
        case "$name" in
            CN1_WORKSPACE|CN1_TEACHER|CN1_IMAGE|PORTS) ;;
            *) echo "cn1.conf: ignoring '$name', not a variable I know" >&2
               continue ;;
        esac
        value=${value#"${value%%[! ]*}"}              # leading spaces
        value=${value%\"}; value=${value#\"}          # quotes, if any
        value=${value%\'}; value=${value#\'}
        case "$value" in "~"/*) value="$HOME${value#\~}" ;; esac
        # the environment wins over the file
        if [ -z "${!name:-}" ]; then
            export "$name=$value"
        fi
    done < cn1.conf
fi

IMG="${CN1_IMAGE:-43616f73/cn1:2026.1}"
export CN1_IMAGE="$IMG"

# The code lives OUTSIDE this folder: updating or deleting the environment
# must never be able to touch anybody's work.
WS="${CN1_WORKSPACE:-$HOME/cn1-workspace}"
mkdir -p "$WS"
WS="$(cd "$WS" && pwd)"

# (Empty arrays are expanded as ${a[@]+"${a[@]}"}: the bash 3.2 on macOS,
#  with set -u, would stop otherwise.)

# Git Bash on Windows: without this, /workspace would become
# C:/Program Files/Git/workspace.
WS_DOCKER="$WS"
case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
        export MSYS_NO_PATHCONV=1
        WS_DOCKER="$(cygpath -w "$WS")"
        ;;
esac

export CN1_WORKSPACE="$WS_DOCKER"
export HOST_UID="$(id -u)"
export HOST_GID="$(id -g)"
export CN1_TEACHER="${CN1_TEACHER:-}"

# Compose v2 is a plugin of the docker command; v1 was a separate program.
# Some distributions ship neither: better to say so than to let docker print
# its own help.
compose() {
    if docker compose version > /dev/null 2>&1; then
        docker compose "$@"
    elif command -v docker-compose > /dev/null 2>&1; then
        docker-compose "$@"
    else
        echo "This needs Docker Compose, which is not installed." >&2
        echo "  Debian/Ubuntu:  sudo apt install docker-compose-v2" >&2
        echo "  or Docker's own repository, package docker-compose-plugin" >&2
        echo "Everything else (./run.sh, ./run.sh build) works without it." >&2
        exit 2
    fi
}

case "${1:-}" in
    build)
        exec docker build -t "$IMG" .
        ;;
    lab)
        compose up -d
        echo "Two hosts up: server (192.168.26.17) and client (192.168.26.23)."
        echo "Open them in two terminals:  ./run.sh server   and   ./run.sh client"
        echo "When you are done:           ./run.sh stop"
        exit 0
        ;;
    server|client)
        compose exec -u student "$1" bash; exit $?
        ;;
    stop)
        compose down; exit $?
        ;;
esac

published=()
for p in ${PORTS:-}; do
    published+=(-p "$p:$p")
done

tty=()
[ -t 0 ] && tty=(-it)

echo "Your code: $WS  ->  /workspace"
exec docker run --rm ${tty[@]+"${tty[@]}"} --init \
    --hostname cn1 \
    --cap-add NET_ADMIN \
    -v "$WS_DOCKER:/workspace" \
    -e HOST_UID -e HOST_GID -e CN1_TEACHER \
    -e CN1_WORKSPACE_HOST="$WS" \
    ${published[@]+"${published[@]}"} \
    "$IMG" "$@"
