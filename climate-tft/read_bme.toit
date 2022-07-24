/*
Show Climate Measurements with ESP-WROVER-KIT
https://github.com/krzychb/toit-samples/tree/main/climate-tft
SPDX-License-Identifier: CC0-1.0

This program is to read measurements of BME280 sensor
and show the measurements on a terminal
*/

import gpio
import i2c
import bme280

/*
Allocation of GPIO Pins used in this project
*/

// BME280 I2C bus GPIO pins
BME280_SCL_GPIO := gpio.Pin 13
BME280_SDA_GPIO := gpio.Pin 14

/*
Configuration of driver for BME280 sensor
*/
get_bme:

  bus := i2c.Bus
    --sda=BME280_SDA_GPIO
    --scl=BME280_SCL_GPIO

  device := bus.device bme280.I2C_ADDRESS
  bme := bme280.Driver device

  return bme


/*
Read measurements from BME280 sensor and show on a terminal
*/
main:

  bme := get_bme

  while true:
    print "Temperature: $(%.1f bme.read_temperature)°C"
    print "Relative humidity: $(%d bme.read_humidity)%"
    print "Barometric pressure: $(%d bme.read_pressure/100) hPa"
    print // empty new line
    sleep --ms=1000
