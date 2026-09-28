#!/bin/sh
# Restart nvidia-powerd while the RTX is awake.
#
# nvidia-powerd reads the GPU/platform state once when it starts. Started
# while the card is runtime-suspended (normal in Hybrid mode a minute after
# boot) it settles on a bogus budget: P5, ~25 W, memory at 810 MHz, with
# "SW Thermal Slowdown" flagged at 50 C. Started while the card is awake it
# negotiates the full Dynamic Boost ceiling (measured 60 W in Hybrid with
# prime-run, 54 W in AsusMuxDgpu). So hold the GPU awake with a polling
# nvidia-smi for the few seconds around the restart.
nvidia-smi -l 1 >/dev/null 2>&1 &
hold=$!
sleep 3
systemctl restart nvidia-powerd.service
sleep 10
kill "$hold" 2>/dev/null
exit 0
