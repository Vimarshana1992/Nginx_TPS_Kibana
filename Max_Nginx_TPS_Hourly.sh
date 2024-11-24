#!/bin/bash

# Path to the log file
log_file="/var/log/nginx/access.log"


# Temp file for storing hits per second last hour
last_hour_hits_per_second="/var/log/nginx/last_hour_hits_per_second.log"

# Output file for maximum TPS per hour
max_tps_hourly="/var/log/nginx/max_tps_hourly.log"

#Get the time range in UTC 1 Hour ago
SIX_AND_HALF_HOURS_AGO=$(date -d '390 minute ago' +"%d/%b/%Y:%H:%M:%S")
FIVE_AND_HALF_HOURS_AGO=$(date -d '331 minutes ago' +"%d/%b/%Y:%H:%M:%S")

# Process log file to count hits per second in last hour period 
awk -v start_time="$SIX_AND_HALF_HOURS_AGO" -v end_time="$FIVE_AND_HALF_HOURS_AGO" '{
    match($0, /\[([^]]+)\]/, arr);
    log_time = arr[1];
    if (log_time >= start_time && log_time <= end_time) {
        split(log_time, datetime, /[:\/ ]/);
        print datetime[1]" "datetime[2]" "datetime[3]" "datetime[4]" "datetime[5]" "datetime[6]" "datetime[7];
    }
}' $log_file | sort | uniq -c > $last_hour_hits_per_second


# Get the Maximum of the last_hour_hits_per_second and output to a file 

awk '
{
    # Extract the timestamp components
    split($0, arr, " ");
    tps = arr[1];
    year = arr[2];
    month = arr[3];
    day = arr[4];
    hour = arr[5];

    # Create a unique key for each hour
    window = year " " month " " day " " hour;

    # Update the maximum TPS for the window
    if (tps > max_tps[window]) {
        max_tps[window] = tps;
    }
}
END {
    # Print the results to the output file
    for (window in max_tps) {
        print window, max_tps[window] >> "'$max_tps_hourly'";
    }
}
' $last_hour_hits_per_second
