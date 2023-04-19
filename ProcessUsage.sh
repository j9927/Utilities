#!/bin/bash

# -------------The top 5 processes by CPU utilisation-------------------------

top_processes=$(ps -eo pid,user,%cpu,cmd --sort=-%cpu | head -n 6 | tail -n 5)

# -------------Show the user the top 5 programmes and request authorization before terminating them.-------------------

echo "The programmes listed below consume the most CPU power:"
echo "$top_processes"
echo "Do you want to kill these processes? (y/n)"
read user_input

# ---------------if the user agrees to kill the processes.---------------------------------

if [[ $user_input == "y" ]]; then
  # Loop through each process and kill it
  while read -r pid user cpu cmd; do
    if [[ $user != "root" ]]; then
      echo "Killing process $pid ($cmd) started by user $user..."
      # Send a SIGKILL signal to the process
      kill -SIGKILL $pid
    fi
  done <<< "$top_processes"
fi

# -------------------Get the current date for the log filename-----------------------------

current_date=$(date +%Y-%m-%d)

# -------------------Creates the log file with the current date in the filename-------------

log_filename="~/ProcessUsageReport-$current_date.log"

# -------------------Loop through each processes that was killed and log the details-----------

killed_processes=0
while read -r pid user cpu cmd; do
  if [[ $user != "root" ]]; then
    # Get the primary group of the user who started the process
    group=$(id -gn $user)
    # Get the current date and time
    current_time=$(date +"%Y-%m-%d %H:%M:%S")
    # Log the details to the file
    echo "$user started process $cmd on $current_time and it was killed on $(date +"%Y-%m-%d %H:%M:%S") in department $group" >> $log_filename
    # Increment the number of killed processes
    ((killed_processes++))
  fi
done <<< "$top_processes"

# ----------------------Show the user how many processes were killed----------------------------

echo "$killed_processes processes were killed."

exit 0
