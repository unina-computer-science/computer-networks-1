# =============================================================================
#  Computer Networks I - lab environment
#  Universita' degli Studi di Napoli Federico II
#
#  Build:  ./run.sh build        (or: docker build -t cn1 .)
#  Why each package is here is in the table in the README.
#  A new package goes HERE and the image is rebuilt: nothing is installed
#  inside a running container, which disappears on exit.
# =============================================================================
FROM ubuntu:26.04

ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Europe/Rome \
    EDITOR=nvim

# -----------------------------------------------------------------------------
#  Man pages: the Ubuntu Docker image leaves them out. They are needed here
#  (man 2 socket, man 7 ip) because in class the network may not be there.
# -----------------------------------------------------------------------------
RUN rm -f /etc/dpkg/dpkg.cfg.d/excludes \
 && if [ -n "$(dpkg-divert --list /usr/bin/man)" ]; then \
        rm -f /usr/bin/man && dpkg-divert --quiet --remove --rename /usr/bin/man; \
    fi

# tshark: dumpcap with the capabilities, usable by the wireshark group (as in L04)
RUN echo "wireshark-common wireshark-common/install-setuid boolean true" \
    | debconf-set-selections

# -----------------------------------------------------------------------------
#  Packages. Every line says where they are used; the detail is in the README.
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    # C toolchain: gcc 15 (C23 by default), POSIX and socket headers, OpenSSL (L31)
        gcc make libc6-dev libssl-dev gdb valgrind clangd \
        man-db manpages manpages-dev manpages-posix-dev \
    # capture and analysis: L04-L05, L15, L18-L19, L22, L28, L30-L32, E1-E4
        tshark tcpdump libcap2-bin \
    # clients and diagnostics: L03-L08, L12-L15, L18-L19, L22-L23, L28, E1-E4
        netcat-openbsd curl wget ca-certificates bind9-dnsutils \
        iputils-ping traceroute iproute2 net-tools tnftp lynx nmap \
    # sessions of the last lectures: FTP (L30), firewall (L31), Tor (L32)
        vsftpd conntrack nftables tor torsocks \
    # system: processes (L09-L12, E4.30), privileges, man pages, shell
        procps sudo less bash-completion \
    # bat: reads the pages in /opt/cn1/docs with colours (the help command)
        bat \
    # time: /usr/bin/time -f '%M' measures memory (the L11 check)
        time \
    # editor: Neovim 0.11 and what its configuration needs
        neovim git ripgrep tree-sitter-cli tar \
 && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
#  The user. Home is /workspace, the folder mounted from the host: the
#  natural place to save is also the only one that survives the exit.
#  The UID is realigned to the host's at startup (entrypoint).
# -----------------------------------------------------------------------------
RUN (userdel -r ubuntu 2>/dev/null || true) \
 && groupadd -g 1000 student \
 && useradd -u 1000 -g 1000 -G wireshark -d /workspace -M -s /bin/bash student \
 && echo "student ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/student \
 && chmod 0440 /etc/sudoers.d/student \
 && mkdir -p /workspace && chown student:student /workspace \
 && mkdir -p /var/run/vsftpd/empty

# -----------------------------------------------------------------------------
#  Neovim. Configuration, plugins and parsers live in /opt/cn1/nvim, OUTSIDE
#  /workspace: the host mount would hide them. Everything is downloaded and
#  built here, at build time: the container starts offline.
#  The build writes into /opt/cn1/nvim as root, so it calls /usr/bin/nvim with
#  the variables set right here. At run time the wrapper in /usr/local/bin/nvim
#  sets them differently, because what is built here is read-only for the
#  student: see the comment in system/nvim-wrapper.
#  The fifth parser, query, is the language of treesitter's own queries: it is
#  what :InspectTree opens its window with.
# -----------------------------------------------------------------------------
COPY nvim/ /opt/cn1/nvim/config/nvim/
COPY system/nvim-wrapper /usr/local/bin/nvim
RUN chmod 0755 /usr/local/bin/nvim \
 && export XDG_CONFIG_HOME=/opt/cn1/nvim/config \
           XDG_DATA_HOME=/opt/cn1/nvim/data \
           XDG_STATE_HOME=/tmp/nvim-build/state \
           XDG_CACHE_HOME=/tmp/nvim-build/cache \
 && /usr/bin/nvim --headless "+Lazy! sync" +qa \
 && /usr/bin/nvim --headless \
        -c "lua require('nvim-treesitter').install({ 'c', 'bash', 'make', 'lua', 'query' }):wait(300000)" \
        -c qa \
 && test -f /opt/cn1/nvim/data/nvim/site/parser/c.so \
 && test -f /opt/cn1/nvim/data/nvim/site/parser/bash.so \
 && test -f /opt/cn1/nvim/data/nvim/site/parser/make.so \
 && test -f /opt/cn1/nvim/data/nvim/site/parser/lua.so \
 && test -f /opt/cn1/nvim/data/nvim/site/parser/query.so \
 && rm -rf /tmp/nvim-build \
 && chmod -R a+rX /opt/cn1/nvim

# -----------------------------------------------------------------------------
#  calisay, shell startup, the test FTP server, entrypoint
# -----------------------------------------------------------------------------
COPY docs/             /opt/cn1/docs/
COPY calisay/calisay   /usr/local/bin/calisay
COPY calisay/messages.txt /usr/local/share/calisay/messages.txt
COPY system/bashrc      /etc/cn1/bashrc
COPY system/vsftpd.conf /etc/cn1/vsftpd.conf
COPY system/start-ftp   /usr/local/bin/start-ftp
COPY system/entrypoint  /usr/local/bin/cn1-entrypoint
RUN chmod 0755 /usr/local/bin/calisay /usr/local/bin/start-ftp /usr/local/bin/cn1-entrypoint \
 && echo '[ -f /etc/cn1/bashrc ] && . /etc/cn1/bashrc' >> /etc/bash.bashrc

WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/cn1-entrypoint"]
CMD ["bash"]
