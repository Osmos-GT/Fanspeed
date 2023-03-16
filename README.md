# Fanspeed

This script takes speed control of a PWM1 fan from UEFI/BIOS and sets up new speed value specified in default_speed file. Unlike what SpeedFan utility does, speed is constant and does not depend on any temperature readings.

It is developed to learn bash scripting, fiddle with SystemD and simultaneously solve a practical issue.

The script can be started at boot via Systemd timer. To do so, files in this repo should be placed in /etc directory. Enable respective systemd timer afterwards.

To use this script you should have lm-sensors installed and running.

Script options:

**default**   Set default speed specified in default_speed file

**status**    Show current RPM, PWM status and speed value. Also shown when no arguments are given.

**[value]**   Set custom speed value which is an integer between 0 and 255.
