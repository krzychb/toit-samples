/*
Sample program to show climate measurements on TFT screen of ESP-WROVER-KIT
https://github.com/krzychb/toit-samples/tree/main/climate-tft
SPDX-License-Identifier: CC0-1.0

If this program looks too complicated, check simpler programs
that demonstrate partial functionality that is used here:

- detect_motion.toit
- read_bmp.toit
- update_display.toit

*/

import bitmap show *
import color_tft show *
import font show *
import font.x11_100dpi.sans.sans_24 as sans_24
import pictogrammers_icons.size_48 as icons
import pixel_display show *
import pixel_display.texture show *
import pixel_display.true_color show *
import gpio
import spi
import i2c
import bme280

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

// BMP280 I2C bus GPIO pins
BMP280_SCL_GPIO := gpio.Pin 13
BMP280_SDA_GPIO := gpio.Pin 14

// GPIO used for read motion detection signal from a PIR sensor
PIR_GPIO        := gpio.Pin 34 

/*
For how long keep the display on if motion is detected
*/
DISPLAY_ON_DELAY ::= 60_000  // ms

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
Configuration of driver for BMP280 sensor
*/
get_bmp:

  bus := i2c.Bus
    --sda=BMP280_SDA_GPIO
    --scl=BMP280_SCL_GPIO

  device := bus.device bme280.I2C_ADDRESS
  bmp := bme280.Driver device

  return bmp


/*
Configure display and keep it updated
with live parameters read from BMP280 sensor
*/
update_display tft bmp:

  tft.background = BLACK
  sans := Font [
    sans_24.ASCII,  // Regular characters
    sans_24.LATIN_1_SUPPLEMENT,  // Degree symbol
  ]
  sans_context := tft.context --landscape --color=WHITE --font=sans --alignment=TEXT_TEXTURE_ALIGN_RIGHT
  temp_context := tft.text sans_context 230 50 "?.?°C"
  hum_context  := tft.text sans_context 220 100 "?%"
  prs_context  := tft.text sans_context 255 150 "? hPa"
  name_context  := tft.text sans_context 255 215 "Krzysztof"

  context := tft.context --landscape --color=(get_rgb 0xe0 0xe0 0xff) 
  icon_temperature := tft.icon context 50 55 icons.THERMOMETER
  icon_humidity := tft.icon context 50 105 icons.WATER_OUTLINE
  icon_pressure := tft.icon context 50 155 icons.ARROW_COLLAPSE_DOWN
  icon_name := tft.icon context 50 220 icons.FACE
  tft.draw

  while true:
    temp_context.text = "$(%.1f bmp.read_temperature)°C"
    hum_context.text = "$(%d bmp.read_humidity)%"
    prs_context.text = "$(%d bmp.read_pressure/100) hPa"
    tft.draw
    sleep --ms=1000


/*
Check for motion and turn the display on if motion is detected
*/
detect_motion:

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


main:
  tft := get_display
  bmp := get_bmp

  task:: update_display tft bmp
  task:: detect_motion
