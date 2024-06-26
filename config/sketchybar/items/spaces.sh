#!/bin/bash

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12") #"13" "14" "15" "16" "17" "18" "19" "20")


sid=0
for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))

  space=(
    space=$sid
    # associated_space=$sid
    # associated_display=1
    ignore_association=on
    icon="${SPACE_ICONS[i]}"
    icon.padding_left=5
    icon.padding_right=7
    label.padding_left=0
    label.padding_right=10
    icon.highlight_color=$WHITE
    label.color=$GREY
    label.highlight_color=$WHITE
    label.font="sketchybar-app-font:Regular:16.0"
    label.y_offset=-1
    background.color=0xbbF17013
    background.border_color=$BACKGROUND_2
    background.height=25
    background.corner_radius=4
    script="$PLUGIN_DIR/space.sh"
  )

  sketchybar --add space space.$sid left    \
             --set space.$sid "${space[@]}"
             # --subscribe space.$sid mouse.clicked space_change space_windows_change display_change
done

# space_creator=(
#   icon=􀆊
#   icon.font="$FONT:Heavy:16.0"
#   padding_left=10
#   padding_right=8
#   label.drawing=off
#   display=active
#   click_script='yabai -m space --create'
#   script="$PLUGIN_DIR/space_windows.sh"
#   icon.color=$WHITE
# )

# sketchybar --add item space_creator left               \
#            --set space_creator "${space_creator[@]}"   \
#            --subscribe space_creator space_windows_change
