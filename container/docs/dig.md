# dig — DNS lookups

Asks a name server a question and prints the reply as it arrived. Unlike a
browser or ping, it shows you the DNS message: flags, sections, TTLs.
That is why the course uses it instead of nslookup.

## What you ask

    dig NAME TYPE

The type goes last — A, NS, MX, SOA, CNAME — and defaults to A.
Everything beginning with + is an option, and they can be combined.

## Choosing who answers

By default dig asks the resolver your machine is configured with, and that
resolver does all the work: it walks down from the root and hands you the
final answer.

@server skips it and asks a specific server. That is how you do by hand what
a resolver does: start at a root server, follow the referral to the TLD, then
to the zone.

+norecurse goes with it: it tells the server do not resolve this for me,
just answer what you know. Without it you are asking a root server to do a
resolver's job, which it will refuse — politely, and the warning line says so.

## Trimming the output

Full output is a screenful. Three ways to cut it:

    +short          the answer values alone, one per line. Good inside scripts
    +noall +answer  the answer section with names, TTLs and types
    +multiline      SOA fields one per line, labelled. Only for SOA

## Examples

    dig +short www.unina.it                        an address, nothing else
    dig +noall +answer mit.edu MX                  who takes the mail
    dig +noall +answer +multiline mit.edu SOA      the zone's parameters
    dig +norecurse @c.root-servers.net ox.ac.uk A  one step, at the root
    dig +trace www.ox.ac.uk                        the whole walk

## Reading the header

    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 19917
    ;; flags: qr aa rd ra;  QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

- status — NOERROR means the question was understood, not that an
  answer exists. NXDOMAIN is no such name, SERVFAIL means the server
  gave up, often on a validation it could not do.
- aa — the answer comes from a server that holds the zone. Without it,
  you are reading somebody's cache.
- ra — the server offers recursion. Authoritative servers do not, so a
  root server that sets ra is not a root server: somebody on the way
  answered for it. This happens on many home connections.
- The counters tell you the shape of the reply before you read it:
  ANSWER: 0 with a non-empty authority section is a referral, not a failure.

The number before IN is the TTL: how many more seconds that copy may be
used. Ask twice and watch it go down — that is a cache at work.

## More

man dig for everything, dig -h for the option list. To see what your
programs see — /etc/hosts included, which dig ignores — use
getent hosts NAME instead.
