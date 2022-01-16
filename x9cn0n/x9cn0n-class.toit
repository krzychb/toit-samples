/*
Example with a class for managing digital potentiometers X9Cn0n (n0n = 102, 103, 104, 503).
Inspired by Arduino library DigiPotX9Cxxx.cpp by Timo Fager, Jul 29, 2011.

Note:
This example is based on X9C104 digipot but should work for any other above listed digipots
*/

import gpio

main:
  /** Connect X9C104 digipot to ESP32 board as follows:
  - X9C104 pin -- ESP32 GPIO 
  - ========================
  - CS -- GPIO2
  - UD -- GPIO0
  - INC -- GPIO4
  */
  digipot := x9cn0n 2 0 4
  digipot.reset 0
  sleep --ms=5000

  // Set the digipot to some resistance values.
  [53, 55, 58, 61, 64, 68, 64, 61, 58, 55, 53].do:
    digipot.set it
    sleep --ms=5000

  // Do not exit the application, stay in endless loop.
  while true:
    sleep --ms=1000


class x9cn0n:

  /** The X9C10S digipot I have seems to be able to move by only 30 steps.
  Change MAX_STEPS to 100 if you have an original digipot.
  Change the resistance basing on the digipot variant, e.g.,
  - X9C102 -- 1 kOhm
  - X9C103 -- 10 kOhm
  - X9C503 -- 50 kOhm
  - X9C104 -- 100 kOhm
  */
  static MAX_STEPS ::= 30
  static RESISTANCE ::= 100.0
  static KOHM_FOR_STEP ::= RESISTANCE/MAX_STEPS

  cs_gpio := ?
  ud_gpio  := ?
  inc_gpio := ?

  /** Note:
  The application has not been fully tested to rely on "position" 
  that stores previously set value then used to set a new position relatively to it.
  The more reliable way is to use reset before setting a new value.
  */
  position := 0

  /** The digipot has three wire interface so three GPIOs are required
  - cs: chip select
  - ud: direction of counting -- up and down
  - inc: pulse input to increment the wiper position
  */
  constructor cs/int ud/int inc/int:
    cs_gpio = gpio.Pin.out cs
    ud_gpio = gpio.Pin.out ud
    inc_gpio = gpio.Pin.out inc
    inc_gpio.set 0  // prevent from saving the current wiper position on cs toggle down
    cs_gpio.set 1   // disable the digipot's control interface


  /** Set the digipot's resistance to specified value.
  */
  set value:
    target := (value / KOHM_FOR_STEP).to_int
    steps := target - position
    if steps == 0:
      return
    if steps > 0:
      change 1 steps
    else:
      change 0 -steps

  /** Get the digipot's resistance calculated basing on wiper position.
  */
  get:
    return position * KOHM_FOR_STEP

  /** Reset wiper position to the minimum or maximum (direction = 0 or 1).
  */
  reset direction:
    print "Running reset: $(%d direction)"
    if direction == 0:
      position = MAX_STEPS
      change 0 MAX_STEPS + 1
    else:
      position = 0
      change 1 MAX_STEPS

  /** Change the wiper position 
    by mowing it in specified direction 0: down, 1: up
    by specified number of steps.
  Note:
  This function is also storing the set wiper position
    in non-volatile retention memory of the digipot
  */
  change direction steps:
    ud_gpio.set direction
    inc_gpio.set 1
    sleep --ms=1
    cs_gpio.set 0  // enable the digipot
    sleep --ms=1
    steps.repeat:
      inc_gpio.set 0  // resistance increment happens on a failing edge
      sleep --ms=1
      inc_gpio.set 1 
      sleep --ms=1
    cs_gpio.set 1   // disable digipot
    sleep --ms=20   // let the digipot store the last wiper position
    if direction == 1:
      position = position + steps
    else:
      position = position - steps
    print "Position: $(%d position), resistance: $(%0.1f get) kOhm"
