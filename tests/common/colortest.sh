#!/bin/bash
ansi_mappings=(
  Black
  Red
  Green
  Yellow
  Blue
  Magenta
  Cyan
  White
  Bright_Black
  Bright_Red
  Bright_Green
  Bright_Yellow
  Bright_Blue
  Bright_Magenta
  Bright_Cyan
  Bright_White
)
colors=(
  base00
  base08
  base0B
  base0A
  base0D
  base0E
  base0C
  base05
  base03
  base08
  base0B
  base0A
  base0D
  base0E
  base0C
  base07
  base09
  base0F
  base01
  base02
  base04
  base06
)

echo;

for padded_value in `seq -w 0 15`; do
  color_variable="color${padded_value}"
  eval current_color=\$${color_variable}
  current_color=$(echo ${current_color//\//} | tr '[:lower:]' '[:upper:]') # get rid of slashes, and uppercase
  non_padded_value=$((10#$padded_value))
  base16_color_name=${colors[$non_padded_value]}
  current_color_label=${current_color:-... }
  ansi_label=${ansi_mappings[$non_padded_value]} 
  block=$(printf "\x1b[48;5;${non_padded_value}m___________________________")
  foreground=$(printf "\x1b[38;5;${non_padded_value}m$color_variable")
  printf "%s %s %s %-30s %s\x1b[0m\n" $foreground $base16_color_name $current_color_label ${ansi_label:-""} $block
done;

echo;

T='perfect'

for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
           '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
           '  36m' '1;36m' '  37m' '1;37m';
  do FG=${FGs// /}
  echo -en " \033[$FG  $T  "
  for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
    do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
  done
  echo;
done
echo
