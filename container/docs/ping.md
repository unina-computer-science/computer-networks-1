# ping — is it reachable, and how far

Sends ICMP echo requests and prints the replies. It answers two questions at
once: whether packets get there and come back, and how long that takes.

## Options used in this course

    -c N     send N and stop
    -i S     seconds between packets (below 0.2 needs root)
    -s N     payload size in bytes
    -M do    do not fragment: with -s, finds the path MTU
    -4 / -6  force one family

## Examples

    ping -c 3 8.8.8.8
    ping -c 3 iana.org
    ping -c 3 -s 3000 192.168.1.1          big enough to be fragmented
    ping -c 3 -s 1472 -M do 8.8.8.8        1472 + 28 = 1500: the usual limit

## Reading the output

    64 bytes from 192.0.43.8: icmp_seq=1 ttl=52 time=41.3 ms

- icmp_seq numbers the requests: a gap means a lost packet.
- ttl is what is left of the sender's hop limit, so it hints at how many
  routers were crossed: 64, 128 or 255 minus what you see.
- time is the round trip, there and back. Half of it is the one-way
  delay only if the path is symmetric, which it often is not.
- The summary line at the end gives loss percentage and min/avg/max.

## When it fails, it may not be your fault

Plenty of hosts and firewalls drop ICMP on purpose, so no reply does not
mean unreachable: the machine may be perfectly fine and simply silent. The
opposite is solid: a reply proves the path works in both directions.

## More

man ping. Inside the container ping works as a normal user because the
kernel allows unprivileged ICMP sockets; on other systems it may need root.
