# nvim — the editor in the container

Neovim, configured for this course: C, four languages of syntax highlighting,
clangd, and one key that compiles and runs what you are looking at. This page
is what you need to work in it. Nobody expects you to like it on the first
day.

If you would rather use your own editor, do: your files are in
~/cn1-workspace on your own machine, and the container is only where you
compile and run.

## Modes, which is the one thing to understand

A normal editor is always ready to type. Neovim is not: it starts in normal
mode, where letters are commands, and you switch to insert mode to write.

    i           start writing, where the cursor is
    a           start writing, one character further right
    o           open a new line below and start writing
    Esc         stop writing, back to normal mode

Everything else on this page assumes normal mode. If something does not work,
press Esc first: you were probably still in insert mode.

## Staying alive

    Space w     save
    Space q     close the window
    :w Enter    save, the long way
    :q! Enter   quit, throwing away changes
    :wq Enter   save and quit
    u           undo
    Ctrl-r      redo

Space is the leader key: press it, wait half a second, and a menu appears with
everything that starts with it. That menu is which-key, and it is the fastest
way to remember what you forgot.

## Moving

    h j k l     left, down, up, right
    w  b        forward, back, one word
    0  $        start, end of the line
    gg  G       top, bottom of the file
    Ctrl-d      half a screen down, keeping the cursor centred
    Ctrl-u      half a screen up
    12G         go to line 12
    { }         previous, next empty line

Line numbers are relative: what you see beside a line is how far it is from
the cursor, so 5k goes up five lines and 3j down three. The absolute number of
the line you are on is shown in place of the zero.

## Editing

Commands compose: an operator plus a movement.

    dd          delete the line
    dw          delete to the end of the word
    d$          delete to the end of the line
    yy          copy the line          (y for yank)
    p  P        paste after, before the cursor
    cw          change the word: delete it and start writing
    x           delete one character
    3dd         three lines at once, and the same for the others

Select with v, then a movement; V selects whole lines. In visual mode J and K
move the selection down and up, which is how you reorder lines without
retyping them.

Space p pastes over a selection without losing what you had copied — the
default would overwrite it, which is the most annoying thing Vim does.

## Searching

    /word       search forward, Enter to accept
    ?word       search backwards
    n  N        next, previous match, always centred on screen
    Esc         clear the highlighting
    *           search for the word under the cursor

Search ignores case unless you type a capital: /open finds Open, /Open does
not find open.

    :%s/old/new/g        replace everywhere
    :%s/old/new/gc       the same, asking each time

## Compiling and running, without leaving

    Space r     save, compile and run the C file you are in
    Space R     the same, asking for arguments first

It compiles with the line this course uses:

    gcc -Wall -Wextra -pthread -g

and adds -lssl -lcrypto by itself if the file includes OpenSSL. The program
runs in a terminal split below.

In that terminal you are in terminal mode, where keys go to the program:

    Ctrl-C            stop the program
    Ctrl-\ Ctrl-n     back to normal mode, to scroll and read
    Space q           close the split

## Files and windows

    -                 open the file explorer, in the current directory
    Space f           find a file by name
    Space g           search a text in every file
    Space b           switch between open files
    :e path/file.c    open a file by name

The explorer is oil: it shows the directory as a normal buffer. Move with
j and k, Enter to enter, - to go up, :w to apply changes — renaming a file
there is editing a line and saving it.

    :split            a second window, horizontally
    :vsplit           vertically
    Ctrl-h j k l      move between windows
    Ctrl-arrows       resize the current one

## What clangd gives you

clangd reads your C as a compiler would, while you type.

    gd                go to the definition of what is under the cursor
    K                 show the documentation: prototype, type, comment
    Space e           show the error on this line in full
    [d   ]d           previous, next problem in the file
    Ctrl-Space        completion (in insert mode; it does not pop up by itself)

The red marks in the left column are its diagnostics. They are not always
errors: many are warnings you would have got from gcc anyway, an hour later.

Completion does not appear on its own, on purpose: it would get in the way
while you are learning the calls. Ask for it with Ctrl-Space, Tab and
Shift-Tab to move in the list, Enter to accept.

## Undo that survives

Close the container, come back tomorrow, open the same file: u still works.
The history is in /workspace/.nvim-undo, which lives on your machine like the
rest of your work.

## Copy and paste with the outside world

y copies inside Neovim, and in terminals that support OSC 52 — Windows
Terminal, iTerm2, kitty, WezTerm, Alacritty, foot — it reaches your own
clipboard as well. In the macOS Terminal and in GNOME Terminal it does not:
there, select with the mouse.

Pasting *into* Neovim from outside is the terminal's job, not Neovim's:
Ctrl-Shift-V or middle click, depending on your terminal.

## Three things that will confuse you once

- **Squares instead of icons** — your terminal is missing a Nerd Font. It is
  a font problem on your machine, not a container one.
- **Your changes to the configuration disappear.** The configuration lives in
  the image, in /opt/cn1/nvim, and the container is thrown away every time.
  To change it for good, change it in the repository and rebuild the image.
  For the same reason :Lazy cannot install or update plugins: they are fixed
  when the image is built, so that the editor works with no network at all.
- **Your searches start over every time.** What telescope remembers of your
  last searches, and the marks that take you back where you were, live in the
  container and go away with it. The undo history is the one exception: that
  is in /workspace, on your machine.

## More

    :help topic       the manual, inside the editor
    :Tutor            a half-hour hands-on tutorial. Worth it on day one
    Space h           search the manual by keyword

The configuration is four short files in the repository, under
container/nvim/: options, keymaps, plugins. Reading them is a reasonable way
to find out what else is in there.
