/*
Example of reading temperature from MAX6675 using SPI interface of ESP32 implemented as Toit class.

Maxim Integrated MAX6675 is a Cold-Junction-Compensated K-Thermocouple-to-Digital Converter
able to read temperatures in range from 0°C to +1024°C.
MAX6675 dataseet: https://datasheets.maximintegrated.com/en/ds/MAX6675.pdf
*/
import gpio
import spi
import binary
import serial

//     ESP32 GPIO #  // MAX6675 Function (Pin)
cs ::=  gpio.Pin 12  // Chip select      (CS)
so ::=  gpio.Pin 13  // Serial output    (SO)
sck ::= gpio.Pin 14  // Serial clock     (SCK)

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
    print "Temperature: $(%0.1f max6675.read.temperature)°C"
    sleep --ms=500


class Measurement:
  temperature/float
  sensor_health/bool  // false if thermocouple is open

  constructor .temperature .sensor_health:

/**
Driver for the Maxim Integrated MAX6675 
Cold-Junction-Compensated K-Thermocouple-to-Digital Converter.
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
  read -> Measurement:
    sensor_health/bool := ?

    data := device_.read 2  // MAX6675 provides two bytes to read
    value := binary.BIG_ENDIAN.int16 data 0  // input bytes are swapped
    // Bit D2 is normally low and goes high when the thermocouple input is open. 
    if (value & THERMOCOUPLE_OPEN_BIT) == THERMOCOUPLE_OPEN_BIT:
      print "Thermocouple open!"
      sensor_health = false
    else:
      sensor_health = true
    /* 
    The first bit, D15, is a dummy sign bit and is always zero. 
    Bits D14–D3 contain the converted temperature in the order of MSB to LSB.
    */
    value = value >> 3  // remove not relevant bits
    temperature := value * 0.25
    return Measurement temperature sensor_health
