/*
Example of reading temperature from MAX6675 using SPI interface of ESP32.

Maxim Integrated MAX6675 is a Cold-Junction-Compensated K-Thermocouple-to-Digital Converter
able to read temperatures in range from 0°C to +1024°C.
MAX6675 dataseet: https://datasheets.maximintegrated.com/en/ds/MAX6675.pdf
*/
import gpio
import spi
import binary

//     ESP32 GPIO #  // MAX6675 Function (Pin)
cs ::=  gpio.Pin 12  // Chip select      (CS)
so ::=  gpio.Pin 13  // Serial output    (SO)
sck ::= gpio.Pin 14  // Serial clock     (SCK)

hz ::= 4_000_000  // According to MAX6675 datasheet the maximum clock frequency is 4.3 MHz

bus := spi.Bus
  --miso=so
  --clock=sck

device := bus.device
  --cs=cs
  --frequency=hz

main:

  /* 
  Description of the contents of the two bytes read from MAX6675 according to the datasheet

  The first bit, D15, is a dummy sign bit and is always zero. 
  Bits D14–D3 contain the converted temperature in the order of MSB to LSB. 
  Bit D2 is normally low and goes high when the thermocouple input is open. 
  D1 is low to provide a device ID for the MAX6675 and bit D0 is three-state.
  */

  /**
  Read temperature from MAX6675 using SPI interface of ESP32.
  */
  while true:
    data := device.read 2  // MAX6675 provides two bytes to read
    data = binary.BIG_ENDIAN.int16 data 0  // input bytes are swapped
    // Bit D2 is normally low and goes high when the thermocouple input is open. 
    if (data & 0b0000_0000_0000_0100) == 0b0000_0000_0000_0100:
      print "Thermocouple open!"
    else:
      /* 
      The first bit, D15, is a dummy sign bit and is always zero. 
      Bits D14–D3 contain the converted temperature in the order of MSB to LSB.
      */
      data = data >> 3  // remove not relevant bits
      print "Temperature: $(%0.1f data * 0.25)°C"
    sleep --ms=500

