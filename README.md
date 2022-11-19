# pTuna

![pTuna](https://raw.githubusercontent.com/make-42/pTuna/master/Manual/cover.jpg)

An open-source DIY guitar tuner.

## Changelog

```
 - Alpha 1.0.9:
    - New splash screen
    - New boot animation
    - Slightly better code performance
    - Overclocked processor from 125MHz to 150MHz.
    - Version bump: v1.0.1 -> v1.0.9
```

## BOM (Prices in France as of June 2022)

- Raspberry Pi Pico (€ 4)
- SSD1306 OLED Display (€ 1.73)
- Adafruit PDM MEMS Microphone Breakout (Product ID: 3492) (€ 4.62)
- CR2032 (Battery holder) (€ 0.50)
- Toggle switch (€ 0.50)
- Wires (€ 0.40)

Total: € 11.75 (excluding shipping)

Note: If you are in Paris I'd definitely recommend [letmeknow](https://letmeknow.fr) for getting parts. The prices are affordable and the staff lovely!

## Building firmware

- Clone this repo
- Run this command:

`cd ./pTuna/Firmware/final/`

- Edit `build.sh` to point to your pico SDK folder.

- Build with:

`sh build.sh`

## Wiring

![pTuna Wiring](https://raw.githubusercontent.com/make-42/pTuna/master/Manual/Wiring.png)

## Schematic

![pTuna Schematic](https://raw.githubusercontent.com/make-42/pTuna/master/Manual/Schematic.png)
