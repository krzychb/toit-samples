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
import pixel_display.histogram show TrueColorHistogram
import pixel_display.texture show *
import pixel_display.true_color show *
import monitor show Mutex
import gpio
import spi
import i2c
import bme280

get_display -> TrueColorPixelDisplay:
                                                // MHz x    y    xoff yoff sda clock cs  dc  reset backlight invert
  WROVER_16_BIT_LANDSCAPE_SETTINGS          ::= [  26, 320, 240, 0,   0,   23, 19,   22, 21, 18,   null,     false, COLOR_TFT_16_BIT_MODE | COLOR_TFT_FLIP_XY ]
  s := WROVER_16_BIT_LANDSCAPE_SETTINGS

  hz            := 1_000_000 * s[0]
  width         := s[1]
  height        := s[2]
  x_offset      := s[3]
  y_offset      := s[4]
  mosi          := gpio.Pin s[5]
  clock         := gpio.Pin s[6]
  cs            := gpio.Pin s[7]
  dc            := gpio.Pin s[8]
  reset         := s[9] == null ? null : gpio.Pin s[9]
  backlight     := s[10] == null ? null : gpio.Pin s[10]
  invert_colors := s[11]
  flags         := s[12]

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

display_mutex := Mutex

/* Information that motion has been detected
and the LEDs should be on.
*/
motion_detected := false
TIMER_ON_DELAY ::= 60_000  // ms
PIR_GPIO ::= 15  // GPIO used for mmotion detection with a PIR sennsor
BACLIGHT_GPIO ::= 5  // LCD backlight GPIO

main:
  set_tz_ "CST-8"
  tft := get_display

  tft.background = BLACK

  sans := Font [
    sans_24.ASCII,  // Regular characters.
    sans_24.LATIN_1_SUPPLEMENT,  // Degree symbol.
  ]
  sans_context := tft.context --landscape --color=WHITE --font=sans --alignment=TEXT_TEXTURE_ALIGN_RIGHT
  temp_context := tft.text sans_context 230 50 "?.?°C"
  hum_context  := tft.text sans_context 220 100 "?%"
  prs_context  := tft.text sans_context 255 150 "? hPa"
  ft_context   := tft.text sans_context 140 220 "? ms"
  time_context := tft.text sans_context 310 220 "?:??:??"

  context := tft.context --landscape --color=(get_rgb 0xe0 0xe0 0xff) 
  icon_temperature := tft.icon context 50 55 icons.THERMOMETER
  icon_humidity := tft.icon context 50 105 icons.WATER_OUTLINE
  icon_pressure := tft.icon context 50 155 icons.ARROW_COLLAPSE_DOWN
  tft.draw

  bus := i2c.Bus
    --sda=gpio.Pin 27
    --scl=gpio.Pin 14

  device := bus.device bme280.I2C_ADDRESS
  driver := bme280.Driver device

  task:: update_time time_context tft
  task:: update_temp driver temp_context hum_context prs_context tft
  task:: update_ft ft_context tft
  task:: check_pir PIR_GPIO BACLIGHT_GPIO

update_time time_context tft:
  while true:
    display_mutex.do:
      now := (Time.now).local
      time_context.text = "$now.h:$(%02d now.m):$(%02d now.s)"
      tft.draw
    sleep --ms=1000

update_temp driver temp_context hum_context prs_context tft:
  while true:
    display_mutex.do:
      temp_context.text = "$(%.1f driver.read_temperature)°C"
      hum_context.text = "$(%d driver.read_humidity)%"
      prs_context.text = "$(%d driver.read_pressure/100) hPa"
      tft.draw
    sleep --ms=500

update_ft ft_context tft:
  last := Time.monotonic_us
  while true:
    display_mutex.do:
      next := Time.monotonic_us
      diff := (next - last) / 1000
      ft_context.text = "$(%3s diff) ms"
      last = next

    sleep --ms=1

check_pir pir_gpio baclight_gpio:

  backlight_off := gpio.Pin baclight_gpio --output
  pir_state := gpio.Pin pir_gpio --input
  while true:
    if pir_state.get == 1:
      backlight_off.set 0
      motion_detected = true
      sleep --ms=TIMER_ON_DELAY
    else:
      backlight_off.set 1
      motion_detected = false
      sleep --ms=100