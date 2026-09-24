# The lab environment

A Linux environment ready for the course: the C compiler, the network tools,
`tshark`, a configured editor. The same for everybody on Linux, macOS and
Windows, and it installs nothing on your own machine.

Using it is not compulsory: at the end of this page there is the list of what
to install to work on your own system instead.

---

## 1. Install Docker

**Linux.** Either your distribution's package or Docker's own repository.

```bash
sudo apt install docker.io          # Debian, Devuan, Ubuntu
sudo dnf install docker             # Fedora
sudo pacman -S docker               # Arch
```

Then enable the service and add yourself to the `docker` group, so that you
do not need `sudo` every time:

```bash
sudo systemctl enable --now docker   # with systemd
sudo service docker start            # without systemd (Devuan, Artix, Void)
sudo usermod -aG docker "$USER"
```

Log out and back in for the group to take effect.

Being in the `docker` group means being able to do anything on the machine:
the daemon runs as root, and anybody who can talk to it can mount the whole
filesystem inside a container. On your own computer that changes nothing,
since you already have `sudo`; on a shared machine, ask whoever runs it.

**Rootless Docker.** If Docker on your system runs rootless, the environment
still works, but the exercises that need network privileges — the ARP table
flush, `nft`, `conntrack` — may not: those capabilities are restricted there.
Those are the exercises of E4.15 and L31.

**macOS and Windows.** Install [Docker
Desktop](https://www.docker.com/products/docker-desktop/). On Windows it
works from PowerShell, from Git Bash and from WSL; the commands on this page
assume Git Bash or WSL.

## 2. Install Docker Compose

It is needed for the two hosts of the project. Docker Desktop already has it;
on Linux it depends on where Docker came from. The distribution's `docker.io`
package does **not** include it.

```bash
docker compose version          # must answer with a version, 2.x
```

If it says that `compose` is not a docker command:

```bash
sudo apt install docker-compose-v2      # Debian 12+, Devuan, Ubuntu 24.04+
sudo dnf install docker-compose         # Fedora
sudo pacman -S docker-compose           # Arch
```

## 3. Fetch the image

```bash
docker pull 43616f73/cn1:2026.1
```

About a gigabyte, downloaded once. **Do it at home, before the first lab
session**: thirty people pulling at the same time over the university network
is slow for everybody.

## 4. Start it

From this folder:

```bash
./run.sh
```

The first time it creates `~/cn1-workspace` on your computer. That folder is
what you see as `/workspace` inside the container, and it is also your home
there: open a shell and you are already in it.

- What you save in `/workspace` is written **straight to your own machine**.
  Closing the container does not touch it.
- **Everything else disappears on exit**: a file saved in `/tmp`, or anywhere
  outside `/workspace`, is gone next time.
- You can open those files with any editor on your system: they are ordinary
  files in an ordinary folder.

Other ways to start it:

```bash
./run.sh gcc --version          # runs one command and exits
PORTS="8080" ./run.sh           # publishes port 8080 towards your computer
```

To use a different folder, or to set your preferences once, copy
`cn1.conf.example` to `cn1.conf` and edit it.

### Check that it works

```bash
./check.sh
```

Ten checks, half a minute: the compiler, the network tools, the capture, and
that a file saved in `/workspace` really ends up on your machine. If they all
pass, your environment is fine.

## 5. Working in it

Inside you have the compiler and every tool the course uses:

```bash
cd /workspace
nvim server.c
gcc -Wall -Wextra -pthread -o server server.c
./server 5000
```

`guide` opens a page per tool — `guide dig`, `guide nc`, `guide nvim` — with
the options the course actually uses and a few examples. `guide` on its own
lists them.

The editor is Neovim, configured for C. `guide nvim` covers the essentials,
including how to quit. Anybody who prefers another editor uses it on their own
machine, in `~/cn1-workspace`, and comes to the container only to compile and
run.

## 6. Two hosts for the project

This is for the course project, where client and server have to live on
different machines; the project itself is published later on. Until then it is
still worth trying, with `nc` on one side and the other.

The chat is more instructive when client and server are two machines with two
addresses, rather than both on `127.0.0.1`:

```bash
./run.sh lab        # starts two hosts on the 192.168.26.0/24 network
./run.sh server     # terminal 1: a shell on "server" (192.168.26.17)
./run.sh client     # terminal 2: a shell on "client" (192.168.26.23)
./run.sh stop       # when you are done
```

Both see the same `/workspace`: you compile once and run on either side.

```bash
server$ ./chatd 5000
client$ ./chat server 5000
```

On this network the MTU is 1500, so a 3000-byte UDP datagram really does
fragment, unlike on loopback.

## 7. Capturing traffic

`tshark` is Wireshark from the terminal, and the filters are the same. No
`sudo` needed:

```bash
tshark -i lo -f "tcp port 5000"               # between two programs on this machine
tshark -i eth0 -Y dns                          # outwards, with a display filter
tshark -i eth0 -w /workspace/capture.pcap      # save (Ctrl-C to stop)
tshark -r /workspace/capture.pcap -Y http      # read it back
```

A capture saved in `/workspace` is already on your computer: open it with the
graphical Wireshark if you prefer the windows.

`tcpdump` is there too, and `guide tshark` and `guide tcpdump` explain both.

## 8. What you cannot do from the container

**Capture your own browser's traffic.** On macOS and Windows the container
runs in a virtual machine and does not see your computer's network. The labs
do not need it: their traffic is generated with `curl`, `dig` and `nc` inside
the container.

**On macOS and Windows**, Docker Desktop carries traffic out through a network
stack in user space. So `traceroute` does not show the real hops, the TTL of
`ping` replies says nothing about the path, and the TCP dynamics observed in
L19 are those of the local leg. On Linux these exercises give true results.

**The "on your own machine" exercises** — your address, your gateway, your
ARP table, DHCP — are done on your own machine, as the slides say.

---

## Doing without the container

Everything the course uses is ordinary free software. To work on your own
system, install:

**Compiler and build**: `gcc` (or `clang`), `make`, `gdb`, `valgrind`, and the
system headers (`libc6-dev` on Debian, `glibc-devel` on Fedora).

**Network tools**: `dig` (in `bind9-dnsutils` or `bind-utils`), `iproute2` for
`ip` and `ss`, `iputils-ping`, `traceroute`, `netcat-openbsd`, `curl`, `wget`,
`nmap`, an FTP client (`tnftp`), `lynx`, `nftables`, `conntrack`, `tor` and
`torsocks`.

**Capture**: `tshark` and `tcpdump`. To capture without root, put yourself in
the `wireshark` group and give `dumpcap` the capabilities — the installation
of the Wireshark package usually asks.

**For the project over TLS** (L31): OpenSSL development headers
(`libssl-dev`, `openssl-devel`).

**For the L30 demonstration**: an FTP server (`vsftpd`), if you want to redo
the captured password.

On macOS most of these are in Homebrew; `tshark` comes with Wireshark. On
Windows the simplest path is WSL, which gives you a Linux to install them in.

One note: the course's compile line is `gcc -Wall -Wextra -pthread`, with no
`-std=`. With a strict `-std=c11` you lose `getaddrinfo`, `sigaction` and
others.
