# curl — fetch a URL, and see how

Makes one HTTP request and prints the reply. Where a browser hides everything
— caches, parallel connections, automatic HTTPS — curl does exactly what you
asked and nothing else, which is why it is the right tool while you are
learning what a request looks like.

## Options used in this course

    -s                silent: no progress meter
    -I                headers only, with a HEAD request
    -i                headers and body
    -o FILE           write the body to a file (-o /dev/null to throw it away)
    -H 'Name: value'  add a header
    -A 'agent'        set the User-Agent
    -L                follow redirects
    -w '%{...}'       print one value when it is over
    --tls-max 1.2     do not go above that TLS version

## Examples

    curl -sI http://info.cern.ch/hypertext/WWW/TheProject.html
    curl -s -o /dev/null -w '%{http_code}\n' https://www.unina.it
    curl -s -H 'Connection: close' http://example.com
    curl -s --tls-max 1.2 -o /dev/null https://www.unina.it   forces TLS 1.2
    curl -s https://ifconfig.me                              your public address

## Things worth knowing

- It does not upgrade to HTTPS. Ask for http:// and you get http://,
  which is what you want when capturing: a browser would quietly switch.
- Redirects are not followed unless you say -L, so a 301 stays a
  301 and you can see it.
- The User-Agent matters. Some sites answer 403 to curl's default one
  and 200 to a browser's. If a page works in Firefox and not here, try
  -A 'Mozilla/5.0' before blaming the network.
- -w is how you measure: %{http_code}, %{time_total},
  %{time_connect}, %{size_download}.

## More

man curl, and curl --help all for the option list, which is long. For
downloading rather than inspecting, wget is usually simpler.
