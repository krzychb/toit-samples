# Show Climate Measurements with ESP-WROVER-KIT

This repository contains a simple Toit application that shows temperature, relative humidity and barometric pressure on TFT display of ESP-WROVER-KIT.


## Required Hardware

To run the application the following hardware is required.

- [ESP-WROVER-KIT](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/hw-reference/esp32/get-started-wrover-kit.html)
- [BMP280 pressure sensor](https://www.bosch-sensortec.com/products/environmental-sensors/pressure-sensors/bmp280/) on a breakboard
- PIR motion sensor
- Some wires to make connections
- Optionally a protoboard and sockets to provide more permanent connection between ESP-WROVER-KIT as well as BMP280 and PIR.


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
| GPIO34      | OUT        | Motion Detected                       |


## Installation of Libraries

There are couple of libraries required to compile and run this application. Open terminal, go to the folder where the application is placed and run the following commands:

```
toit pkg install github.com/toitware/bme280-driver
toit pkg install github.com/toitware/toit-color-tft
toit pkg install github.com/toitware/toit-pixel-display
toit pkg install github.com/toitware/toit-icons-pictogrammers
```

To update previously installed libraries with a newer version run:
```
toit pkg update
```


## How to Use Toit

Check the readme file in the [root folder](../README.md) for information on how to configure and use Toit.


## Step by Step Guide

The following guide presents the process to test individual components of the application and then running the complete application. 

If not done already, please install Toit and check if it works following  [Quick start guide](https://docs.toit.io/getstarted).

Then install Jaguar and check if it works following [instructions](https://github.com/toitlang/jaguar) on GitHub. This guide is using Jaguar for the application development. The reason is that _climate-tft_ application does not need to use cloud infrastructure of Toit and local development directly on your PC is faster.


### Set up Project

Start of by creating a new empty folder e.g., `climate-tft` and then opening this folder in VS Code. 

In the folder we are going to create some test files and check if they work with the hardware. 

You can create a new file by right clicking in VS Code EXPLORER pane on the left, selecting 'New File' from the context menu and entering the file name. Then you can just copy and paste to this file the code taken from https://github.com/krzychb/toit-samples/tree/main/climate-tft.


### Flash Jaguar

Before loading any test code you need to flash Jaguar application to your ESP-WROVER-KIT. Open a terminal window by clicking `Terminal` > `New Terminal` from the VS Code menu. In the terminal window enter:

```
jag flash --wifi-ssid [ssid-of-your-wifi] --wifi-password [password-to-your-wifi] --name climate-tft-name
```

Replace `[ssid-of-your-wifi]` and `[password-to-your-wifi]` with SSID and password to access point of your wifi. Instead of `climate-tft-name` put a specific name of your choice. You can skip `--name climate-tft-name` if there no other Toit devices running on your network. 

You will be asked to select a port name to your board. ESP-WROVER-KIT will be visible under two ports. Select the port with the higher number. The log of successful flashing will look similar to below:

```
PS C:\Users\krzys\toit\climate-tft> jag flash --wifi-ssid my-ssid --wifi-password my-password  --name climate-tft-krzysztof
v COM8
Flashing device over serial on port 'COM8' ...
esptool.py v3.0
Serial port COM8
Connecting....
Chip is ESP32-D0WD (revision 1)
Features: WiFi, BT, Dual Core, 240MHz, VRef calibration in efuse, Coding Scheme None
Crystal is 40MHz
MAC: ac:67:b2:71:61:18
Uploading stub...
Running stub...
Stub running...
Changing baud rate to 921600
Changed.
Configuring flash size...
Auto-detected Flash size: 4MB
Compressed 15840 bytes to 11108...
Wrote 15840 bytes (11108 compressed) at 0x00001000 in 0.1 seconds (effective 1002.8 kbit/s)...
Hash of data verified.
Compressed 3072 bytes to 147...
Wrote 3072 bytes (147 compressed) at 0x00008000 in 0.0 seconds (effective 1535.6 kbit/s)...
Hash of data verified.
Compressed 8192 bytes to 31...
Wrote 8192 bytes (31 compressed) at 0x0000d000 in 0.0 seconds (effective 4523.9 kbit/s)...
Hash of data verified.
Compressed 1205216 bytes to 782390...
Wrote 1205216 bytes (782390 compressed) at 0x00010000 in 12.7 seconds (effective 757.6 kbit/s)...
Hash of data verified.

Leaving...
Hard resetting via RTS pin...
PS C:\Users\krzys\toit\climate-tft>
```

You can proceed to the next step only after successfully flashing Jaguar application.


### Monitor Jaguar

It is a good idea to have an access to log reported by Jaguar. In previously opened terminal window run:

```
jag monitor --port [port-to-monitor]
```

Instead of `[port-to-monitor]` enter the port name used previously to flash Jaguar. Log of successfully executed command will look like follows:

```
PS C:\Users\krzys\toit\climate-tft> jag monitor --port COM8
Starting serial monitor of port 'COM8' ...
ets Jun  8 2016 00:22:57

rst:0x1 (POWERON_RESET),boot:0x1e (SPI_FAST_FLASH_BOOT)
configsip: 0, SPIWP:0xee
clk_drv:0x00,q_drv:0x00,d_drv:0x00,cs0_drv:0x00,hd_drv:0x00,wp_drv:0x00
mode:DIO, clock div:2
load:0x3fff0030,len:188
ho 0 tail 12 room 4
load:0x40078000,len:12672
load:0x40080400,len:2892
entry 0x400805c0
[toit] Starting <v2.0.0-alpha.8>
[toit] clearing RTC memory: invalid checksum
[wifi] DEBUG: connecting
[wifi] DEBUG: connected
[wifi] INFO: dhcp assigned address {ip: 192.168.1.36}
[jaguar] INFO: running Jaguar device 'climate-tft-krzysztof' (id: '6f40f4bd-50c2-4994-9faf-90085c86f842') on 'http://192.168.1.36:9000'
```
Now you are ready to start testing the application code.


### Test PIR Sensor

In this step we are going to check if PIR sensor is operational. If motion is detected then backlight of TFT screen of ESP-WROVER-KIT will turn on for one second. If there is no motion the screen will be off.

Connect PIR sensor to [Main I/O Connector / JP1](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/hw-reference/esp32/get-started-wrover-kit.html#main-i-o-connector-jp1) of ESP-WROVER-KIT:

| ESP32 GPIO  | BMP280 Pin | Description of PIR Pin Functionality  | Wire Color  |
|-------------|------------|---------------------------------------|--------------
| 3.3V        | +          | Power Supply                          |  Red        |
| GND         | -          | Ground                                |  Blue       |
| GPIO34      | OUT        | Motion Detected                       |  White      |

Backlight GPIO is already [connected](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/hw-reference/esp32/get-started-wrover-kit.html#lcd-u5) internally on ESP-WROVER-KIT and you do not need to do anything about it.

Before running the test application, you can check this internal connection by shortening GPIO5 to GND. The TFT should turn on if GPIO5 is at low level and turn off if it is a high level or not connected.

After connecting the hardware you are ready to test the software. Create a new file [detect_motion.toit](detect_motion.toit) and load it to ESP-WORVER-KIT. 

To do so open a new terminal window by clicking `Terminal` > `New Terminal` from the VS Code menu. In the terminal enter:

```
jag watch detect_motion.toit --device climate-tft-krzysztof
```

The part `--device climate-tft-krzysztof` is required to load the application to one specific device if there are more than one on your network. A successful log after executing above command will look similar to below:

```
PS C:\Users\krzys\toit\climate-tft> jag watch detect_motion.toit --device climate-tft-krzysztof       
Scanning ...
Running 'detect_motion.toit' on 'climate-tft-krzysztof' ...
Success: Sent 24KB code to 'climate-tft-krzysztof'
```

Now check if the motion sensor is working. If you wave your hand in front to the PIR the TFT screen should turn on. The code to read the sensor and control the TFT is quite simple.

First, backlight GPIO is configured as output and PIR GPIO is configured as input. 


``` python
main:
  backlight_off := BACKLIGHT_GPIO
  backlight_off.config --output
  pir_state := PIR_GPIO
  pir_state.config --input
```

Then the PIR state is checked in an endless loop. If Motion is detected the backlight is turned on for one second.

``` python
  while true:
    if pir_state.get == 1:         // if motion is detected ...
      backlight_off.set 0          // turn the backlight on
      sleep --ms=DISPLAY_ON_DELAY  // keep the backlight on for some time
    else:
      backlight_off.set 1          // turn the backlight off
      sleep --ms=100
```

If the application is working properly, you can experiment by changing the value of `DISPLAY_ON_DELAY` to e.g., `5_000` and checking if TFT screen will turn on for at least five seconds.

``` python
/*
For how long keep the display on if motion is detected
*/
DISPLAY_ON_DELAY ::= 01_000  // ms
```

Save the modification to `detect_motion.toit` and since it is "watched" (remember running `jag watch detect_motion.toit`), it should be automatically loaded to ESP-WROVER-KIT:

```
File modified 'C:\Users\krzys\toit\climate-tft\detect_motion.toit'
Running 'detect_motion.toit' on 'climate-tft-krzysztof' ...
Success: Sent 24KB code to 'climate-tft-krzysztof'
```

If you see any issue check the other terminal window where you run Jaguar monitoring. Each terminal is accessible by clicking one of "jag" lines at the bottom right of VS Code. To distinguish which terminal is witch it is a good idea to rename "jag" to something else. Right click on "jag" and rename the windows to "monitor" and "watch":

![alt text](_more/monitor-and-watch-terminal.png "Distinguish 'monitor' and 'watch' terminal windows")

