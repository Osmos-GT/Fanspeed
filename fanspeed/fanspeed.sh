#!/bin/bash
#Custom fan speed script ver 0.5

#This won't work without lm-sensors installed and running
if [ $(systemctl is-active lm-sensors.service) != "active" ]; then
    echo "Lm-sensors service is not installed or not active. Exiting."
    exit 0
fi

#Let's determine where the fan 1 inpit is exactly
for input in $(find /sys/class/hwmon/hwmon*/ -type f -name fan1_input); do
  if ! [ $(cat $input) -eq 0 ]; then
  HWMON_PATH=$( echo $input | cut -d/ -f1-5 )
  fi
done

DEFAULT_SPEED=`cat /etc/fanspeed/default_speed`
PWM_ENABLED_BINARY_STATUS=$(cat $HWMON_PATH/pwm1_enable)
CURRENT_SPEED=$(cat $HWMON_PATH/pwm1)
CUSTOM_SPEED=$1

#Custom speed value can only be set  in certain limit
if [ -n "$CUSTOM_SPEED" ] && [ "$CUSTOM_SPEED" -eq "$CUSTOM_SPEED" ] 2>/dev/null; then
  if [[ "$CUSTOM_SPEED" -lt "0" ]] || [[ "$CUSTOM_SPEED" -gt "255" ]]; then
  echo "Custom fan speed value should be between 0 and 255. Exiting."
  exit 0
  fi
fi

get_pwm_status() {
if [[ $PWM_ENABLED_BINARY_STATUS -eq "1" && $CURRENT_SPEED -lt "255" ]] || [[ $PWM_ENABLED_BINARY_STATUS -eq "0" && $CURRENT_SPEED -eq "255" ]]; then
    PWM_STATUS=enabled
    else
    PWM_STATUS=disabled
fi
}

pwm_enable() {
if  [ $PWM_ENABLED_BINARY_STATUS -ne 1 ] && [ $CURRENT_SPEED -lt 255 ]; then
    echo 1 > $HWMON_PATH/pwm1_enable && echo "Manual PWM fan speed control enabled"
    else
    echo "Manual PWM fan speed control is already enabled"
fi
}

set_default_speed() {
    if [ $CURRENT_SPEED -eq $DEFAULT_SPEED ]; then
    echo "Default speed of $DEFAULT_SPEED is already set up"
    else
    echo $DEFAULT_SPEED > $HWMON_PATH/pwm1 && echo "Default fan speed of $DEFAULT_SPEED is set"
fi
}

set_custom_speed() {
    echo $CUSTOM_SPEED > $HWMON_PATH/pwm1 && echo "Custom fan speed of $CUSTOM_SPEED is set"
}

get_current_rpm() {
CURRENT_RPM=$(cat $HWMON_PATH/fan1_input)
}

#If no arguments or status given
if [ -z "$1" ] || [ "$1" = "status" ]; then
    echo "Current HWMON path:      $HWMON_PATH"
    get_pwm_status && echo "Manual PWM control:      $PWM_STATUS"
    get_current_rpm && echo "Current fan speed:       $CURRENT_RPM RPM"
    echo "Current fan speed value: $CURRENT_SPEED"
    echo "Default fan speed value: $DEFAULT_SPEED"
#On boot
    elif [ "$1" = "default" ]; then
    pwm_enable
    set_default_speed
#If custom speed value is specified    
    elif [ "$1" -eq "$1" ] 2>/dev/null; then
    set_custom_speed
#If user is a dumbass    
    else
    echo "Custom fan speed script ver 0.5

Script options:
default       Set default speed
status        Show current RPM, PWM status and speed value. Also shown when no arguments are given.
<speed value> Set custom speed value.
  "
fi
