# perfectputty
PuTTY comes with a number of really ugly default settings. These settings date back to 1998 and may not be ideal if you're connecting to a modern linux terminal server.  You'll want to change them.

Editing your settings as you go can be painful as all settings are edited on a session by session basis.  In order to edit existing sessions en masse you will have to resort to exporting a .reg file, editing and re-importing.  That's why it's so important to get your settings PERFECT before you even begin using PuTTY.

I've put together some resources to change the defaults to what I consider sane and beautiful settings.

## Install
- Look over 'default-settings.reg' and then merge it into your registry.
- Install the font.  Make sure the PuTTY default config uses it.
- Put the pop.wav somewhere you can live with and point the default bell there.

## Features

### perfect16 - 21 super sweet colors for Putty
I started with [jellybeans](https://github.com/nanotech/jellybeans.vim) and made modifications with the following
goals:

- 16 color term for the default, 256 color schemes should probably be handled server side
- Dark background, just like your favorite IDE
- Colors should stay true to their ANSI description, ANSI RED should be somewhat red.
- No invisible output!  The stock PuTTY color scheme makes it hard to see output in some cases, and impossible in others.
- Clarity, comfort and contrast. 

![version2-color](https://cloud.githubusercontent.com/assets/15676339/20086123/255acc82-a52b-11e6-8fae-41db88fc101e.PNG)

### Deja Vu: a mature console font
Aside from my subjective preference, font selection criteria:

- Readability against dark background
- Render quality at smaller sizes  (pt size isn't a criteria)
- Render quality on PuTTY
- [Unicode range 25 line drawing support](http://www.alanflavell.org.uk/unicode/unidata25.html) 

[Deja Vu Mono](http://dejavu-fonts.org) renders nicely at 12pts on 1920x1080 native resolution LCDs.  It's slightly large for my taste, but it also has a very full unicode support and is actively developed and supported.

![version2-ascii](https://cloud.githubusercontent.com/assets/15676339/20086121/2462a412-a52b-11e6-8aa0-3d388849b102.PNG)

Inconsolata is very nice, but at 12 pts I noticed some thin lines and scraggly rendering.  It's also missing the ANSI line drawing and ANSI art glyphs used in some linux console utilities.  

If you really want to us it I've included 'inconsolata-fallback.reg' to attempt to set the 'Consolas' font as a fallback to 'Inconsolata'.  The procedure [is described here](https://msdn.microsoft.com/en-US/globalization/mt662331), and consists of editing the registry key:

    HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontLink\SystemLink

**Right now this isn't working correctly.**  The font does fall back and display the missing unicode characters, but it's not using Consolas.  Apparently just having an entry is enough to get it to fall back to whatever the default font is.  Much of the Windows Font subsystem is "there be dragons" kind of stuff dating back to Windows 3.11.  To quote the MSDN article: 

    "Editing/modifying the font link entries in the Registry can be done, but is NOT supported by Microsoft. The wrong font link entry can leave the system unstable and impacts machine performance."

Finally I wanted to mention [Input](http://input.fontbureau.com/).  This is a font that pays attention to the things you really want to see in a console/code font.  Aesthetically: I can dig it.  It has good support for Unicode line drawing but it's incomplete.  However it has a less liberal license and I can't distribute it here.  Here's a link to download:

http://input.fontbureau.com/download/

Of course there are many variables in rendering fonts, YMMV.

### Less annoying bell
The default is certainly jarring when you are using code completion, and many people just disable it.  I like having an 
audio cue, so I have included a brief and gentle sound.

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
- Terminal type string set to "putty"

Reference: http://dag.wiee.rs/blog/content/improving-putty-settings-on-windows
