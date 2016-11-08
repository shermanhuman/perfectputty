#!/bin/bash

initializeANSI()
{
  esc=""

  blackf="${esc}[30m";   redf="${esc}[31m";    greenf="${esc}[32m"
  yellowf="${esc}[33m"   bluef="${esc}[34m";   magentaf="${esc}[35m"
  cyanf="${esc}[36m";    grayf="${esc}[37m"
  
  blackb="${esc}[40m";   redb="${esc}[41m";    greenb="${esc}[42m"
  yellowb="${esc}[43m"   blueb="${esc}[44m";   magentab="${esc}[45m"
  cyanb="${esc}[46m";    grayb="${esc}[47m"

  boldon="${esc}[1m";    boldof="${esc}[22m"
  italicson="${esc}[3m"; italicsoff="${esc}[23m"
  ulon="${esc}[4m";      uloff="${esc}[24m"
  invon="${esc}[7m";     invoff="${esc}[27m"

  reset="${esc}[0m"
}
initializeANSI
cat ascii/mike.ascii ascii/big.ascii ascii/circle.ascii ascii/future.ascii ascii/pagga.ascii
cat << EOF
${boldon}
${redf}      ██▓███  ▓█████  ██▀███    █████▒▓█████  ▄████▄  ▄▄▄█████▓
     ▓██░  ██▒▓█   ▀ ▓██ ▒ ██▒▓██   ▒ ▓█   ▀ ▒██▀ ▀█  ▓  ██▒ ▓▒
     ▓██░ ██▓▒▒███   ▓██ ░▄█ ▒▒████ ░ ▒███   ▒▓█    ▄ ▒ ▓██░ ▒░
     ▒██▄█▓▒ ▒▒▓█  ▄ ▒██▀▀█▄  ░▓█▒  ░ ▒▓█  ▄ ▒▓▓▄ ▄██▒░ ▓██▓ ░ 
     ▒██▒ ░  ░░▒████▒░██▓ ▒██▒░▒█░    ░▒████▒▒ ▓███▀ ░  ▒██▒ ░ 
     ▒▓▒░ ░  ░░░ ▒░ ░░ ▒▓ ░▒▓░ ▒ ░    ░░ ▒░ ░░ ░▒ ▒  ░  ▒ ░░   
     ░▒ ░      ░ ░  ░  ░▒ ░ ▒░ ░       ░ ░  ░  ░  ▒       ░    
     ░░          ░     ░░   ░  ░ ░       ░   ░          ░      
                 ░  ░   ░                ░  ░░ ░               
                                             ░                 
${reset} 


                        ${boldon}├──  SOME ANSI CHARACTERS ───┤${boldof}
        █ ▓ ▒ ░ ▄ ▀ ▐ ▌ ● ═ ║ ╔ ╦ ╗ ╚ ╩ ╝ ■ ▬ ▲ ▼ ◄ ► ┌┼└┼└ ┐┌ ─ ┤├


              ╔═══════════════════════════════════════════════════╗
              ║                ${boldon}CONSOLE CODE'S CHART${boldof}               ║
              ║                                                   ║
              ║  ${boldon}COLOR    TEXT BACKGROUND  COLOR          TEXT${boldof}    ║
              ║  ${grayb}${blackf}Black      30${reset}     40      ${boldon}${blackf}Dark Gray      1;30${boldoff}${reset}    ║
              ║  ${redf}Red        31     41      ${boldon}${redf}Light Red      1;31${boldof}${reset}    ║
              ║  ${greenf}Green      32     42      ${boldon}${greenf}Light Green    1;32${boldof}${reset}    ║
              ║  ${yellowf}Yellow     33     43      ${boldon}${yellowf}Light Yellow   1;33${boldof}${reset}    ║
              ║  ${bluef}Blue       34     44      ${boldon}${bluef}Light Blue     1;34${boldof}${reset}    ║
              ║  ${magentaf}Magenta    35     45      ${boldon}${magentaf}Light Magenta  1;35${boldof}${reset}    ║
              ║  ${cyanf}Cyan       36     46      ${boldon}${cyanf}Light Cyan     1;36${boldoff}${reset}    ║
              ║  ${grayf}Light Gray 37     47      ${blackb}${boldon}${grayf}White          1;37${boldof}${reset}    ║
              ║                                                   ║
              ║  ${boldon}FORMAT         FORMAT${boldof}                            ║
              ║  reset          0            underscore on,       ║
              ║  ${boldon}bold           1${boldof}  default foreground color 38    ║
              ║  half-bright    2           underscore off,       ║
              ║  ${ulon}underline${uloff}      ${ulon}4${uloff}  default foreground color 39    ║
              ║  blink          5  default background color 49    ║
              ║  inverse        7                                 ║
              ║  conceal        8                                 ║
              ║  normal        22            ${boldon}man console_codes${boldof}    ║
              ║  underline off 24                                 ║
              ║  blink off     25                                 ║
              ║  inverse off   27                  mewbies.com    ║
              ║                                                   ║
              ╚═══════════════════════════════════════════════════╝

EOF