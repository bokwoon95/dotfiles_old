#!/bin/bash

fage () {
  # gets age of file in seconds
  [ "$#" -eq 0 ] && f=$(</dev/stdin) || f="$1"
  echo "$(( $(date +%s) - $(date -r $f +%s) ))"
}
fmtsec () {
  # converts seconds to format "%d.years %d.months %d.days %d.hours %d.minutes %d.seconds"
  [ "$#" -eq 0 ] && local T=$(</dev/stdin) || local T="$1"
  local Y=$((T/60/60/24/30/12))
  local m=$((T/60/60/24/30%12))
  local d=$((T/60/60/24%30))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  echo "$Y.years $m.months $d.days $H.hours $M.minutes $S.seconds"
}

#funtion arguments -> filename to comapre against curr time
function olderthan24h() {
  if [ $(fage $1) -lt $(echo '24*60*60' | bc) ]; then
    echo "younger than 24h"
  else
    echo "older than 24h"
  fi
  # if [ ! -f $1 ]; then
  #   echo "file $1 does not exist"
  #   exit 1
  # fi
  # MAXAGE=$(bc <<< '28*60*60') # seconds in 28 hours
  # # file age in seconds = current_time - file_modification_time.
  # FILEAGE=$(($(date +%s) - $(stat -c '%Y' "$1")))
  # test $FILEAGE -lt $MAXAGE && {
  #   echo "$1 is less than 28 hours old."
  #     return 0
  #   }
  # echo "$1 is older than 28 hours seconds."
  # return 1
}
