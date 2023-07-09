/*
Sample program to control temperature and show parameters in a browser.

SPDX-License-Identifier: CC0-1.0
*/

import fixed_point show FixedPoint
import gpio
import max6675
import uart
import pid

/* Temperature control parameters
*/
temperature := 0.0
temperature_sp := 40.0
pid_output := 0.0  // 0.0 .. 1.0
control_loop_time ::= 200  // ms

/* Allocation of GPIO pins.
               ESP32 GPIO #  // Function (Pin Name)
*/
cs_gpio ::=     gpio.Pin 12  // Chip select (CS)
so_gpio ::=     gpio.Pin 13  // Serial output (SO)
sck_gpio ::=    gpio.Pin 14  // Serial clock  (SCK)

HEATER_GPIO ::= gpio.Pin 23 --output  // Heater output

/* GPIO pins for serial port to read data from the browser.
 - RX pin should be connected to RX0 (GPIO3) of UART0 of ESP32.
 - TX pin is not used in this program but should be configured to some free GPIO.
*/
SERIAL_RX_GPIO ::= gpio.Pin 4
SERIAL_TX_GPIO ::= gpio.Pin 2


main:
  task:: temperature_control
  task:: heater_pwm HEATER_GPIO
  task:: send_values
  task:: receive_values


/* Temperature control loop
that performs calculation of the heater output
to reduce the temperature error.
*/
temperature_control:

  device := max6675.DriverBitBang
    --cs=cs_gpio
    --so=so_gpio
    --sck=sck_gpio

  thermocouple := max6675.Driver device

  pid := pid.Controller --kp=0.05 --ki=0.0001
  last := Time.now

  while true:
    temperature = thermocouple.read.temperature
    control_error := temperature_sp - temperature
    pid_output = pid.update control_error last.to_now
    last = Time.now
    sleep --ms=control_loop_time


/* Heater control loop that outputs PWM signal
proportional to the PID output
calculated in the temperature control loop.
*/
heater_pwm heater_on:

  while true:
    heater_on_time := (pid_output * control_loop_time).to_int
    heater_on.set 1
    sleep --ms=heater_on_time
    heater_on.set 0
    sleep --ms=control_loop_time - heater_on_time


/* Send data to the browser for visualization.
*/
send_values:

  while true:
    print "[To UI] T: $(%0.1f temperature)°C SP: $(%0.1f temperature_sp)°C OUT: $(%d pid_output * 100)%"
    sleep --ms=1000

/* Receive temperature setpoint from the browser.
*/
receive_values:

  serial_port := uart.Port
    --rx=SERIAL_RX_GPIO
    --tx=SERIAL_TX_GPIO
    --baud_rate=115200
    --data_bits=8
    --parity=uart.Port.PARITY_DISABLED
    --stop_bits=uart.Port.STOP_BITS_1

  rs/string := ?
  while true:
    rs = serial_port.read.to_string
    print "[From UI] $(%s rs)"
    if rs.matches "SP: " --at=0:
      setpoint := FixedPoint (rs.copy 4 rs.size - 1) // remove newline
      temperature_sp = setpoint.to_float
      print "SP: $(%0.1f temperature_sp)°C"
    else:
      print "Unknown command"
    sleep --ms=100
