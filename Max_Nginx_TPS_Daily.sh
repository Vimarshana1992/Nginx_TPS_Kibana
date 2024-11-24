#!/bin/bash

# Input file for maximum TPS per hour
max_tps_hourly="/var/log/nginx/max_tps_hourly.log"

#Output file for max tps daily
max_tps_daily="/var/log/nginx/max_tps_daily.log"

# Get the date for the day before the current date in the format "day month year"
previous_date=$(date -d "yesterday" "+%d %b %Y")

# Extract the last 24 records from max_tps_hourly
tail -n 24 "$max_tps_hourly" | awk -v date="$previous_date" '
{
    tps = $5;  # Assuming the TPS is in the 5th field

    # Update the maximum TPS
    if (tps > max_tps) {
        max_tps = tps;
    }
}
END {
    # Print the maximum TPS to the output file
    print date,max_tps >> "'$max_tps_daily'";
}
