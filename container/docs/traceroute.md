# traceroute — the routers along the way

Shows which routers your packets cross to reach a destination, and how long
each step takes. It works by sending packets with a TTL of 1, then 2, then 3:
each router that throws one away reports back, and that report is its name.

## Options used in this course

    -n    numbers only, no reverse DNS: much faster
    -I    use ICMP instead of UDP (some paths only answer to that)
    -T    use TCP
    -m N  stop after N hops
    -q N  N probes per hop instead of 3

The last argument, a number, is the packet size: traceroute host 3000
sends 3000-byte packets, which is how you make fragmentation happen.

## Examples

    traceroute -n italia.it
    traceroute italia.it 3000           big packets: watch them fragment
    traceroute -I 8.8.8.8               when the default gets no answers

## Reading the output

    3  10.20.30.1  8.1 ms  7.9 ms  8.2 ms
    4  * * *
    5  89.97.200.1  19.4 ms  19.1 ms  19.6 ms

- Three times per line: three probes, so you see variation, not one sample.
- * * * means that router did not answer. It does not mean the path
  is broken: plenty of routers are configured not to reply, and the hops after
  it usually answer fine.
- Times that go down at a later hop are normal: each is an independent round
  trip, and load varies.
- The path can change between one run and the next, and the way back may not
  be the way there — traceroute only sees the way there.

## More

man traceroute. On Windows it is tracert, and it uses ICMP by default.
mtr does the same thing continuously, if you want to watch a path over time.
