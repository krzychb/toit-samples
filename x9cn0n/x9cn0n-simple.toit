/*
A simple example for managing digital potentiometers X9Cn0n (n0n = 102, 103, 104, 503).
Inspired by Arduino library DigiPotX9Cxxx.cpp by Timo Fager, Jul 29, 2011.

Note:
This example is based on X9C104 digipot but should work for any other above listed digipots
*/

import gpio

/* The X9C104S digipot I have seems to be able to move by only 30 steps.
Change MAX_STEPS to 100 if you have an original digipot.
*/
MAX_STEPS ::= 30

/* Connect X9C104 digipot to ESP32 board as follows:
- ESP32 GPIO -- X9C104 pin -- Desription
- ======================================
- GPIO2 -- CS  -- Chip select
- GPIO0 -- UD  -- Direction of counting: up and down
- GPIO4 -- INC -- Pulse input to increment the wiper position 
*/

/* Configure ESP32 output pins to drive the digipot
*/
cs_gpio := gpio.Pin.out 2
ud_gpio := gpio.Pin.out 0
inc_gpio := gpio.Pin.out 4

main:
  /* Set some initial values of the output pins
  */
  inc_gpio.set 0  // Prevent from saving the current wiper position on cs toggle down.
  cs_gpio.set 1   // Disable the digipot's control interface.

  /* Change the wiper position down to the mminimum.
  If you attach an Ohm meter to VL and VW pins of the digipot
  the Ohm meter should read about 0 Ohm.
  */
  change 0 MAX_STEPS 
  sleep --ms=5000  // Some delay to read the Ohm meter

  /* Change the wiper position up to the middle position.
  For X9C104 digipot the Ohm meter should read about 50 kOhm
  */
  change 1 MAX_STEPS/2
  sleep --ms=5000

  // Do not exit the application, stay in endless loop.
  while true:
    sleep --ms=1000

/** Change the wiper position 
  by mowing it in specified direction
  - 0: down
  - 1: up
  and by specified number of steps.
Note:
This function is also storing the set wiper position
  in non-volatile retention memory of the digipot
*/
change direction steps:
  ud_gpio.set direction
  inc_gpio.set 1 // the INC should be high before enabling the digipot
  sleep --ms=1
  cs_gpio.set 0  // enable the digipot
  sleep --ms=1
  steps.repeat:
    inc_gpio.set 0  // resistance increment happens on a failing edge
    sleep --ms=1
    inc_gpio.set 1 
    sleep --ms=1
  cs_gpio.set 1   // disable the digipot
  sleep --ms=20   // let the digipot store the last wiper position
  if direction == 1:
    print "Moved up by $(%d steps)"
  else:
    print "Moved down by $(%d steps)"
