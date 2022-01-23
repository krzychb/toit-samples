/*
Example of driving 74HC595 shift register using bit-banging of GPIOs of ESP32.

For background information see e.g: https://learn.adafruit.com/adafruit-arduino-lesson-4-eight-leds

Copyright (C) 2022 Krzysztof Budzynski. All rights reserved.
Use of this source code is governed by an Apache 2.0 license that can be found
in the LICENSE file of https://github.com/krzychb/toit-samples repository.
*/

import gpio

//           ESP32 GPIO #  // 74HC595 Function        (Pin)
data  ::= gpio.Pin.out 12  // Data serial input       (DS)
latch ::= gpio.Pin.out 13  // Storage register clock  (ST_CP)
clock ::= gpio.Pin.out 14  // Shift register clock    (SH_CP)

main:

  256.repeat:
    latch.set 0  
    sleep --ms=1
    shift_out it false
    latch.set 1  
    sleep --ms=1
    print "Out: $(%d it)"       
    sleep --ms=200

  while true:
    sleep --ms=1000


shift_out value lsb_first:
  bit := ?
  8.repeat:
    if lsb_first:  // LSB first
      bit = (value & 0b0000_0000_0000_0001) == 0b0000_0000_0000_0001 ? 1 : 0
      value = value >> 1
    else:  // MSB first
      bit = (value & 0b0000_0000_1000_0000) == 0b0000_0000_1000_0000 ? 1 : 0
      value = value << 1
    data.set bit  // set the data serial input
    clock.set 1   // shift in the value
    sleep --ms=1
    clock.set 0
    sleep --ms=1
