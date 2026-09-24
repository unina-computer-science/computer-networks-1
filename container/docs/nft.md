# nft — the firewall rules

Shows and changes the packet filter in the kernel. It replaced iptables:
same job, one syntax for IPv4 and IPv6, and rules you can read.

In this course it is used mostly to look, not to configure.

## The shape of it

Rules live in a chain, chains live in a table. A table has a family
(inet covers IPv4 and IPv6 together) and a name.

    sudo nft list ruleset                        everything
    sudo nft list table inet filter              one table
    sudo nft list chain inet filter input        one chain

## Reading a rule

    chain input {
        type filter hook input priority 0; policy drop;
        ct state established,related accept
        tcp dport { 22, 80, 443 } accept
    }

- policy drop is what happens to a packet no rule accepted.
- ct state established,related accept is the line that makes a stateful
  firewall stateful: replies to connections you started are let through
  without a rule for each one.
- Rules are read in order, and the first one that matches decides.

## Looking at the connection table

    sudo conntrack -L                            everything the kernel tracks
    sudo conntrack -L -p tcp --dport 443

That is where established comes from: the kernel remembers the connections
it has seen, and the firewall asks it.

## Changing things

    sudo nft add rule inet filter input tcp dport 5000 accept
    sudo nft flush ruleset                       careful: removes everything

Inside the container this is harmless, and it is the only place you should
experiment.

## More

man nft is long but well written; man nft then search for "syntax". The
iptables equivalents are in man iptables-translate, useful when you meet
old rules.
