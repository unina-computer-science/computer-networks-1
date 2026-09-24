# ftp — the file transfer protocol, by hand

A client for FTP, which is here for one reason: it is old enough to be simple
and honest, so you can watch a whole protocol go by in the clear. Nobody
should still use it to move files — that is what sftp and HTTPS are for —
but everybody should see one session at least once.

## A session

    $ ftp ftp.gnu.org
    Name: anonymous
    Password: your@email
    ftp> ls
    ftp> cd gnu
    ftp> get README
    ftp> quit

## Commands worth knowing

    ls, cd, pwd         as in a shell, but on the server
    get FILE, put FILE  one file down, one file up
    mget PATTERN        several
    binary, ascii       transfer mode: binary unless you know why not
    passive             switch between active and passive mode
    bye / quit          leave

## Why two connections

FTP uses one connection for commands and a second one for every transfer.
Who opens that second one is the difference between the two modes: in active
mode the server connects back to you, which almost never works from behind a
NAT; in passive mode you connect to the server, which is why passive is the
default today.

Watch it with tshark -i eth0 -f 'tcp port 21': you will see the commands in
plain text — including USER and PASS.

## Notes

- On Debian and Ubuntu the package is now tnftp; the command is still ftp.
- Browsers removed ftp:// support in 2021.
- Anonymous FTP is a convention, not a protocol feature: user anonymous,
  and an email address as the password.

## More

man ftp, and help inside the client. For the secure version: man sftp.
