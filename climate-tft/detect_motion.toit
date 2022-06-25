/*
Show Climate Measurements with ESP-WROVER-KIT
https://github.com/krzychb/toit-samples/tree/main/climate-tft
SPDX-License-Identifier: CC0-1.0

This program is to check if PIR is operational
*/

import gpio


/*
Allocation of GPIO Pins used in this project
*/

// GPIO used to tun backlight of ESP-WROVER-KIT display on/off
BACKLIGHT_GPIO   := gpio.Pin 5

// GPIO used for read motion detection signal from a PIR sensor
PIR_GPIO        := gpio.Pin 34 

/*
For how long keep the display on if motion is detected
*/
DISPLAY_ON_DELAY ::= 01_000  // ms


/*
Check for motion and turn the display on if motion is detected
*/
main:
  backlight_off := BACKLIGHT_GPIO
  backlight_off.config --output
  pir_state := PIR_GPIO
  pir_state.config --input

  while true:
    if pir_state.get == 1:         // if motion is detected ...
      backlight_off.set 0          // turn the backlight on
      sleep --ms=DISPLAY_ON_DELAY  // keep the backlight on for some time
    else:
      backlight_off.set 1          // turn the backlight off
      sleep --ms=100
