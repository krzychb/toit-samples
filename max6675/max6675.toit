/*
Example of reading temperature from MAX6675 using bit-banging of GPIOs of ESP32.
The example is using a package with the driver for MAX6675.
*/

import gpio
import max6675

//          ESP32 GPIO #  // MAX6675 Function (Pin)
cs_gpio ::=  gpio.Pin 12  // Chip select      (CS)
so_gpio ::=  gpio.Pin 13  // Serial output    (SO)
sck_gpio ::= gpio.Pin 14  // Serial clock     (SCK)


main:
  device := max6675.DriverBitBang
    --cs=cs_gpio
    --so=so_gpio
    --sck=sck_gpio

  max6675 := max6675.Driver device

  while true:
    print "Temperature: $(%0.1f max6675.read.temperature)°C"
    sleep --ms=500
