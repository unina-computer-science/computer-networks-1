# lynx — a browser that shows you the HTTP

A text-mode web browser. It is in this course because it does exactly one
request for the page you asked for: no images, no scripts, no prefetching, no
silent upgrade to HTTPS. When you capture its traffic, everything you see is
the page you asked for.

## Using it

    lynx http://info.cern.ch/hypertext/WWW/TheProject.html
    lynx -dump http://example.com          print the page and exit
    lynx -source http://example.com        print the HTML instead

Inside the browser: arrows to move between links, Enter to follow, g for a
new address, \ to see the HTML source, q to quit.

## What it is good for here

A modern browser fetches dozens of things for one page and reuses
connections, so a capture is hard to read. lynx makes one request and one
reply, which is what you want the first time you look at HTTP in Wireshark.

It also announces itself as Lynx and speaks HTTP/1.0 by default, so the
request is short enough to read in full.

## More

man lynx. For getting a page without a browser at all, curl is usually
what you want.
