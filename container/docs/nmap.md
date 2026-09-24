# nmap — what is listening over there

Asks a host, or a whole network, which ports are open. In this course it is
used to look at a machine from the outside and to find who is on the LAN —
not to go anywhere you have not been invited.

## Options used in this course

    -sn            ping scan: who is alive, no ports
    --top-ports N  the N most common ports instead of 1000
    -p 22,80,443   exactly these ports
    -Pn            skip the alive check, scan anyway
    -sV            ask each open port what it is running
    -n             no reverse DNS

## Examples

    nmap --top-ports 6 scanme.nmap.org        a host that allows scanning
    sudo nmap -sn 192.168.1.0/24              who is on my network
    nmap -p 5000 127.0.0.1                    is my server up?

## Reading the output

    PORT     STATE    SERVICE
    22/tcp   open     ssh
    80/tcp   closed   http
    443/tcp  filtered https

    open      something accepted the connection.
    closed    nothing there, but the host answered with a reset: it is alive.
    filtered  no answer at all. A firewall is dropping the packets, and
  nmap cannot tell open from closed.

The service column is a guess from the port number unless you used -sV.
Port 80 means whoever runs the machine chose port 80.

## Before you use it

Scanning hosts you do not own is, depending on where you are, at best rude and
at worst illegal. scanme.nmap.org exists precisely so you have something
legitimate to try. On your own network, and on the container, do as you like.

## More

man nmap. Some scan types need root — -sn on a LAN uses ARP, which does.
