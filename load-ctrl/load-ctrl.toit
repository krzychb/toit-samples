/*
Sample program to control temperature and show parammeters on TFT screen of ESP-WROVER-KIT
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
import monitor show Mutex
import gpio
import spi
import i2c
import bme280
import pid

get_display -> TrueColorPixelDisplay:

  hz            := 26 * 1_000_000
  width         := 320
  height        := 240
  x_offset      := 0
  y_offset      := 0
  mosi          := gpio.Pin 23
  clock         := gpio.Pin 19
  cs            := gpio.Pin 22
  dc            := gpio.Pin 21
  reset         := gpio.Pin 18
  backlight     := null  // inverted signal not implemented in the driver
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

display_mutex := Mutex
display := get_display

/* Temperature control parameters
*/
temperature := 0.0
temperature_sp := 34.5
pid_output := 0.0  // 0.0 .. 1.0
control_loop_time ::= 200  // ms

/* Allocation of GPIO pins other that for LCD screen
Note: backlight is handled separately because it is not properly supported by the driver
*/
BACLIGHT_GPIO  ::= 5   // LCD backlight GPIO
HEATER_GPIO    ::= 26  // Heater output
I2C_SDA_GPIO   ::= 27  // BMP280 I2C SDA
I2C_SCL_GPIO   ::= 14  // BMP280 I2C SCL


main:
  set_tz_ "CST-8"  // https://stackoverflow.com/questions/67246706/time-zones-in-toit
  display.background = BLACK
  backlight_off := gpio.Pin BACLIGHT_GPIO --output
  backlight_off.set 0

  sans := Font [
    sans_24.ASCII,  // Regular characters.
    sans_24.LATIN_1_SUPPLEMENT,  // Degree symbol.
  ]
  sans_context     := display.context --landscape --color=WHITE --font=sans --alignment=TEXT_TEXTURE_ALIGN_RIGHT
  temp_context     := display.text sans_context 230  50 "?.?°C"
  temp_sp_context  := display.text sans_context 230 100 "?.?°C"
  pid_out_context  := display.text sans_context 220 150 "?%"

  ft_context       := display.text sans_context 140 220 "? ms"
  time_context     := display.text sans_context 310 220 "?:??:??"

  context := display.context --landscape --color=(get_rgb 0xe0 0xe0 0xff) 
  icon_temp    := display.icon context  50  55 icons.THERMOMETER
  icon_temp_sp := display.icon context  50 105 icons.TARGET_VARIANT
  icon_heater  := display.icon context  50 155 icons.RADIATOR_DISABLED
  display.draw

  bus := i2c.Bus
    --sda=gpio.Pin I2C_SDA_GPIO
    --scl=gpio.Pin I2C_SCL_GPIO

  device := bus.device bme280.I2C_ADDRESS
  driver := bme280.Driver device

  task:: update_time time_context
  task:: update_temp driver temp_context temp_sp_context
  task:: update_ft ft_context
  task:: heater_control icon_heater pid_out_context
  task:: heater_pwm HEATER_GPIO


/* Update current time on TFT dscreen
*/
update_time time_context:
  while true:
    display_mutex.do:
      now := (Time.now).local
      time_context.text = "$now.h:$(%02d now.m):$(%02d now.s)"
      display.draw
    sleep --ms=1000


/* Update temperature on TFT dscreen
*/
update_temp driver temp_context temp_sp_context:
  while true:
    display_mutex.do:
      temperature = driver.read_temperature
      temp_context.text    = "$(%.1f temperature)°C"
      temp_sp_context.text = "$(%.1f temperature_sp)°C"
      display.draw
    sleep --ms=500


/* Update frame time on TFT screen
*/
update_ft ft_context:
  last := Time.monotonic_us
  diff_max := 0
  diff_count := 0
  while true:
    display_mutex.do:
      next := Time.monotonic_us
      diff := (next - last) / 1000
      last = next
      if diff > diff_max:
        diff_max = diff
      diff_count++
      if diff_count > 200:
        ft_context.text = "$(%3s diff) ms"
        display.draw
        diff_count = 0
        diff_max = 0
    sleep --ms=1


/* Temperature control loop
that perfroms calculation of the heater optupt
to reduce the temmparature error
*/
heater_control icon_heater pid_out_context:
  
  pid := pid.Controller --kp=0.1 --ki=0.0001
  last := Time.now

  while true:
    display_mutex.do:
      pid_output = pid.update temperature_sp - temperature last.to_now
      last = Time.now
      if pid_output > 0:
        icon_heater.icon = icons.RADIATOR
      else:
        icon_heater.icon = icons.RADIATOR_OFF
      pid_out_context.text = "$(%d pid_output * 100)%"
      display.draw
    sleep --ms=control_loop_time


/* Heater control loop that outputs PWM signal
proportional to the pid output
calculated in the temperature control loop
*/
heater_pwm heater_gpio:
  heater_om := gpio.Pin heater_gpio --output

  while true:
    heater_on_time := (pid_output * control_loop_time).to_int
    heater_om.set 1
    sleep --ms=heater_on_time
    heater_om.set 0
    sleep --ms=control_loop_time - heater_on_time
