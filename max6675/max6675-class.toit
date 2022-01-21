import gpio
import spi
import binary
import serial

cs ::=  gpio.Pin.out 12  // Chip select (CS)
so ::=  gpio.Pin.out 13  // Serial output (SO)
sck ::= gpio.Pin.out 14  // Serial clock (SCK)

// According to MAX6675 datasheet the maximum clock frequency is 4.3 MHz
MAX6675_SCK_FREQUECY ::= 4_000_000

main:
  cs_gpio := cs
  so_gpio := so
  sck_gpio := sck

  bus := spi.Bus
    --miso=so_gpio
    --clock=sck_gpio

  device := bus.device
    --cs=cs_gpio
    --frequency=MAX6675_SCK_FREQUECY

  max6675 := Max6675 device

  while true:
    print "Temperature: $(%0.2f max6675.read.temperature)"
    sleep --ms=1000


class Measuremment:
  temperature/float
  sensor_health/bool  // thermocouple is not open

  constructor .temperature .sensor_health:

/**
Driver for the Maxim Integrated MAX6675 
Cold-Junction-Compensated K-Thermocoupleto-Digital Converter.
(0°C to +1024°C)
https://datasheets.maximintegrated.com/en/ds/MAX6675.pdf
*/
class Max6675:
  static THERMOCOUPLE_OPEN_BIT ::= 0b0000_0000_0000_0100
  device_/serial.Device ::= ?

  constructor device/serial.Device:
    device_ = device

  /** 
  Read temperature in degrees of Celsius (°C)
  */
  read -> Measuremment:
    sensor_health/bool := ?
    /* 
    Description from the datasheet of the contents of the two bytes read from MAX6675

    The first bit, D15, is a dummy sign bit and is always zero. 
    Bits D14–D3 contain the converted temperature in the order of MSB to LSB. 
    Bit D2 is normally low and goes high when the thermocouple input is open. 
    D1 is low to provide a device ID for the MAX6675 and bit D0 is three-state.
    */
    data := device_.read 2  // MAX6675 provides two bytes to read
    value := binary.BIG_ENDIAN.int16 data 0  // input bytes are swapped
    if (value & THERMOCOUPLE_OPEN_BIT) == THERMOCOUPLE_OPEN_BIT:
      print "Thermocouple open!"
      sensor_health = false
    else:
      sensor_health = true
    value = value >> 3  // temperature is in bits 3..14
    temperature := value * 0.25
    return Measuremment temperature sensor_health
