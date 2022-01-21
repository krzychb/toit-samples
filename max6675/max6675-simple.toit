import gpio
import spi
import binary

cs ::=  gpio.Pin.out 12  // Chip select
so ::=  gpio.Pin.out 13  // Serial output
sck ::= gpio.Pin.out 14  // Serial clock

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

  while true:
    data := device.read 2  // MAX6675 provides two bytes to read
    data = binary.BIG_ENDIAN.int16 data 0  // input bytes are swapped
    if (data & 0b0000_0000_0000_0100) == 0b0000_0000_0000_0100:
      print "Thermocouple open!"
    else:  
      data = data >> 3  // temperature is in bits 3..14
      print "Value: $(%0.2f data * 0.25)"
    sleep --ms=1000

