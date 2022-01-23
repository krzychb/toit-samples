/*
Example of reading temperature from MAX6675 using bit-banging of GPIOs of ESP32.

Maxim Integrated MAX6675 is a Cold-Junction-Compensated K-Thermocouple-to-Digital Converter
able to read temperatures in range from 0°C to +1024°C.
MAX6675 dataseet: https://datasheets.maximintegrated.com/en/ds/MAX6675.pdf
*/
import gpio

//     ESP32 GPIO #  // MAX6675 Function   (Pin)
cs ::=  gpio.Pin.out 12  // Chip select    (CS)
so ::=  gpio.Pin.in  13  // Serial output  (SO)
sck ::= gpio.Pin.out 14  // Serial clock   (SCK)

main:
  while true:
    print "Temperature: $(%0.1f max6675_read)°C"       
    sleep --ms=1000

/**
Read temperature from MAX6675 using bit-baging of ESP32 GPIO pins.
*/
max6675_read:
  data := 0
  sck.set 0
  sleep --ms=1
  cs.set 0
  sleep --ms=1
  16.repeat:
    data = data << 1  // prepare the next cleared bit
    if so.get == 1:   // set the bit if read high
      data = data | 0b0000_0000_0000_0001
    sck.set 1 
    sleep --ms=1
    sck.set 0   // Data is changed in failing edge
    sleep --ms=1
  cs.set 1
  // Bit D2 is normally low and goes high when the thermocouple input is open. 
  if (data & 0b0000_0000_0000_0100) == 0b0000_0000_0000_0100:
    print "Thermocouple open!"
  /* 
  The first bit, D15, is a dummy sign bit and is always zero. 
  Bits D14–D3 contain the converted temperature in the order of MSB to LSB.
  */
  data = data >> 3  // remove not relevant bits
  return data * 0.25