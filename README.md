# perfectputty
PuTTY comes with a number of really bad default settings, and to make things worse changing the 
default session doesn't update any of the old entries you've made.  If you want to edit your existing 
session en masse will have to resort to exporting a .reg file, editing and re-importing.  That's why
it's so important to get your settings PERFECT before you even begin using Putty.

I've put together some resources to change the defaults to what I consider sane and beautiful settings.

## Install

- Right click the 'default-settings.reg' and merge into your registry.
- Install the font.
- Put the pop.wav somewhere you can live and point the default bell there.


## Features

### Sweet color settings
I started with [jellybeans](https://github.com/nanotech/jellybeans.vim) and made modifications with the following
goals:

- Colors should stay true to their ANSI description, ANSI RED should be somewhat red.
- No invisible output!  The stock PuTTY color scheme makes it hard to see output in some cases, and impossible in others.
- Clarity and contrast. 

### Inconsolata: the perfect console font 
I evaluated 'consolas', 'anonymous pro', 'lucida console' and 'source code pro'.  Anonymous didn't feel dense
enough for console and the others had various defects in rendering.  Inconsolata rendered perfectly and is 
very readable.

### Less annoying bell

### Sane default settings
- Never close the window when you type "exit"
- Don't ask to close window
- Big scrollback buffer
- Don't reset the scroll on display activity
- Reset scroll on keypress
- 4 pixel gap between the text and the edge of the window
- Blinking vertical cursor
- Fullscreen on alt-enter
- UTF-8
- No change to copy paste behaviour, I'm used to it
- null packet keepalives every 60 seconds
- SSH compression on
- Warn if it's not AES


### Terminal-type string
Maybe: Putty defaults to the "xterm" string, which some Linuxes limit to 16 colors.  Could change it to "xterm-256color" 
for more terminal colors, but it breaks our color scheme.
