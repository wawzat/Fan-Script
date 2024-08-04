#!/bin/bash

# Tested to work on Dell PowerEdge R420 and R730 Servers

source /home/jlucas/scripts/config.txt

SERVERTYPE=$(ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD fru | grep PowerEdge | grep "Product Name" | sed 's/.*PowerEdge //')

# Get temp measurements from IPMITool.
# INLET TEMP, CPU1 & CPU2

TEMPERATURES=$(ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD sdr type temperature)
TODAY=$(TZ=":US/Pacific" date)

# Print the header
printf "%-25s %-15s\n" "Date" "Readings"
printf "%-25s %-15s\n" "-------------------------" "-----------------"

# Print the date
printf "%-25s\n" "$TODAY"

# Print each temperature reading on a new line
echo "$TEMPERATURES" | while IFS= read -r line; do
    printf "%-25s %-15s\n" "" "$line"
done

FANS=$(ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD sdr type fan)

# Print each temperature reading on a new line
echo "$FANS" | while IFS= read -r line; do
    printf "%-25s %-15s\n" "" "$line"
done


echo "Server Type: $SERVERTYPE"

