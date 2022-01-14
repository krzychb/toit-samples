/*
 * Example for managing digital potentiometers X9Cxxx (xxx = 102,103,104,503).
 * Inspired by Arduino library DigiPotX9Cxxx.cpp by Timo Fager, Jul 29, 2011.
 **/

import gpio

main:

  /** Connect X9C104 digipot to ESP32 board as follows:
  - X9C104 pin -- ESP32 GPIO 
  - ========================
  - cs -- GPIO4
  - ud -- GPIO0
  - inc -- GPIO 2
  */
  digipot := x9c10n 4 0 2

  // Set the digipot to some value.
  digipot.set 88
  print "Value: $(%0.1f digipot.get) kOhm"

  // Save the current wiper position.
  digipot.save

  // Do not exit the application, stay in endless loop.
  while true:
    sleep --ms=1000


class x9c10n:

  /** The X9C104S digipot I have seems to be able to move by only 30 steps.
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

  /** Note: do not rely on "position" as the relative value.
  Use reset before setting a new value.
  */
  position := -1

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
    cs_gpio.set 1   // disable the digipot
    reset  // reset position of the digipot

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

  /** Reset wiper position to the minimum.
  */
  reset:
    change 0 MAX_STEPS
    position = 0

  /** Save the current wiper position.
  */
  save:
    inc_gpio.set 1  // current wiper position will be saved when inc input is aserted level
    sleep --ms=1
    cs_gpio.set 0   // enable the digipot
    sleep --ms=1
    cs_gpio.set 1   // disable digipot to save the position
    inc_gpio.set 0  // prevent from saving the current wiper position on cs toggle down
    sleep --ms=20   // wait to let the digipot save the position

  /** Change the wiper position 
  by mowing it in specified direction 0: down, 1: up
  by specified number of steps.
  */
  change direction steps:
    ud_gpio.set direction
    cs_gpio.set 0  // enable the digipot
    sleep --ms=1
    steps.repeat:
      inc_gpio.set 1
      sleep --ms=1
      inc_gpio.set 0  // resistance increment happens on a failing edge
      sleep --ms=1
    cs_gpio.set 1   // disable digipot
    if direction == 1:
      position = position + steps
    else:
      position = position - steps
