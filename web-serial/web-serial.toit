/*
Sample program to demonstrate interaction by ESP32
with a browser running web serial.

SPDX-License-Identifier: CC0-1.0
*/

import gpio
import uart

/* GPIO pins for serial port to read data from the browser.
 - RX pin should be connected to RX0 (GPIO3) of UART0 of ESP32.
 - TX pin is not used in this program but should be configured to some free GPIO.
*/
SERIAL_RX_GPIO ::= gpio.Pin 4
SERIAL_TX_GPIO ::= gpio.Pin 2


main:
  task:: serial_write
  task:: serial_read


/* Sample task to write data to the browser.
*/
serial_write:
  counter := 0
  while true:
    print "[Sent by ESP32] $(%d counter++)"
    sleep --ms=1000


/* Sample task to read data from the browser.
*/
serial_read:
  serial_port := uart.Port
    --rx=SERIAL_RX_GPIO
    --tx=SERIAL_TX_GPIO
    --baud_rate=115200
    --data_bits=8
    --parity=uart.Port.PARITY_DISABLED
    --stop_bits=uart.Port.STOP_BITS_1

  rs/string := ?
  while true:
    rs = serial_port.read.to_string
    print "[Received by ESP32] $(%s rs)"
    sleep --ms=100
