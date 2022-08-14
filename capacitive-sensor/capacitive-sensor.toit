import gpio
import gpio.adc show Adc
import bitmap show bytemap_zap
import pixel_strip show UartPixelStrip

PIXELS ::= 8  // Number of pixels on the strip.

/* Calibration of RGB LED strip display 
to show the full range of measurements 
on the output of the capacitive moisture sensor
*/
SH_SENSOR_L ::= 0.9 // lowest voltage by the sensor
SH_SENSOR_H ::= 2.3 // highest voltage by the sensor
SH_SENSOR_G ::= PIXELS / (SH_SENSOR_H - SH_SENSOR_L) // measurement gain

main:
  pixels := UartPixelStrip PIXELS
    --pin=10  // Output pin - this is the normal pin for UART 1

  r := ByteArray PIXELS
  g := ByteArray PIXELS
  b := ByteArray PIXELS

  adc := Adc (gpio.Pin 34)
  while true:
    shs_out := adc.get
    // output voltage is smaller if moisture concentration is higher
    lh/int := PIXELS - ((shs_out - SH_SENSOR_L) * SH_SENSOR_G).round
    if lh < 0:
      lh = 0
    if lh > PIXELS:
      lh = PIXELS
    print "$(%.1f shs_out) V ($(%d lh))"

    for i := 0; i < lh; i++:
      r[i] = 0
      g[i] = 0
      b[i] = 10
    for i := lh; i < PIXELS; i++:
      r[i] = 0
      g[i] = 0
      b[i] = 0

    pixels.output r g b
    sleep --ms=1000