#!/bin/sh

if hyprctl clients -j | jq -e '.[] | select(.class == "filemanager")' > /dev/null; then
    hyprctl dispatch togglespecialworkspace "filemanager"
else
    hyprctl --batch "
        dispatch togglespecialworkspace filemanager;
        dispatch exec kitty --class=filemanager --title=float sh -c ranger
    "
fi
