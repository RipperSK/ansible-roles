#!/bin/bash
# Script: cpu_temp_monitor.sh
# Description: Get temperature for specific CPU core
# Usage: ./cpu_temp_monitor.sh <core_number>

CORE_NUM=$1

# Validate input
if [[ ! "$CORE_NUM" =~ ^[0-9]+$ ]]; then
    echo "Error: Core number must be numeric"
    exit 1
fi

# Try to get temperature from sensors command
if command -v sensors &> /dev/null; then
    # Parse sensors output for specific core
    TEMP=$(sensors | grep "^Core $CORE_NUM" | awk '{print $3}' | sed 's/+//;s/°C//')
    if [ -n "$TEMP" ]; then
        echo "$TEMP"
        exit 0
    fi
fi

# Fallback: Try reading from sysfs thermal zone
THERMAL_FILE="/sys/class/thermal/thermal_zone${CORE_NUM}/temp"
if [ -f "$THERMAL_FILE" ]; then
    # Temperature is in millidegrees, convert to degrees
    TEMP=$(cat "$THERMAL_FILE")
    echo "scale=1; $TEMP / 1000" | bc
    exit 0
fi

# Alternative: Try hwmon interface
for hwmon in /sys/class/hwmon/hwmon*/temp*_label; do
    if [ -f "$hwmon" ]; then
        LABEL=$(cat "$hwmon")
        if [[ "$LABEL" =~ "Core $CORE_NUM" ]]; then
            TEMP_FILE="${hwmon%_label}_input"
            if [ -f "$TEMP_FILE" ]; then
                TEMP=$(cat "$TEMP_FILE")
                echo "scale=1; $TEMP / 1000" | bc
                exit 0
            fi
        fi
    fi
done

echo "Error: Unable to read temperature for Core $CORE_NUM"
exit 1

