# tor, torsocks — traffic that takes three hops

tor connects to the Tor network and opens a SOCKS proxy on 127.0.0.1:9050.
torsocks runs another program with its connections sent through that proxy.
The course uses them to see what an observer can and cannot tell.

## Running it

    tor &                              starts, takes a few seconds
    torsocks curl -s https://check.torproject.org | grep -i congratul
    torsocks dig +short example.com    resolved through Tor, not your resolver

tor prints Bootstrapped 100% when it is ready. Before that, connections
through it fail.

## What changes, and what does not

- The address the site sees is the exit node's, not yours.
- Your provider sees that you are talking to a Tor entry node, and
  nothing else: not which sites, not what.
- The exit node sees the traffic as it leaves, so anything unencrypted at
  that point is readable there. HTTPS still matters inside Tor.
- Timing and volume remain visible to somebody watching both ends, which
  is the correlation attack the lecture describes.

## Notes

- Only TCP goes through: ping cannot be torsocked, because ICMP is not TCP.
- Latency goes up a lot — three hops chosen around the world. That is the
  price, and it is worth measuring once with time.
- In the container this is a demonstration, nothing more: tor from a
  container on a university network may not even bootstrap.

## More

man tor, man torsocks, and https://check.torproject.org to see whether
you are actually going through it.
