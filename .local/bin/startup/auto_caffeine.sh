#!/usr/bin/env bash

CAFFEINE="$HOME/.local/bin/caffeine"

if [[ $(powerprofilesctl get) == "performance" ]] ; then
    "$CAFFEINE" --on & 
else
    "$CAFFEINE" --off &
fi

gdbus monitor \
    --system \
    --dest net.hadess.PowerProfiles \
    --object-path /net/hadess/PowerProfiles |
while IFS= read -r line; do
    case "$line" in
        *"PropertiesChanged"* )

        profile=$(printf "%s\n" "$line" | awk -F"<'|'>" '/ActiveProfile/{print $2}')
        
        if [[ -n "$profile" ]]; then
            if [[ "$profile" == "performance" ]]; then 
                "$CAFFEINE" --on &
            else
                "$CAFFEINE" --off &
            fi
        fi
        ;;
    esac
done
