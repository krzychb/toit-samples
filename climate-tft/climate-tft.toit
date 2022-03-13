/*
Sample program to show climate measurements on TFT screen of ESP-WROVER-KIT
SPDX-License-Identifier: CC0-1.0
*/

import core.time_impl show set_tz_
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

// Default ESP-WROVER-KIT pins for driving TFT screen 
MOSI_GPIO       := gpio.Pin 23
CLOCK_GPIO      := gpio.Pin 19
CS_GPIO         := gpio.Pin 22
DC_GPIO         := gpio.Pin 21
RESET_GPIO      := gpio.Pin 18
BACLIGHT_GPIO   := gpio.Pin 5

// GPIO used for read motion detection signal from a PIR sensor
PIR_GPIO        := gpio.Pin 15  

// BME280 I2C bus GPIO pins
BME280_SCL_GPIO := gpio.Pin 13
BME280_SDA_GPIO := gpio.Pin 14

/*
For how long keep the display on if motion is detected
*/
DISPLAY_ON_DELAY ::= 60_000  // ms

/*
Configuration of driver for TFT screen on board of ESP-WROVER-KIT
*/
get_display -> TrueColorPixelDisplay:
  hz            := 26_000_000
  width         := 320  // pixels
  height        := 240  // pixels
  x_offset      := 0    // pixels
  y_offset      := 0    // pixels
  mosi          := MOSI_GPIO
  clock         := CLOCK_GPIO
  cs            := CS_GPIO
  dc            := DC_GPIO
  reset         := RESET_GPIO
  backlight     := null  // driver is unable to handle inverted backlight signal
  invert_colors := false
  flags         := COLOR_TFT_16_BIT_MODE | COLOR_TFT_FLIP_XY

  bus := spi.Bus
    --mosi=mosi
    --clock=clock

  device := bus.device
    --cs=cs
    --dc=dc
    --frequency=hz

  driver := ColorTft device width height
    --reset=reset
    --backlight=backlight
    --x_offset=x_offset
    --y_offset=y_offset
    --flags=flags
    --invert_colors=invert_colors

  tft := TrueColorPixelDisplay driver

  return tft


main:
  set_tz_ "CST-8"
  tft := get_display

  task:: update_display tft
  task:: detect_motion


/*
Configure display and keep it updated
with live parameters read from BME280 sensor
*/
update_display tft:

  tft.background = BLACK
  sans := Font [
    sans_24.ASCII,  // Regular characters
    sans_24.LATIN_1_SUPPLEMENT,  // Degree symbol
  ]
  sans_context := tft.context --landscape --color=WHITE --font=sans --alignment=TEXT_TEXTURE_ALIGN_RIGHT
  temp_context := tft.text sans_context 230 50 "?.?°C"
  hum_context  := tft.text sans_context 220 100 "?%"
  prs_context  := tft.text sans_context 255 150 "? hPa"
  time_context := tft.text sans_context 240 220 "?:??:??"

  context := tft.context --landscape --color=(get_rgb 0xe0 0xe0 0xff) 
  icon_temperature := tft.icon context 50 55 icons.THERMOMETER
  icon_humidity := tft.icon context 50 105 icons.WATER_OUTLINE
  icon_pressure := tft.icon context 50 155 icons.ARROW_COLLAPSE_DOWN
  icon_clock := tft.icon context 50 225 icons.CLOCK_OUTLINE
  tft.draw

  bus := i2c.Bus
    --sda=BME280_SDA_GPIO
    --scl=BME280_SCL_GPIO

  device := bus.device bme280.I2C_ADDRESS
  bme280 := bme280.Driver device

  while true:
    temp_context.text = "$(%.1f bme280.read_temperature)°C"
    hum_context.text = "$(%d bme280.read_humidity)%"
    prs_context.text = "$(%d bme280.read_pressure/100) hPa"
    now := (Time.now).local
    time_context.text = "$now.h:$(%02d now.m):$(%02d now.s)"
    tft.draw
    sleep --ms=1000


/*
Check for motion and turn the display on if motion is detected
*/
detect_motion:

  backlight_off := BACLIGHT_GPIO
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
