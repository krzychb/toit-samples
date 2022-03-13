# Show Climate Measurements with ESP-WROVER-KIT

This repository contains a simple Toit application that shows temperature, relative humidity, barometric pressure and time on TFT display of ESP-WROVER-KIT.


## Required Hardware

To run the application the following hardware is required.

- [ESP-WROVER-KIT](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/hw-reference/esp32/get-started-wrover-kit.html)
- [BME280 pressure sensor](https://www.bosch-sensortec.com/products/environmental-sensors/pressure-sensors/bmp280/) on a breadboard
- PIR motion sensor
- Some wires to make connections


## Hardware Connections

The example code is configured for the connections described below.

### BMP280 Pressure Sensor

| ESP32 GPIO  | BMP280 Pin | Description of BMP280 Pin Functionality  |
|-------------|------------|------------------------------------------|
| 3.3V        | VCC        | Power Supply                             |
| GND         | GND        | Ground                                   |
| GPIO13      | SCL        | I2C Clock                                |
| GPIO14      | SDA        | I2C Data                                 |

### PIR Sensor

| ESP32 GPIO  | BMP280 Pin | Description of PIR Pin Functionality  |
|-------------|------------|---------------------------------------|
| 3.3V        | +          | Power Supply                          |
| GND         | -          | Ground                                |
| GPIO15      | OUT        | Motion Detected                       |


## Installation if Libraries

There are couple of libraries required to compile and run this application. Open terminal, go to the folder where the application is placed and run the following commands:

```
toit pkg install github.com/toitware/bme280-driver
toit pkg install github.com/toitware/toit-color-tft
toit pkg install github.com/toitware/toit-pixel-display
toit pkg install github.com/toitware/toit-icons-pictogrammers
```

## How to Use Toit

Check the readme file in the [root folder](../README.md) for information on how to configure and use Toit.
