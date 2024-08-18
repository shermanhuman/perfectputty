# perfectputty
PuTTY comes with a number of really ugly default settings. These settings date back to 1998 and may not be ideal if you're connecting to a modern linux terminal server.  You'll want to change them.

Editing your settings as you go can be painful: all settings are edited on a session by session basis.  In order to edit existing sessions en masse you will have to resort to exporting a .reg file, editing and re-importing.  That's why it's so important to get your settings PERFECT before you even begin using PuTTY.

I've put together some resources to change the defaults to what I consider sane and beautiful settings.

## Install
- Look over 'default-settings.reg' and then merge it into your registry.
- Install the font.  Make sure the PuTTY default config uses it.
- Put the pop.wav somewhere you can live with and point the default bell there.

## Features

### perfect16 - 16 super sweet colors for Putty
I started with [jellybeans](https://github.com/nanotech/jellybeans.vim) and made modifications with the following
goals:

- 16 color term for the default, 256 color schemes should probably be handled server side
- Dark background, just like your favorite IDE
- Colors should stay true to their ANSI description, ANSI RED should be somewhat red.
- No invisible output!  The stock PuTTY color scheme makes it hard to see output in some cases, and impossible in others.
- Clarity, comfort and contrast. 

![version2-color](https://cloud.githubusercontent.com/assets/15676339/20086123/255acc82-a52b-11e6-8fae-41db88fc101e.PNG)

![version2-fun](https://cloud.githubusercontent.com/assets/15676339/20086277/45607f26-a52c-11e6-81ab-70da91149281.PNG)

### Deja Vu: a mature console font
Aside from my subjective preference, font selection criteria:

- Readability against dark background
- Render quality at smaller sizes  (pt size isn't a criteria)
- Render quality on PuTTY
- [Unicode range 25 line drawing support](http://www.alanflavell.org.uk/unicode/unidata25.html) 

[Deja Vu Mono](http://dejavu-fonts.org) renders nicely at 12pts on 1920x1080 native resolution LCDs.  It's slightly large for my taste, but it also has a very full unicode support and is actively developed and supported.

You might want to consider this Deja Vu Mono fork: [Hack](https://sourcefoundry.org/hack/).

![version2-ascii](https://cloud.githubusercontent.com/assets/15676339/20086121/2462a412-a52b-11e6-8aa0-3d388849b102.PNG)

Inconsolata is very nice, but at 12 pts I noticed some thin lines and scraggly rendering.  It's also missing the ANSI line drawing and ANSI art glyphs used in some linux console utilities.  

If you really want to use it I've included 'inconsolata-fallback.reg' to attempt to set the 'Consolas' font as a fallback to 'Inconsolata'.  The procedure [is described here](https://msdn.microsoft.com/en-US/globalization/mt662331), and consists of editing the registry key:

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

# Windows 11 and Windows Terminal Support
For Windows 11 users, I've extended support to Windows Terminal.



## Installation for Windows Terminal
1. Navigate to the `win11` folder in this repository.
2. Run the `Install-wt-color-scheme.ps1` script in PowerShell:
   ```
   .\Install-wt-color-scheme.ps1
   ```
3. Follow the prompts to install the "Perfect" color scheme and apply it to your desired profiles.

This script does the following:
- Locates your Windows Terminal settings file
- Adds the "Perfect" color scheme to your available schemes
- Allows you to apply the scheme to one, multiple, or all profiles

### Testing the Color Scheme
After installation, you can test the color scheme using the provided `ColorTest.ps1` script:
1. Navigate to the `win11\tests` folder.
2. Run the script:
   ```
   .\ColorTest.ps1
   ```
This will display a comprehensive color test, showing how different colors render in your terminal.

## PowerShell Profile
I've also included a bonus PowerShell profile (`Microsoft.PowerShell_profile.ps1`) that enhances your command-line fun:
- Sets up a custom prompt with git integration
- Uses the "Perfect" color scheme 

To install the PowerShell profile:
1. Copy `Microsoft.PowerShell_profile.ps1` to your PowerShell profile location (typically `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`) or edit it from the command line `notepad $PROFILE` in the shell you want to edit.
2. Restart PowerShell or run `. $PROFILE` to load the new profile.
