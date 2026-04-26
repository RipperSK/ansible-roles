#!/bin/bash
cd /root/smartctl_reports/ || exit 1
report="./smartctl_report-$(date +%F).txt"

hdd_attrs="Power_On_Hours|Reallocated_Sector_Ct|Temperature|Uncorrect|Power_Cycle_Count|Head_Health"
nvme_attrs="Power_On_Hours|Available_Spare|Temperature|Unsafe_Shutdowns|Media_Errors"

for d in /dev/sd? /dev/nvme?n1; do
  [ -e "$d" ] || continue

  echo "$d ===================="

  if [[ "$d" == /dev/nvme* ]]; then
    /usr/sbin/smartctl -a "$d" | grep -iE "$nvme_attrs"
  else
    /usr/sbin/smartctl -a "$d" | grep -iE "$hdd_attrs"
  fi

done >> "$report"
