# tcpdump — packets, on the terminal

Prints the packets going through an interface, one line each. Same job as
Wireshark, without the window: quicker to start, quicker to read when you
already know what you are looking for.

## Options used in this course

    -i IFACE  which interface (lo for loopback, any for all)
    -n        do not resolve addresses; -nn not even port names
    -c N      stop after N packets
    -e        show the Ethernet header too: MAC addresses
    -t        no timestamp, shorter lines
    -X        hex and ASCII of the payload
    -w FILE   write a .pcap instead of printing, to open in Wireshark

## The filter goes last

    sudo tcpdump -i lo -n 'tcp port 5000'
    sudo tcpdump -i eth0 -e -n 'arp or port 5000'
    sudo tcpdump -i eth0 -n -X 'udp port 53'
    sudo tcpdump -i eth0 -w capture.pcap 'host 192.168.1.17'

The filter language (BPF) is not the one Wireshark uses in its display bar:
here it is tcp port 80, there it is tcp.port == 80. Both exist for a
reason — this one decides what gets captured, that one what gets shown.

## Reading a line

    12:31:04.552 IP 127.0.0.1.43210 > 127.0.0.1.5000: Flags [S], seq 1829

Address and port are joined by a dot, so 127.0.0.1.5000 is port 5000.
Flags [S] is SYN, [S.] SYN+ACK, [P.] push with data, [F.] FIN,
[R] reset.

## Two practical notes

- On loopback there are no Ethernet headers and no ARP: to see those you need
  two real hosts, which is what the compose setup is for.
- Capturing usually needs root. Inside the container tshark is set up to run
  as a normal user, tcpdump with sudo.

## More

man tcpdump for the options, man pcap-filter for the filter language,
which is the part worth reading.
