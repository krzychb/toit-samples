/*
Show Climate Measurements with ESP-WROVER-KIT
https://github.com/krzychb/toit-samples/tree/main/climate-tft
SPDX-License-Identifier: CC0-1.0

This program is to adjust real time of ESP to NTP server
and show the current time on a terminal
*/

import ntp
import esp32 show adjust_real_time_clock

main:
  set_timezone "CST-8"
  task:: sync_time

  while true:
    time := Time.now.local
    print "$time.h:$(%02d time.m):$(%02d time.s)"
    sleep --ms=1000 

/*
Periodically synchronize real time clock of ESP to NTP server
*/
sync_time:

  while true:
    now := Time.now
    result ::= ntp.synchronize
    if result:
      adjust_real_time_clock result.adjustment
      print "Set time to $Time.now by adjusting $result.adjustment"
    else:
      print "ntp: synchronization request failed"
    /*
    Synchronize time every 10 seconds to quickly see if this procedure is working.
    In practice, synchronization once per couple of hours would be enough.
    */
    sleep --ms=10000
