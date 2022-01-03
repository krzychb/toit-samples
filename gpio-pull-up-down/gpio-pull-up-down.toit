/*
Internal week pull up and pull down resistor checking example

Check if GPIO input state corresponds with setting
  of internal weak pull up (WPU) / pull down (WPD) resistors.
Note: For the test to pass GPIO should not be connected  
  to a circuit that may influence state of WPU / WPD.

This example code is in the Public Domain (or CC0 licensed, at your option.)

Unless required by applicable law or agreed to in writing, this
  software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
  CONDITIONS OF ANY KIND, either express or implied.
*/

import gpio

ESP32_GPIO_COUNT ::= 40

// The wiht GPIOs numbers specifically excluded from the checking 
SKIP_GPIO := [
    1,    // UART TXD
    6,    // SPI flash
    7,    // SPI flash
    8,    // SPI flash
    9,    // SPI flash
    10,   // SPI flash
    11,   // SPI flash
    16,   // SPI flash
    17,   // SPI flash
    20,   // Not supported (exposed on ESP32-PICO-D4)
    24,   // Not supported
    28,   // Not supported
    29,   // Not supported
    30,   // Not supported
    31,   // Not supported
    34,   // No WPD / WPU circuit
    35,   // No WPD / WPU circuit
    36,   // No WPD / WPU circuit
    37,   // No WPD / WPU circuit
    38,   // No WPD / WPU circuit
    39,   // No WPD / WPU circuit
]

main:

  for i := 0; i < ESP32_GPIO_COUNT; i++:
    skip_check := false;
    SKIP_GPIO.do:
      if it == i:
        skip_check = true
        // We are just iterating to the end of do loop  
        // since break.do is not yet implemented.
    if skip_check:
      print "GPIO$(%d i) check skipped"
    else:
      gpio_test_passed := true
      // enable weak pull up and expect high state on the input
      pin := gpio.Pin i --input --pull_up
      if pin.get != 1:
        gpio_test_passed = false
        print "GPIO$(%d i) Note: reading other than high when pulled up"
      pin.close
      // enable weak pull down and expect low state on the input
      pin = gpio.Pin i --input --pull_down
      if pin.get != 0:
        gpio_test_passed = false
        print "GPIO$(%d i) Note: reading other than low when pulled down"
      if gpio_test_passed:
        print "GPIO$(%d i) "
          

