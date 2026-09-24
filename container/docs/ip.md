# ip — addresses, routes, neighbours, links

One command for everything the kernel knows about the network. It replaced
ifconfig, route and arp, which you will still meet in older books: same
information, three commands instead of one, and no IPv6.

## The shape of it

    ip OBJECT COMMAND

The objects used in this course:

    ip addr   addresses on the interfaces
    ip route  where packets for a destination go
    ip neigh  the ARP table: which MAC belongs to which IP
    ip link   the interfaces themselves, MAC and MTU

show is the default command, so ip addr and ip addr show are the same
thing. Every object takes -br for a compact table, and -4 or -6 to look
at one family only.

## Examples

    ip -4 addr show eth0        one interface, IPv4 only
    ip -br link                 every interface on one line each
    ip route                    the routing table, default route first
    ip neigh                    who answered ARP recently
    sudo ip neigh flush all     forget it, so the next ping asks again

## Reading an address

    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...
        inet 217.149.127.10/26 brd 217.149.127.63 scope global eth0

- /26 is the mask, written as the number of ones: 26 here, so
  255.255.255.192, and 6 bits left for hosts.
- brd is the broadcast address of that subnet, the last one in it.
- mtu is the largest payload a frame can carry on that link. On
  loopback it is enormous (65536), which is why fragmentation never shows up
  when you test on 127.0.0.1.
- UP means configured, LOWER_UP means the cable is actually
  connected. They can disagree, and when they do that is your problem.

## More

man ip, and man ip-address, man ip-route: each object has its own page.
ip is Linux only — on macOS you get ifconfig and netstat -r, on Windows
ipconfig and route print.
