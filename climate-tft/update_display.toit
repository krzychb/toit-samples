/*
Show Climate Measurements with ESP-WROVER-KIT
https://github.com/krzychb/toit-samples/tree/main/climate-tft
SPDX-License-Identifier: CC0-1.0

This program is to check if ESP-WROVER-KIT's display is operational
*/

import color_tft show *
import font show *
import pixel_display show *
import pixel_display.texture show *
import pixel_display.true_color show *
import spi
import gpio


/*
Allocation of GPIO Pins used in this project
*/

// Default ESP-WROVER-KIT pins for driving TFT display 
MOSI_GPIO       := gpio.Pin 23
CLOCK_GPIO      := gpio.Pin 19
CS_GPIO         := gpio.Pin 22
DC_GPIO         := gpio.Pin 21
RESET_GPIO      := gpio.Pin 18
BACKLIGHT_GPIO  := gpio.Pin 5

/*
Configuration of driver for TFT screen on board of ESP-WROVER-KIT
*/
get_display -> TrueColorPixelDisplay:

  bus := spi.Bus
    --mosi=MOSI_GPIO
    --clock=CLOCK_GPIO

  device := bus.device
    --cs=CS_GPIO
    --dc=DC_GPIO
    --frequency=26_000_000  // Hz

  driver := ColorTft device 320 240  // width x height (in pixels)
    --reset=RESET_GPIO
    --backlight=null  // backlight will be controlled separately
    --x_offset=0      // pixels
    --y_offset=0      // pixels
    --flags=COLOR_TFT_16_BIT_MODE | COLOR_TFT_FLIP_XY      
    --invert_colors=false

  tft := TrueColorPixelDisplay driver

  return tft


/*
Show text "Hello World" on ESP-WROVER-KIT's display
*/
main:

  backlight_off := BACKLIGHT_GPIO
  backlight_off.config --output
  backlight_off.set 0   // turn the backlight on

  tft := get_display
  tft.background = BLACK
  sans := Font.get "sans10"
  sans_context := tft.context --landscape --color=WHITE --font=sans
  hello_context := tft.text sans_context 130 120 "Hello World"
  tft.draw

  /*
  We need to stay in a loop 
  otherwise the program will terminate
  and the display will turn off
  */
  while true:
    sleep --ms=1000
