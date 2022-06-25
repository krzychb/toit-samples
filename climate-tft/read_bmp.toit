/*
Show Climate Measurements with ESP-WROVER-KIT
https://github.com/krzychb/toit-samples/tree/main/climate-tft
SPDX-License-Identifier: CC0-1.0

This program is to read measurements of BMP280 sensor
and show the measurements on a terminal
*/

import gpio
import i2c
import bme280

/*
Allocation of GPIO Pins used in this project
*/

// BMP280 I2C bus GPIO pins
BMP280_SCL_GPIO := gpio.Pin 13
BMP280_SDA_GPIO := gpio.Pin 14

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
Read measurements from BMP280 sensor and show on a terminal
*/
main:

  bmp := get_bmp

  while true:
    print "Temperature: $(%.1f bmp.read_temperature)°C"
    print "Relative humidity: $(%d bmp.read_humidity)%"
    print "Barometric pressure: $(%d bmp.read_pressure/100) hPa"
    print // empty new line
    sleep --ms=1000
