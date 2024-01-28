#!/bin/sh

# Set CONFIG_DIR manually, in case this script is called from Yabai.
if [[ -z "$CONFIG_DIR" ]]
then
   CONFIG_DIR="$HOME/.config/sketchybar/"
fi

CURRENT_SPACES="$(yabai -m query --displays | jq -r '.[].spaces.[]')"

while read -r line
do
    for space in $line
    do
        icon_strip=""
        apps=$(yabai -m query --windows --space $space | jq -r "unique_by(.app).[].app")
        space_visible=$(yabai -m query --spaces --space $space | jq -r '."is-visible"')
        args+=(--set space.$space background.drawing="$space_visible")
        if [[ "$space_visible" == "true" || -n "$apps" ]]
        then
            args+=(--set space.$space drawing=on)
        else
            args+=(--set space.$space drawing=off)
        fi
        if [[ -n "$apps" ]]
        then
            while IFS= read -r app; do
                icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
            done <<< "$apps"
            args+=(--set space.$space label="$icon_strip" label.drawing=on)
        else
            args+=(--set space.$space label.drawing=off)
        fi
    done
done <<< "$CURRENT_SPACES"

sketchybar "${args[@]}"
