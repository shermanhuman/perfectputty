# perfectputty
PuTTY comes with a number of really ugly default settings, and all settings are edited on a session by session basis. 
If you want to edit your existing sessions en masse will have to resort to exporting a .reg file, editing and re-importing.  
That's why it's so important to get your settings PERFECT before you even begin using PuTTY.

I've put together some resources to change the defaults to what I consider sane and beautiful settings.

## Install

- Look over 'default-settings.reg' and then merge it into your registry.
- Install the font.  Make sure PuTTY is configured to use it.
- Put the pop.wav somewhere you can live and point the default bell there.


## Features

### Sweet color settings
I started with [jellybeans](https://github.com/nanotech/jellybeans.vim) and made modifications with the following
goals:

- Colors should stay true to their ANSI description, ANSI RED should be somewhat red.
- No invisible output!  The stock PuTTY color scheme makes it hard to see output in some cases, and impossible in others.
- Clarity and contrast. 

![puttycolors-3](https://cloud.githubusercontent.com/assets/15676339/20016153/9b67ea84-a27b-11e6-8baf-09ddd03660f9.PNG)
![puttycolors](https://cloud.githubusercontent.com/assets/15676339/20016156/9b72a280-a27b-11e6-8d39-a2b854f461e0.PNG)
![puttycolors-2](https://cloud.githubusercontent.com/assets/15676339/20016154/9b6e22e6-a27b-11e6-9167-24cfd2148ce4.PNG)
![puttycolors-4](https://cloud.githubusercontent.com/assets/15676339/20016339/3f34440a-a27c-11e6-843d-2b14e079ec11.PNG)

### Inconsolata: the perfect console font 
I evaluated 'consolas', 'anonymous pro', 'lucida console' and 'source code pro'.  Anonymous didn't feel dense
enough for console and the others had various defects in rendering.  Inconsolata rendered perfectly and is 
very readable.  Of course there are many variables in rendering fonts, YMMV.

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
Maybe: PuTTY defaults to the "xterm" string, which some Linuxes limit to 16 colors.  Could change it to "xterm-256color" 
for more terminal colors, but it breaks our color scheme.
