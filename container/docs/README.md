# The tools of this course

One page each: what it is for, the options that actually get used here,
examples, and where the real manual is. They are not a replacement for man —
they are the part man does not have, which is which five options out of
forty matter while you are learning.

## The network

    dig           ask a name server, and read the reply as a DNS message
    ip            addresses, routes, the ARP table, the interfaces
    ss            which sockets exist, and what state they are in
    ping          is it reachable, and how far away
    traceroute    which routers are in between
    nmap          which ports are open over there
    nft           the firewall rules, and the connections the kernel tracks

## Talking to a server

    nc            a socket wired to your terminal: any protocol, by hand
    curl          one HTTP request, and everything about the reply
    wget          download a file
    ftp           a protocol old enough to watch in full
    lynx          a browser that makes exactly one request
    tor           the same traffic, three hops away

## Looking at the wire

    tcpdump       packets, one line each
    tshark        the same, but it understands protocols

## Reading them in the terminal

    guide            the list
    guide dig        one page

guide is a shell function in the container: it shows the page with bat, which
colours it and pages it. It is not called help, because that is a bash
builtin. Outside the container these are ordinary files: open
them in an editor, or read them on the web, where they are laid out.
