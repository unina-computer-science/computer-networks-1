# nc — a socket you can type into

Opens a TCP connection, or listens for one, and wires it to your terminal.
Whatever you type goes out, whatever arrives is printed. It is a generic
client and a generic server, which makes it the fastest way to look at a
protocol or to test your own program before you have written the other half.

## Two modes

    nc HOST PORT        connect, and talk
    nc -l PORT          listen, and wait for somebody

## Options used in this course

    -l    listen instead of connecting
    -u    UDP instead of TCP
    -C    send CRLF at end of line, not just LF
    -q N  after your input ends, wait N seconds before quitting
    -v    say what happened: connected, refused, timed out
    -z    just try the connection, send nothing

## Examples

    nc -C info.cern.ch 80                talk HTTP by hand
    nc -l 5001 > got.bin                 receive a file
    nc 127.0.0.1 5001 < send.bin         send it, from the other terminal
    nc -vz 192.0.47.59 43                is that port open at all?
    printf 'unina.it\r\n' | nc whois.nic.it 43

## -C matters more than it looks

Many text protocols — HTTP, SMTP, WHOIS — end every line with carriage return
and newline. Your terminal sends only the newline. Without -C a strict
server answers 400 Bad Request or simply waits for the rest of a line that
never comes.

Never use -C when moving binary data: it would rewrite bytes inside the file.

## What it does not do

nc says nothing about what it sends, adds nothing, and interprets nothing.
That is the point: what you see is what is on the wire. It also does not
encrypt: for TLS use openssl s_client -connect host:443.

## More

man nc. Careful with the name: on Debian and Ubuntu it is
netcat-openbsd, on Fedora nc is Nmap's ncat, on macOS it is the BSD one.
Options differ, -l and -u do not.
