# ss — sockets, and what state they are in

Lists the sockets on the machine: who is listening, who is connected, and how
much is queued. It replaced netstat, which you will find in books and which
is no longer installed by default on most systems.

## Options used in this course

    -t        TCP
    -u        UDP
    -l        only the listening ones
    -n        numbers, never names: no DNS, and much faster
    -p        which process owns the socket (needs sudo for other users')

They combine: -tln is the one you will type most.

## Filters

ss takes a filter language, which beats | grep because it asks the kernel
instead of matching text:

    ss -tln 'sport = :5000'          listening on port 5000
    ss -tn state established         only the established ones
    ss -tn state close-wait          only the ones stuck in CLOSE-WAIT

## Examples

    ss -tln                          is my server actually listening?
    ss -tn                           who is connected right now
    ss -tnp 'dport = :443'           which program has connections to port 443

## Reading the output

    State      Recv-Q  Send-Q   Local Address:Port    Peer Address:Port
    ESTAB      0       0        127.0.0.1:5000        127.0.0.1:43210

- Recv-Q is what arrived and your program has not read yet. Growing means
  your program is not reading fast enough — or not reading at all.
- Send-Q is what you wrote and the other end has not acknowledged.
- LISTEN with a local address of 0.0.0.0 or * means every interface;
  127.0.0.1 means loopback only, and nobody else can reach you.
- CLOSE-WAIT on your side means the other end closed and your program
  never called close. It is always a bug in the program.
- TIME-WAIT is normal: the kernel keeps the pair for a while after
  closing. It is also why bind fails right after a restart, unless you set
  SO_REUSEADDR.

On the loopback every connection appears twice, once per end.

## More

man ss for the filter language. The old equivalent is netstat -tan, if you
ever end up on a machine without ss.
