# tshark — Wireshark without the window

The same engine as Wireshark, driven from the terminal. It understands
protocols, not just packets: where tcpdump shows you a TCP segment, tshark
tells you it is an HTTP request and which fields it carries.

## Options used in this course

    -i IFACE           which interface
    -f 'FILTER'        capture filter, BPF, same as tcpdump
    -Y 'FILTER'        display filter, the Wireshark one
    -c N               stop after N packets
    -a duration:N      stop after N seconds
    -r FILE            read a .pcap instead of capturing
    -w FILE            write one
    -V                 the whole dissection, as in the detail pane
    -T fields -e NAME  print only the fields you name

## Two filters, not one

-f decides what is captured: it runs in the kernel, it is cheap, and it
uses the tcpdump syntax — tcp port 443.

-Y decides what is shown of what was captured: it runs afterwards, it
understands protocols, and it uses Wireshark's syntax — http.request,
tls.handshake.type == 1, dns.flags.response == 0.

Use both: capture narrow, then filter what you kept.

## Examples

    tshark -i lo -f 'tcp port 5001'
    sudo tshark -i eth0 -f 'tcp port 443' -Y tls
    tshark -r capture.pcap -Y 'http.request' -T fields -e http.host
    tshark -i eth0 -a duration:10 -w ten-seconds.pcap

## Notes

- In the container tshark runs as a normal user: dumpcap has the
  capabilities and the user is in the wireshark group, exactly as set up in
  L04.
- A .pcap written into /workspace is on your machine straight away, ready
  to open in the graphical Wireshark.
- Filter names changed over the years: it is tls, not ssl, and dhcp, not
  bootp. Old tutorials will tell you otherwise.

## More

man tshark, and man wireshark-filter for the display filter language.
