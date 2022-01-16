# Drive digitally controlled potentiometer X9Cn0n

This folder contains some examples to show how to control X9C104 and similar digipots, and provides the Toit class to control it.

- [x9cn0n-simple](x9cn0n-simple.toit) - A simple example to provides the basis of operating X9Cn0n digipots.
- [x9cn0n-class](x9cn0n-class.toit) - The Toit class to operate the digipot.

## The Story

Digital potentiometers are around for years and there are hundreds of examples how to control them. I was looking for a way to provide a variable pull down and pull up resistors to test [gpio-pull-up-down](../gpio-pull-up-down) example but I could not find any Toit library to control a digipot. The after purchasing a quite popular X9C104 digipot and checking the datasheet as well as nice & simple Arduino library in a quite comprehensive article [Interfacing X9C104 100K Digital Potentiometer Module with Arduino](https://electropeak.com/learn/interfacing-x9c104-100k-ohm-digital-potentiometer-module-with-arduino/) written by Mehran Maleki I decided to write the control example in Toit. This also turnet out to be a very good opportunity to learn basics of writing clasess in Toit.

## Required Hardware

- ESP32 board with at least three exposed and unused GPIO pins
- X9C104 or any other [X9Cn0n](_more/REN_x9c102-103-104-503_DST_20050310.pdf) digipot on a breakout board
- Breadboard and some wires to make connections
- Ohm meter
- Optionally some LEDs to visualize the status of the digipot's pins

Note: I saw these digipots in DIP package. If you get one then no breakboard is needed.

## How to Use

Check the readme file in the [root folder](../README.md) for information how to configure and use Toit.

