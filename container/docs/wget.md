# wget — download a file

Retrieves a URL and saves it. Where curl prints to standard output and is
built for looking, wget is built for getting: it names the file for you,
shows progress, and resumes.

## Options used in this course

    -O FILE   save with this name (-O - to print instead)
    -c        continue an interrupted download
    -q        quiet
    --spider  do not download, just check it is there
    -S        show the server's response headers

## Examples

    wget http://speedtest.tele2.net/10MB.zip          measure a download
    wget -q -O - http://example.com               print it instead of saving
    wget --spider -S http://example.com               headers only, no body

## Things worth knowing

- With no -O, wget writes into the current directory using the name from
  the URL, and if that name exists already it adds .1, .2, and so on.
- Run from a script with no terminal, wget redirects its own output to
  wget-log instead of the screen. If you see nothing, look there.
- For anything you want to inspect rather than keep, curl -i is more direct.

## More

man wget.
