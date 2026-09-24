#!/usr/bin/env bash
# ===========================================================================
#  check.sh — is my environment working?
#
#      ./check.sh
#
#  Ten checks, about half a minute: the compiler, the tools the course uses,
#  the capture, and that a file saved in /workspace really lands on your own
#  machine. Nothing here needs the Internet.
#
#  If they all pass, the environment is fine and any problem is in the code.
# ===========================================================================
set -u

cd "$(dirname "$0")"
IMG="${CN1_IMAGE:-43616f73/cn1:2026.1}"
WS="${CN1_WORKSPACE:-$HOME/cn1-workspace}"

pass=0; fail=0
green() { printf '\033[32m%s\033[0m' "$1"; }
red()   { printf '\033[31m%s\033[0m' "$1"; }
ok() { printf '  %s  %s\n' "$(green PASS)" "$1"; pass=$((pass+1)); }
ko() { printf '  %s  %s\n' "$(red FAIL)" "$1"; [ -n "${2:-}" ] && printf '        %s\n' "$2"; fail=$((fail+1)); }

inside() { docker run --rm -i --init --cap-add NET_ADMIN \
             -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" \
             -v "$WS:/workspace" "$IMG" "$@" 2>&1 </dev/null; }

echo
echo "Environment check"
echo "-----------------"

# --- 1. docker and the image ----------------------------------------------
if ! command -v docker > /dev/null 2>&1; then
    ko "docker is not installed" "see README, section 1"
    echo; exit 1
fi
ok "docker is installed"

if ! docker info > /dev/null 2>&1; then
    ko "the docker daemon is not answering" \
       "start it (sudo service docker start) and check you are in the docker group"
    echo; exit 1
fi
ok "the docker daemon answers"

if docker image inspect "$IMG" > /dev/null 2>&1; then
    ok "the image $IMG is here"
else
    ko "the image $IMG is not here" "docker pull $IMG"
    echo; exit 1
fi

if docker compose version > /dev/null 2>&1 || command -v docker-compose > /dev/null 2>&1; then
    ok "docker compose is installed"
else
    ko "docker compose is missing" \
       "needed for ./run.sh lab: see README, section 2"
fi

# --- 2. the workspace ------------------------------------------------------
mkdir -p "$WS"
out=$(inside bash -c 'echo hello > /workspace/.cn1-check; echo INSIDE_OK')
if [ -f "$WS/.cn1-check" ] && [ "$(cat "$WS/.cn1-check")" = hello ]; then
    ok "a file written in /workspace lands on your machine"
else
    ko "the file did not arrive in $WS" "$out"
fi

u=$(stat -c %u "$WS/.cn1-check" 2>/dev/null || stat -f %u "$WS/.cn1-check" 2>/dev/null)
if [ "$u" = "$(id -u)" ]; then
    ok "and it belongs to you (uid $u)"
else
    ko "the file belongs to uid $u instead of $(id -u)"
fi
rm -f "$WS/.cn1-check"

# --- 3. the compiler -------------------------------------------------------
out=$(inside bash -c 'cat > /tmp/t.c <<EOF
#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <pthread.h>
int main(void) {
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    printf("%s\n", fd >= 0 ? "SOCKET_OK" : "SOCKET_NO");
    return 0;
}
EOF
gcc -Wall -Wextra -pthread -o /tmp/t /tmp/t.c && /tmp/t')
if printf '%s' "$out" | grep -q SOCKET_OK; then
    ok "a C program with sockets compiles and runs"
else
    ko "the C program does not compile or does not run" "$(printf '%s' "$out" | head -3)"
fi

# --- 4. the tools ----------------------------------------------------------
attesi="gcc make gdb valgrind nvim dig ip ss ping traceroute nc curl wget nmap ftp lynx tshark tcpdump nft"
out=$(inside bash -c "for c in $attesi; do command -v \$c > /dev/null || echo MISSING=\$c; done; echo TOOLS_DONE")
missing=$(printf '%s' "$out" | grep -o 'MISSING=[a-z]*' | sed 's/MISSING=//' | tr '\n' ' ')
if [ -z "$missing" ]; then
    ok "every tool the course uses is there"
else
    ko "these tools are missing: $missing" "the image may be incomplete: docker pull $IMG"
fi

# --- 5. the capture --------------------------------------------------------
out=$(inside bash -c 'tshark -i lo -a duration:2 -w /tmp/c.pcap > /dev/null 2>&1 &
    sleep 1; (echo hi | nc -l 5099 &) ; sleep 0.2; echo hi | nc -q 1 127.0.0.1 5099 > /dev/null 2>&1
    sleep 2; echo PACKETS=$(tshark -r /tmp/c.pcap 2>/dev/null | wc -l)')
n=$(printf '%s' "$out" | grep -o 'PACKETS=[0-9]*' | sed 's/PACKETS=//')
if [ "${n:-0}" -gt 0 ]; then
    ok "tshark captures without sudo ($n packets)"
else
    ko "tshark captured nothing" "$(printf '%s' "$out" | head -3)"
fi

# --- 6. the editor ---------------------------------------------------------
out=$(inside bash -c 'nvim --headless -c "qa" 2>&1; echo NVIM_RC=$?')
if printf '%s' "$out" | grep -q 'NVIM_RC=0'; then
    ok "the editor starts with no errors"
else
    ko "nvim reports errors at startup" "$(printf '%s' "$out" | head -3)"
fi

echo
printf '%s %d   %s %d\n' "$(green PASS)" "$pass" "$(red FAIL)" "$fail"
if [ "$fail" -eq 0 ]; then
    echo "The environment is fine."
else
    echo "Look at the red lines: each says what to do."
fi
exit $(( fail > 0 ))
