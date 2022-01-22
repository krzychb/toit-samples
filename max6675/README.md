# Read temperature from MAX6675, a Cold-Junction-Compensated K-Thermocouple-to-Digital Converter

This folder contains some examples to show how to read temperature from MAX6675 converter, and provides the Toit class to read it.

- [max6675-simple](max6675-simple.toit) - A simple example to provide the basis of reading MAX6675 converter.
- [max6675--bit-bang](max6675-bit-bang.toit) - An example of reading MAX6675 converter using bit-banging of ESP32 GPIO pins.
- [max6675-class](max6675-class.toit) - The Toit class to reading the converter.


## Timing diagrams reading the MAX6675

Reading MAX6675 Using bit-banging of GPIO pins of ESP32

![alt text](_more/max6675-reading-bit-bang.png "Reading MAX6675 Using bit-banging of GPIO pins of ESP32")

Reading MAX6675 using SPI interface of ESP32

![alt text](_more/max6675-reading-class.png "Reading MAX6675 using SPI interface of ESP32")


## Related documents

- [MAX6675 datasheet](https://datasheets.maximintegrated.com/en/ds/MAX6675.pdf)