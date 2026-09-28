#!/usr/bin/env bash

# Noctalia's caffeine, not ~/.local/bin/caffeine. Noctalia sets a Wayland idle
# inhibitor, which hypridle honours, and its bar widget then shows the real
# state. The old script used systemd-inhibit, which only holds off logind and
# left hypridle free to lock and blank the screen anyway.
caffeine() {
    case "$1" in
        --on)  noctalia msg caffeine-enable ;;
        --off) noctalia msg caffeine-disable ;;
    esac
}

if [[ $(powerprofilesctl get) == "performance" ]] ; then
    caffeine --on & 
else
    caffeine --off &
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
                caffeine --on &
            else
                caffeine --off &
            fi
        fi
        ;;
    esac
done
