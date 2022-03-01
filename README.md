# Introduction

Zeta SBC is an Zilog Z80 based single board computer. It is inspired by Ampro Little Board Z80 and N8VEM project. Zeta SBC is software compatible with N8VEM SBC and Disk I/O boards.

## Pictures

### Complete Board

![Zeta SBC](files/Zeta%20Board.jpg)

### Zeta SBC with ParPortProp and a Floppy Drive

![Zeta SBC with ParPortProp](files/Zeta%20with%20ParPortProp%20-%20Perspective%20View.jpg)

# Specifications

Zeta SBC features following components:

* Z80 CPU
* 16550 UART - for connecting a console
* 8255 PPI - can be used for attaching a hard drive using PPIDE or controlling some external devices
* SMC FDC9266 floppy disk controller - NEC 765A / Intel 8272 compatible, with integrated data separator
* 512 KiB of battery backed SRAM
* 512 KiB of flash memory
* RTC

Zeta SBC is compact and easy to build:

* Footprint of an 3.5" floppy drive (100 mm x 170.18 mm) and PCB can be mounted under a 3.5" drive.
* Uses only through hole components.
* Assumes using commonly available 3.5" floppy drives (not many people have 5.25" drives and even less 8" ones). Although it should work with 5.25" drives too.
* Only 3 configuration jumpers.
* Easy to use flash memory instead of UV EPROM.
* PCB mounted connectors, no need to build cables.
* Uses widely available components
* An easy way to get a "taste" of CP/M era computing.

# Hardware Documentation

## Schematics

Zeta SBC - Schematics - Color - 1.0.pdf (see attachments at the bottom of this page)<br>

Zeta SBC - Schematics - BW - 1.0.pdf (see attachments at the bottom of this page)

### PCB Version 1.0

Zeta SBC - Board - Color - 1.0.pdf (see attachments at the bottom of this page)

### PCB Version 1.1

Zeta SBC - Board - Color - 1.1.pdf (see attachments at the bottom of this page)

### PCB Version 1.2

Zeta SBC - Board - Color - 1.2.pdf (see attachments at the bottom of this page)

### PCB Version 1.3

Zeta SBC - Board - Color - 1.3.pdf (see attachments at the bottom of this page)

## Input/Output ports

* Compatible with N8VEM SBC and N8VEM Disk I/O boards (FDC part only, no XT-IDE)
* 30h (aliases 32h, 34h, 36h) - FDC Main Status Register (N8VEM Disk I/O uses 36h)
* 31h (aliases 33h, 35h, 37h) - FDC Data Register (N8VEM Disk I/O uses 37h)
* 38h (aliases 39h - 3Fh)
  - Write - FDC Diginal Output Register (DOR), also known as latch.
    + Bit 0 - TC
    + Bit 1 - MOTOR (0 = Motor off, 1 = Motor on)
    + Bit 2 - MINI
    + Bit 3 - P2
    + Bit 4 - P1
    + Bit 5 - P0
    + Bit 6 - DENSEL (0 = High density, 1 = Low density)
    + Bit 7 - ~FDC_RST (0 = FDC RESET active, 1 = normal operation)
  - Read - FDC Digital Input Register (DIR)
    + Bit 0 - ~DC
    + Bits 1-7 - unused
  - N8VEM FDC compatibility notes:
    + Bit 1 is inverted, so upon system reset floppy drive motor(s) will be turned off
    + Bit 6 is inverted, but it is unlikely that it will cause any compatibility problems, as modern 3.5" drives don't use this signal
    + Bit 7 of the latch is used differently (and incorrectly) on N8VEM Disk I/O as an input to ~DC (disk change) line. In Zeta SBC this output is connected to FDC RESET input, and allows software controlled FDC reset.
    + ~DC (disk change) output from floppy drives can be read from DIR register, bit 0. It could be used by the system to detect floppy disk change. In such case CP/M should be warm rebooted.
* 60h-63h (alias 64h-67h) - PPI Registers
* 68h-6Fh - UART Registers
* 70h (aliases 71h-77h) - RTC Registers
  - Write:
    + Bits 0-3 - unused
    + Bit 4 - RTC Chip Enable
    + Bit 5 - RTC Write Enable
    + Bit 6 - RTC Clock
    + Bit 7 - RTC Input
  - Read:
    + Bit 0 - RTC Output
    + Bits 1-5 - unused
    + Bit 6 - Configuration Jumper (JP1)
    + Bit 7 - unused
* 78h (aliases 79h-7Bh) - RAM Page Select Register (CFG1)
  - Bits 0-3 - RAM page selection (A15-A18)
  - Bits 4-7 - unused
* 7Ch (aliases 7Dh-7Fh) - ROM Page register (CFG2)
  - Bits 0-3 - ROM page selection (A15-A18)
  - Bits 4-6 - unused
  - Bit 7 - ROM disable (~ROM_ENA signal)
* N8VEM compatibility notes:
  - Zeta SBC qualifies ~WR signal when accessing configuration registers, so accidental read access to them won't corrupt their content. This makes programs like SURVEY.COM work without crashing the system.
  - Zeta SBC doesn't check A1 when accessing configuration registers range (78h-7Fh), so write access to any of 78h-7Dh addresses will change CFG1 (78h-79h in N8VEM SBC) and write access to 7Ch-7Fh will change CFG2 (7Ch-7Dh in N8VEM SBC). This should not cause any compatibility problem, unless in the future N8VEM SBC or some N8VEM I/O devices will use 7Ah-7Bh or 7Eh-7Fh, and some software will try to access these ports.

## Interrupts

* UART interrupt output is connected to the ~INT of the Z80
* FDC interrupt output has three connection options, selected by JP3 jumper:
  1. JP3 position 1-2 - FDC interrupt output is connected to the ~INT input of the Z80. This setting is compatible with N8VEM interrupt and fast interrupt modes.
  2. JP3 position 2-3 - FDC interrupt output is connected to the ~NMI input of the Z80
  3. JP3 not installed - FDC interrupt line is not connected to the CPU. This setting can be used with polling I/O mode.

## Jumpers and Connectors

### Jumper JP1 - CONFIG

JP1 is a software configuration jumper. It can be read by software using RTC port (70h) bit 6. This jumper is not currently used by software.

### Jumper JP2 - PIN25_GND/VCC

JP2 connects pin 25 of the parallel port P4 to either GND or Vcc (+5). Note that pin 1 is the pin that is closer to the parallel connector.

Warning: If JP2 is set incorrectly, it is possible to create a short circuit of the 5 Volt power supply.

| **Jumper Position** | **Description** |
| :------------------ | :-------------- |
| 1-2 | P4 pin 25 is connected to the ground |
| 2-3 | P4 pin 25 is connected to Vcc. Use this position with PPIDE, make sure to set jumper K1 on PPIDE to position 2-3. Please refer to [PPIDE documentation](/w/file/28373213/ppide-Install.txt) for more information. |
| **no jumper*** | P4 pin 25 is left open |

\* default

### Jumper JP3 - FDC_INT/NMI

| **Jumper Position** | **Description** |
| :------------------ | :-------------- |
| 1-2 | FDC interrupt is connected to the ~INT input of  Z80. This is the default setting. Both interrupt and polling mode will work with it. |
| 2-3 | FDC interrupt is connected to the ~NMI input of Z80. |
| **no jumper*** | FDC interrupt is not connected. FDC polling mode will work with this setting |

\* default

### Connector P1 - POWER

Connect regulated +5V power supply to this connector.

| **Pin** | **Description** |
| :------ | :-------------- |
| tip (the inner contact) | Positive terminal - +5V |
| barrel / sleeve | Negative terminal - ground |

### Connector P2 - RESET

P2 is the connector for an external reset button.

### Connector P3 - SERIAL

P3 is the serial port connector. It is normally used for connecting a console or terminal. P3 uses pinout similar to that of IBM AT serial port (with some signals missing). Use a null modem cable to connect to a PC.

| **Pin Number** | **Description** |
| :------------- | :-------------- |
| 1 | Not used - Not connected on the SBC |
| 2 | RX |
| 3 | TX |
| 4 | DTR |
| 5 | GND |
| 6 | DSR |
| 7 - 9 | Not used - Not connected on the SBC |
| shield | GND |

### Connector P4 - PARALLEL

P4 is the parallel port connector. It is connected directly to the 8255 PPI and can be used for attaching an IDE hard disk using the PPIDE mini board, for controlling external devices (e.g. printer, watering system), or for extending the SBC (e.g. connecting an LCD display and a keyboard). The pinout of P4 is the same as in other N8VEM boards (SBC V1, SBC V2, SBC-188).

| **Pin Number** | **Description** | **Pin Number** | **Description** | **Pin Number** | **Description** | **Pin Number** | **Description** |
| :------------- | :-------------- | :------------- | :-------------- | :------------- | :-------------- | :------------- | :-------------- |
| 1 | PC0 | 9 | PC4 | 17 | PB7 | 25 | GND or Vcc (see JP2) |
| 2 | PA0 | 10 | PA4 | 18 | PB0 | 26 | GND |
| 3 | PC1 | 11 | PC5 | 19 | PB6 |  |  |
| 4 | PA1 | 12 | PA5 | 20 | PB1 |  |  |
| 5 | PC2 | 13 | PC6 | 21 | PB5 |  |  |
| 6 | PA2 | 14 | PA6 | 22 | PB2 |  |  |
| 7 | PC3 | 15 | PC7 | 23 | PB4 |  |  |
| 8 | PA3 | 16 | PA7 | 24 | PB3 |  |  |

### Connector P5 - FLOPPY

P5 is the floppy interface connector. It uses PC compatible pinout. When using a PC floppy cable with a twist, Drive A (ID 0) is the drive after the twist and Drive B (ID 1) is the drive before the twist. When using only one FDD, either a twisted cable can be used, or the BIOS can be patched to use Drive B.

| **Pin Number** | **Description** | **Direction (relative to the SBC)** | **Connected to** |
| :------------- | :-------------- | :---------------------------------- | :--------------- |
| 1-33 | Odd pins are GND |  | GND |
| 2 | High Density. This signal is ignored by most (all?) 3.5" drives. | Output | DOR (bit 6) |
| 4, 6 | Not used |  | No connection |
| 8 | Index Pulse | Input | Schmidt Trigger, FDC (IDX) |
| 10 | Motor On B | Output | DOR (bit 1), Buffer |
| 12 | Drive Select A | Output | FDC (US0, US1), Decoder |
| 14 | Drive Select B | Output | FDC (US0, US1), Decoder |
| 16 | Motor On A | Output | DOR (bit 1), Buffer |
| 18 | Direction | Output | FDC (LCT/DIR), Multiplexer |
| 20 | Step | Output | FDC (FR/STEP), Multiplexer |
| 22 | Write Data | Output | FDC (WDOUT), OC Buffer |
| 24 | Write Enable | Output | FDC (WE), OC Buffer |
| 26 | Track Zero | Input | Multiplexer, FDC (FLT/TR0) |
| 28 | Write Protect | Input | Multiplexer, FDC (WP/TS) |
| 30 | Read Data | Input | Schmidt Trigger, FDC (~DSKD) |
| 32 | Select Head | Output | FDC (HD), OC Buffer |
| 34 | Disk Changed | Input | DIR (bit 0) |

### Connector P6 - 5V

P6 is the 5V power output for the floppy drive. Alternatively it can be used instead of P1 for supplying power to the board. It is recommended to use a polarized header for P6 to avoid incorrect power polarity which probably will destroy FDD or components on the SBC board.

| **Pin Number** | **Description** |
| :------------- | :-------------- |
| 1 | 5V |
| 2 | GND |

# Bill of Materials (BOM)

## BOM Notes

Disclaimer: I did my best to make sure that components listed in this BOM will be compatible with Zeta SBC. Obviously I didn't order all of components listed here, and I was not able to actually verify that they will work. Please make sure to double check specifications on manufacturer's and seller's web site before ordering. Please let me know (or update the BOM) if you found any problems or incompatibilities.

Many components have multiple part numbers listed in BOM. There are some differences between various part numbers, such as:

* Different manufacturer (e.g. Texas Instruments vs. National Semiconductor for IC). Usually these ICs will be 100% compatible and won't have any differences in specifications. For some other components (e.g. connectors) different manufacturer also means different quality. It for example is likely to get a better quality connector from TE (was AMP/Tyco) than from some obscure manufacturer (e.g. components sold under Jameco ValuePro brand).
* Specification differences
  - Different IC families (LS, ALS), different technologies (TTL and CMOS). They have different specs, and you might prefer to use certain IC family.
  - Different IC speed/frequency, especially for CPU, PPI, and memory.
  - Mechanical differences, especially for switches. Pick whatever suits best in your enclosure.
  - Minor differences. For example: RoHS or Pb-free vs. regular components; thickness of gold plating on connectors; frequency stability of oscillators and crystals.
* Price differences

If unsure what to order, read specifications on seller's and manufacturer's web sites. There are some datasheets available in Zeta's [Documentation](/w/browse/#view=ViewFolder&param=Documentation) folder. Also please read Replacement Notes below. Finally, consult people on [N8VEM news group](http://groups.google.com/group/n8vem).

## BOM

| Component type | Reference | Description | Quantity | Possible sources and notes |
| :------------- | :-------- | :---------- | :------- | :------------------------- |
| PCB |  | Zeta SBC PCB Version 1.0 | 1 | Order from Sergey |
| Battery Holder | BT1 | CR2032 batter holder, 20 mm lead spacing | 1 | Jameco [355434](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_355434_-1), Mouser [122-2620-GR](http://www.mouser.com/ProductDetail/Eagle-Plastic-Devices/122-2620-GR/?qs=sGAEpiMZZMupuRtfu7GC%252bdT30ZRn29lxdufOO0Kb9bU%3D "Click to view additional information on this product."),[122-2520-GR](http://www.mouser.com/ProductDetail/Eagle-Plastic-Devices/122-2520-GR/?qs=sGAEpiMZZMupuRtfu7GC%252baV0gE1yIQM5wO6q6AKGNZU%3D "Click to view additional information on this product."),[122-2420-GR](http://www.mouser.com/ProductDetail/Eagle-Plastic-Devices/122-2420-GR/?qs=sGAEpiMZZMupuRtfu7GC%252beZOrkV%252bKN9%2FAB%252buxIS5wOM%3D "Click to view additional information on this product."), Radio Shack [270-009](http://www.radioshack.com/product/index.jsp?productId=3060977) |
| Capacitor | C1 - C28 | 0.1 uF ceramic, 5.08 mm lead spacing | 28 | Mouser [80-C323C104K5R](http://www.mouser.com/ProductDetail/Kemet/C323C104K5R5TA/?qs=sGAEpiMZZMuAYrNc52CMZJc2YQhHPlYVWR1uyzMGvKQ%3D "Click to view additional information on this product.") Jameco [25523](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_25523_-1)  |
| Capacitor | C29 | 47 uF, 6.3 V electrolytic | 1 | Jameco [31114](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_31114_-1), Mouser [667-ECA-1HHG470](http://www.mouser.com/ProductDetail/Panasonic-Electronic-Components/ECA-1HHG470/?qs=sGAEpiMZZMtZ1n0r9vR22be70OeCKE1EbiDEkso9tdM%3D "Click to view additional information on this product.") |
| Capacitor | C30 | 10 uF, 6.3 V electrolytic | 1 | Jameco [94221](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_94221_-1), Mouser [667-ECA-1HHG100B](http://www.mouser.com/ProductDetail/Panasonic-Electronic-Components/ECA-1HHG100B/?qs=sGAEpiMZZMtZ1n0r9vR22be70OeCKE1EPp5pYVHJnfQ%3D "Click to view additional information on this product.") |
| Diode | D1 | 1N4148 | 1 | Jameco [36038](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_36038_-1),[179215](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_179215_-1); Mouser [512-1N4148](http://www.mouser.com/ProductDetail/Fairchild-Semiconductor/1N4148/?qs=sGAEpiMZZMutXGli8Ay4kC4Bz7vbB60woGEFXf9TQ98%3D "Click to view additional information on this product."),[771-1N4148-T/R](http://www.mouser.com/ProductDetail/NXP-Semiconductors/1N4148113/?qs=sGAEpiMZZMutXGli8Ay4kE3wRMDwmh%2F%252bGmXBTkVQdt4%3D "Click to view additional information on this product.") |
| Diode | D2, D3 | Bi-level LED indicator | 1 | Jameco [2006676](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_2006676_-12006676); Mouser [696-SSF-LXH240GYD](http://www.mouser.com/ProductDetail/Lumex/SSF-LXH240GYD/?qs=sGAEpiMZZMurHQmwyojo5EtA%252bKO7aifq%2F8Iq2xqPbQI%3D "Click to view additional information on this product.") |
| Standoff | HOLE1, HOLE2, HOLE3, HOLE4 | Standoff, M3 male / female, 20 mm | 4 | Mouser [534-24317](http://www.mouser.com/ProductDetail/Keystone-Electronics/24317/?qs=sGAEpiMZZMs6x5FGDTpfsIdmmWiq5V9U4wJ1XZo48xk%3D "Click to view additional information on this product."),[534-25505](http://www.mouser.com/ProductDetail/Keystone-Electronics/25505/?qs=sGAEpiMZZMs6x5FGDTpfsIdmmWiq5V9Utxx9C%2Fw3Z7E%3D "Click to view additional information on this product."),[855-R30-3012002](http://www.mouser.com/ProductDetail/Harwin/R30-3012002/?qs=sGAEpiMZZMtzcnMBgC2bs6Id%2FK%2FNPiw4hN1Xmhg%2FQVw%3D "Click to view additional information on this product.") Note: The length of male end of these standoffs is 8 mm. It is too long for some floppy disk drives (you'll notice that standoff doesn't go completely inside the floppy drive mount hole). In this case cut a few millimeters using a file or a fine saw. |
| Screw | HOLE1, HOLE2, HOLE3, HOLE4 | Screw, M3, 6 mm | 4 | Use regular floppy or CD-ROM drive mounting screws.  Mouser [534-29311](http://www.mouser.com/ProductDetail/Keystone-Electronics/29311/?qs=sGAEpiMZZMs6x5FGDTpfsIdmmWiq5V9UXRwmMEDRMDY%3D "Click to view additional information on this product.")  |
| Connector | JP1, P2 | 2x1 pin header | 2 | Jameco [108338](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_108338_-1); Mouser [649-78229-102HLF](http://www.mouser.com/ProductDetail/FCI/78229-102HLF/?qs=sGAEpiMZZMtsLRyDR9nM1%252b9K9ogxAkAjs2jx2M%252b94WE%3D "Click to view additional information on this product.") |
| Connector | JP2, JP3 | 3x1 pin header | 2 | Jameco [109576](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_109576_-1); Mouser [649-69190-103HLF](http://www.mouser.com/ProductDetail/FCI/69190-103HLF/?qs=sGAEpiMZZMvlX3nhDDO4AIYfP1TbgJhjYISz3bCP%2Fwo%3D "Click to view additional information on this product."),[649-78229-103HLF](http://www.mouser.com/ProductDetail/FCI/78229-103HLF/?qs=sGAEpiMZZMtsLRyDR9nM14Vjyw4ze%252bjtWzL%2FZN0BySE%3D "Click to view additional information on this product.") |
| Connector | P1 | DC jack | 1 | Jameco [101178](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_101178_-1); Mouser [806-KLDX-0202-A](http://www.mouser.com/ProductDetail/Kycon/KLDX-0202-A/?qs=sGAEpiMZZMu2f9RNbWupYrp4fVeNia8SgJaG%252bI5Hr1k%3D "Click to view additional information on this product.") |
| Connector | P3 | DE9M, right angle PCB mount | 1 | Jameco [104943](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_104943_-1),[614441](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_614441_-1),[614459](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_614459_-1),[614432](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_614432_-1); Mouser [806-K22X-E9P-N](http://www.mouser.com/ProductDetail/Kycon/K22X-E9P-N/?qs=sGAEpiMZZMu857ZbtCGHt0PbUrjjd%2FNBm0naypBlx9c%3D "Click to view additional information on this product."),[806-K22X-E9P-N-99](http://www.mouser.com/ProductDetail/Kycon/K22X-E9P-N-99/?qs=sGAEpiMZZMu857ZbtCGHt%2FwNqbkdXVI1Hsm1P%252bducYc%3D "Click to view additional information on this product.") (teal color),[571-1734351-1](http://www.mouser.com/ProductDetail/TE-Connectivity-AMP/1734351-1/?qs=sGAEpiMZZMu857ZbtCGHt9wvM057StPOmYCG73Ah%252biQ%3D "Click to view additional information on this product."),[571-7478404](http://www.mouser.com/ProductDetail/TE-Connectivity-AMP/747840-4/?qs=sGAEpiMZZMu857ZbtCGHtwpRvUYYjR%2Fb0tNi%2FPWGuJ4%3D "Click to view additional information on this product.") |
| Connector | P4 | 13x2 pin header | 1 | Jameco [53495](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_53495_-1); Mouser [649-68602-126HLF](http://www.mouser.com/ProductDetail/FCI/68602-126HLF/?qs=sGAEpiMZZMtsLRyDR9nM1%252bmbmmVUI0dAYWKlImNZbew%3D "Click to view additional information on this product."),[649-77313-824-26LF](http://www.mouser.com/ProductDetail/FCI/77313-824-26LF/?qs=sGAEpiMZZMtsLRyDR9nM14Vjyw4ze%252bjtilYVPfgiHws%3D "Click to view additional information on this product.") Note: don't use shrouded connector, as it will interfere with the standoff and other components.  |
| Connector | P5 | 17x2 pin header shrouded | 1 | Jameco [68583](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_68583_-1),[753547](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_753547_-1); Mouser [737-BHR-34-VUA](http://www.mouser.com/ProductDetail/ADAM-TECH/BHR-34-VUA/?qs=sGAEpiMZZMtsLRyDR9nM1w%2Fb70V3tmfCftCK6iZWwMM%3D "Click to view additional information on this product.") |
| Connector | P6 | 2 pin header with friction lock | 1 | Jameco [232266](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_232266_-1),[613931](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_613931_-1); Mouser [571-6404562](http://www.mouser.com/ProductDetail/TE-Connectivity-AMP/640456-2/?qs=sGAEpiMZZMtsLRyDR9nM16DGeeXFND9gHLFcjtDJkhM%3D "Click to view additional information on this product."),[571-3-641126-2](http://www.mouser.com/ProductDetail/TE-Connectivity-AMP/3-641126-2/?qs=sGAEpiMZZMtsLRyDR9nM18mJd%252baLxMG9uKUwnVJVJ8s%3D "Click to view additional information on this product."),[571-3-641215-2](http://www.mouser.com/ProductDetail/TE-Connectivity-AMP/3-641215-2/?qs=sGAEpiMZZMtsLRyDR9nM16DGeeXFND9gdDlMjBZrVXQ%3D "Click to view additional information on this product.") Corresponding female connector: Jameco [234798](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_234798_-1); Mouser [571-770602-2](http://www.mouser.com/ProductDetail/TE-Connectivity-AMP/770602-2/?qs=sGAEpiMZZMtsLRyDR9nM168vwp4yW2ZSGNK4xeaBpHA%3D "Click to view additional information on this product."); Contacts (2 contacts needed): Jameco [234923](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_234923_-1),[736501](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_736501_-1); Mouser [571-770666-1](http://www.mouser.com/ProductDetail/TE-Connectivity-AMP/770666-1/?qs=sGAEpiMZZMtsLRyDR9nM18mJd%252baLxMG9GrlfGo%252bW7aE%3D "Click to view additional information on this product.") It is recommended to use a polarized header to avoid incorrect power polarity.  |
| Resistor | R1 | 10 Ohm, 1/4 W | 1 | Jameco [690380](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_690380_-1) Mouser [291-10-RC](http://www.mouser.com/ProductDetail/Xicon/291-10-RC/?qs=sGAEpiMZZMu61qfTUdNhG5WVxMYmJR0O1OUR1xbHmxs%3D "Click to view additional information on this product.")  |
| Resistor | R2 | 10 kOhm, 1/4 W | 1 | Jameco [691104](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_691104_-1) Mouser [291-10K-RC](http://www.mouser.com/ProductDetail/Xicon/291-10K-RC/?qs=sGAEpiMZZMu61qfTUdNhG6xwTrVwTvbz8PPav3aExs8%3D "Click to view additional information on this product.")  |
| Resistor | R3, R4 | 470 Ohm, 1/4 W | 2 | Jameco [690785](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_690785_-1) Mouser [291-470-RC](http://www.mouser.com/ProductDetail/Xicon/291-470-RC/?qs=sGAEpiMZZMu61qfTUdNhG1AdbDi3ermZfsjMZ8nKiDY%3D "Click to view additional information on this product.")  |
| Resistor Array | RR1 | 4.7 kOhm, 6 pin, bussed resistor array | 1 | Mouser [264-4.7K-RC](http://www.mouser.com/ProductDetail/Xicon/264-47K-RC/?qs=sGAEpiMZZMvrmc6UYKmaNVNDE5UWkgN%2FsgYW0PIGqes%3D "Click to view additional information on this product."),[652-4306R-1LF-4.7K](http://www.mouser.com/ProductDetail/Bourns/4306R-101-472LF/?qs=sGAEpiMZZMvrmc6UYKmaNWgIZ6biHU4EEgaZTof5r6w%3D "Click to view additional information on this product.") |
| Resistor Array | RR2 | 1 kOhm, 6 pin, bussed resistor array | 1 | Mouser [264-1.0K-RC](http://www.mouser.com/ProductDetail/Xicon/264-10K-RC/?qs=sGAEpiMZZMvrmc6UYKmaNQbJ%252b29QTxaEngMB%2FdVaAdM%3D "Click to view additional information on this product."),[652-4306R-1LF-1K](http://www.mouser.com/ProductDetail/Bourns/4306R-101-102LF/?qs=sGAEpiMZZMvrmc6UYKmaNTNUNwWuH088chgRi4yNveI%3D "Click to view additional information on this product.") |
| Switch | SW1 | Tactile switch, right angle | 1 | Mouser [611-PTS645VL39LFS](http://www.mouser.com/ProductDetail/CK-Components/PTS645VL39-LFS/?qs=sGAEpiMZZMsgGjVA3toVBBpDTNTTW0j3PFTGmAFHC2w%3D "Click to view additional information on this product."),[611-PTS645VL58LFS](http://www.mouser.com/ProductDetail/CK-Components/PTS645VL58-LFS/?qs=sGAEpiMZZMsgGjVA3toVBBpDTNTTW0j3IDaDbWTRu9A%3D "Click to view additional information on this product."),[611-PTS645VL83LFS](http://www.mouser.com/ProductDetail/CK-Components/PTS645VL83-LFS/?qs=sGAEpiMZZMsgGjVA3toVBBpDTNTTW0j3rnMu07KpUX4%3D "Click to view additional information on this product."),[611-PTS645VL15LFS](http://www.mouser.com/ProductDetail/CK-Components/PTS645VL15-LFS/?qs=sGAEpiMZZMsgGjVA3toVBBpDTNTTW0j3NFq3KfxP94Y%3D "Click to view additional information on this product.")(Note: these switches have different actuator length, the number at the end of the part number denotes the length measured from ground terminal - from 3.9 mm to 15 mm. You might want to select it according your own preferences, for example the enclosure type you want to use, and whatever you want the reset button to stick out of the enclosure, or to stay hidden inside) Jameco [1953575](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_1953575_-1),[202956](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_202956_-1)  |
| IC | U1 | Z80 CPU, CMOS, 40 pin DIP - Z84C00xxPEC | 1 | Mouser [692-Z84C0010PEG](http://www.mouser.com/ProductDetail/ZiLOG/Z84C0010PEG/?qs=sGAEpiMZZMvu0Nwh4cA1wSoSQ2enekUq2IMsKtAiEbo%3D "Click to view additional information on this product."),[692-Z84C0008PEG](http://www.mouser.com/ProductDetail/ZiLOG/Z84C0008PEG/?qs=sGAEpiMZZMvu0Nwh4cA1wWtRoPcQBaz3A%252bL%2FQ9ovAB8%3D "Click to view additional information on this product.") Jameco [35781](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_35781_-135781),[35705](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_35705_-1)(It appears that Jameco doesn't have 8MHz+ Z80 any more) Frequency of U21 (CPU clock) oscillator should be less or equal to CPU frequency. 8MHz CPU recommended for 1.44 MB floppy disks support.  |
| IC | U2 | 512 KiB flash, 32 pin DIP - 29F040, 29C040, 39SF040 | 1 | Mouser [804-39SF0407CPHE](http://www.mouser.com/ProductDetail/Microchip-Technology/SST39SF040-70-4C-PHE/?qs=sGAEpiMZZMtI%252bQ06EiAoGwr0W47sj3OOZ45%252baf2mLJ4%3D "Click to view additional information on this product."); Jameco [242667](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_242667_-1),[242659](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_242659_-1) |
| IC | U3 | 512 KiB SRAM, 32 pin DIP - AS6C4008-55PCN | 1 | Mouser [913-AS6C4008-55PCN](http://www.mouser.com/ProductDetail/Alliance-Memory/AS6C4008-55PCN/?qs=sGAEpiMZZMt9mBA6nIyysPeGHDtAZQ%252bHv1ODopTep98%3D "Click to view additional information on this product."); Jameco [1927617](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_1927617_-1) Note: Jameco 242448 and 157358 (BS62LV4006P) should work too, but they are way too expensive  |
| IC | U4 | 16550 UART | 1 | Mouser [701-ST16C550CP40-F](http://www.mouser.com/ProductDetail/Exar/ST16C550CP40-F/?qs=sGAEpiMZZMvslxq79%2FS5eUCA3FEAk74zGi0B8%2FzwcfA%3D "Click to view additional information on this product."); Jameco [27596](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_27596_-1),[288809](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_288809_-1) |
| IC | U5 | 8255 PPI | 1 | Mouser [968-CP82C55AZ](http://www.mouser.com/ProductDetail/Intersil/CP82C55AZ/?qs=cbl4%252bYHJGOF3%2FjEgaAvGRe5K%2FILMXjQ3 "Click to view additional information on this product."),[968-CP82C55A](http://www.mouser.com/ProductDetail/Intersil/CP82C55A/?qs=B4b5rvZIvWUoKcRPBZOAqTe8YvZ7Q5In "Click to view additional information on this product."); Jameco [52417](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_52417_-1) Unicorn Electronics (order 82C55);  |
| IC | U6 | FDC9266 FDC | 1 | Order from Sergey; Utsource; eBay (beware, some sellers have way too high price on this IC). Can be replaced with FDC9268, in this case U23 frequency should be 16 MHz. |
| IC | U7 | 74LS273 | 1 | Mouser [595-SN74ALS273N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74ALS273N/?qs=sGAEpiMZZMvxP%252bvr8KwMwLcnqnc7ytuCSdm8rhHZ20Q%3D "Click to view additional information on this product."),[512-DM74ALS273N](http://www.mouser.com/ProductDetail/Fairchild-Semiconductor/DM74ALS273N/?qs=sGAEpiMZZMvxP%252bvr8KwMwC7zurHDHx7mG1kHgpYvQYs%3D "Click to view additional information on this product."),[595-SN74LS273N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74LS273N/?qs=sGAEpiMZZMvxP%252bvr8KwMwE%2FH01ykG3Ig8PvmfhhDmpo%3D "Click to view additional information on this product."),[595-SN74AHCT273N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT273N/?qs=sGAEpiMZZMvxP%252bvr8KwMwLcnqnc7ytuC4LhHLUd1T3c%3D "Click to view additional information on this product."); Unicorn Electronics; Jameco [47386](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_47386_-1),[308398](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_308398_-1),[45049](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_45049_-1)  |
| IC | U8 | 74LS240 | 1 | Mouser [595-SN74ALS240AN](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74ALS240AN/?qs=sGAEpiMZZMuiiWkaIwCK2bK%2FUlbxrrJCstrLRa7dF2I%3D "Click to view additional information on this product."),[595-SN74LS240N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74LS240N/?qs=sGAEpiMZZMuiiWkaIwCK2UHhUsuHvyUOLkmAhnV0bVo%3D "Click to view additional information on this product."),[595-SN74AHCT240N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT240N/?qs=sGAEpiMZZMuiiWkaIwCK2bK%2FUlbxrrJCjatBJKq2nRs%3D "Click to view additional information on this product."); Unicorn Electronics; Jameco [47141](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_47141_-1),[308291](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_308291_-1),[45014](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_45014_-1)  |
| IC | U9, U10, U11 | 74LS174 | 3 | Mouser [595-SN74ALS174N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74ALS174N/?qs=sGAEpiMZZMvxP%252bvr8KwMwH1qxRiYd9fqotp0hrbNkvI%3D "Click to view additional information on this product."),[595-SN74LS174N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74LS174N/?qs=sGAEpiMZZMvxP%252bvr8KwMwOIDaP0%252beD%2FyRsSdiADfoLM%3D "Click to view additional information on this product."),[595-SN74AHCT174N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT174N/?qs=sGAEpiMZZMvxP%252bvr8KwMwH1qxRiYd9fqkE7X46My71M%3D "Click to view additional information on this product."); Unicorn Electronics; Jameco [46931](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_46931_-1),[301760](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_301760_-1)  |
| IC | U12 | 74F139 | 1 | Mouser [595-SN74ALS139N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74ALS139N/?qs=sGAEpiMZZMtxONTBFIcRfq4mebfZO%252bELhxGgXnQWC8c%3D "Click to view additional information on this product."),[595-SN74LS139AN](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74LS139AN/?qs=sGAEpiMZZMtxONTBFIcRfpKvrGTByBdi%2FBZhV6RAyCA%3D "Click to view additional information on this product."),[595-CD74ACT139E](http://www.mouser.com/ProductDetail/Texas-Instruments/CD74ACT139E/?qs=sGAEpiMZZMtxONTBFIcRfsQCBiNmETR9yYy7yqk6Oio%3D "Click to view additional information on this product."),[512-74ACT139PC](http://www.mouser.com/ProductDetail/Fairchild-Semiconductor/74ACT139PC/?qs=sGAEpiMZZMtxONTBFIcRfil%2Fstwym1XXVoaftb8reqY%3D "Click to view additional information on this product."),[595-SN74AHCT139N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT139N/?qs=sGAEpiMZZMtxONTBFIcRfsQCBiNmETR9s6YW4lCucrQ%3D "Click to view additional information on this product."); Unicorn Electronics; Jameco [46623](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_46623_-1),[301268](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_301268_-1),[63773](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_63773_-1),[239011](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_239011_-1)  |
| IC | U13 | 74LS138 | 1 | Mouser [595-SN74ALS138AN](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74ALS138AN/?qs=sGAEpiMZZMtxONTBFIcRfgMIbQHDmxevHm7M5LBU91I%3D "Click to view additional information on this product."),[512-DM74ALS138N](http://www.mouser.com/ProductDetail/Fairchild-Semiconductor/DM74ALS138N/?qs=sGAEpiMZZMtxONTBFIcRfmXc22tCNV5puFUyD3ssFWc%3D "Click to view additional information on this product."),[595-SN74LS138N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74LS138N/?qs=sGAEpiMZZMtxONTBFIcRfpKvrGTByBdiQjlbb3Ynr4s%3D "Click to view additional information on this product."),[595-SN74AHCT138N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT138N/?qs=sGAEpiMZZMtxONTBFIcRfsQCBiNmETR9UG1XXuubiis%3D "Click to view additional information on this product."); Unicorn Electronics; Jameco [46607](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_46607_-1),[46608](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_46608_-1),[301233](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_301233_-1),[44927](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_44927_-1)  |
| IC | U14 | 74LS125 | 1 | Mouser [595-SN74LS125AN](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74LS125AN/?qs=sGAEpiMZZMuiiWkaIwCK2WAncryyStC7ZVuQLUtSxbI%3D "Click to view additional information on this product."),[595-SN74AHCT125N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT125N/?qs=sGAEpiMZZMuiiWkaIwCK2YBcf8bvyFlOxbSCg1DZEdI%3D "Click to view additional information on this product."); Unicorn Electronics; Jameco [46501](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_46501_-1)  |
| IC | U15, U16, U17 | 74LS32 | 3 | Mouser [595-SN74ALS32N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74ALS32N/?qs=sGAEpiMZZMtMa9lbYwD6ZFfNaxHsgUwaIDUbKItpOSQ%3D "Click to view additional information on this product."),[512-DM74ALS32N](http://www.mouser.com/ProductDetail/Fairchild-Semiconductor/DM74ALS32N/?qs=sGAEpiMZZMtMa9lbYwD6ZE1jns5lgn1Bh06DPj26jcM%3D "Click to view additional information on this product."),[595-SN74LS32N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74LS32N/?qs=sGAEpiMZZMtMa9lbYwD6ZOuZLcSXNpUacHuLMioAEnk%3D "Click to view additional information on this product."),[595-SN74AHCT32N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT32N/?qs=sGAEpiMZZMtMa9lbYwD6ZAv0bRAq9ZjLc7SArqaJcaQ%3D "Click to view additional information on this product."); Unicorn Electronics; Jameco [44134](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_44134_-1),[47466](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_47466_-1),[47467](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_47467_-1),[295515](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_295515_-1)  |
| IC | U18,U19 | 74LS14 | 2 | Mouser [595-SN74LS14N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74LS14N/?qs=sGAEpiMZZMuyBeSSR239Ias%252b1yN%2FIiBNAdJP0U6%2Fu9k%3D "Click to view additional information on this product."),[595-SN74AHCT14N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT14N/?qs=sGAEpiMZZMuyBeSSR239Ias%252b1yN%2FIiBNVP9ThiduLa4%3D "Click to view additional information on this product."); Unicorn Electronics; Jameco [46640](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_46640_-1),[295460](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_295460_-1),[44935](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_44935_-1)  |
| IC | U20 | 74LS06 | 1 | Mouser [595-SN74LS06N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74LS06N/?qs=sGAEpiMZZMuiiWkaIwCK2VXqsqoZKDeCkeD2aBHhlIw%3D "Click to view additional information on this product."); Unicorn Electronics; Jameco [46359](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_46359_-1) |
| IC | U21 | CPU clock oscillator, full can | 1 | See frequency selection note for U1.  4 MHz: Jameco [27967](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_27967_-1),[354889](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_354889_-1); Mouser [815-ACO-4-EK](http://www.mouser.com/ProductDetail/ABRACON/ACO-4000MHZ-EK/?qs=sGAEpiMZZMt8zWNA7msRCufK6FojpZgBkZbpC3y2DKw%3D "Click to view additional information on this product."),[520-TCF400-X](http://www.mouser.com/ProductDetail/ECS/ECS-100AX-40/?qs=sGAEpiMZZMt8zWNA7msRCkZF6o3VgKlS%252bNJe%252bsVHAhg%3D "Click to view additional information on this product.") 6 MHz: Mouser [520-TCF600-X](http://www.mouser.com/ProductDetail/ECS/ECS-100AX-60/?qs=sGAEpiMZZMt8zWNA7msRCkZF6o3VgKlSVVceCglATlo%3D "Click to view additional information on this product.") 8 MHz: Jameco [27991](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_27991_-1); Mouser [815-ACO-8-EK](http://www.mouser.com/ProductDetail/ABRACON/ACO-8000MHZ-EK/?qs=sGAEpiMZZMt8zWNA7msRCufK6FojpZgBol2LWy2yIwI%3D "Click to view additional information on this product."),[520-TCF800-X](http://www.mouser.com/ProductDetail/ECS/ECS-100AX-80/?qs=sGAEpiMZZMt8zWNA7msRCkZF6o3VgKlSdZ7QUqFOCa0%3D "Click to view additional information on this product.")(see Mods section below) 10 MHz: Jameco [27887](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_27887_-1); Mouser [815-ACO-10-EK](http://www.mouser.com/ProductDetail/ABRACON/ACO-10000MHZ-EK/?qs=sGAEpiMZZMt8zWNA7msRCufK6FojpZgBI8%252bDSKO898Q%3D "Click to view additional information on this product."),[520-TCF1000-X](http://www.mouser.com/ProductDetail/ECS/ECS-100AX-100/?qs=sGAEpiMZZMt8zWNA7msRCkZF6o3VgKlSWiBx3iH%252buXU%3D "Click to view additional information on this product.") 20 MHz: Jameco [27932](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_27932_-1); Mouser [815-ACO-20-EK](http://www.mouser.com/ProductDetail/ABRACON/ACO-20000MHZ-EK/?qs=sGAEpiMZZMt8zWNA7msRCufK6FojpZgBfQRL%252bhz7SWY%3D "Click to view additional information on this product."),[520-TCF2000-X](http://www.mouser.com/ProductDetail/ECS/ECS-100AX-200/?qs=sGAEpiMZZMt8zWNA7msRCkZF6o3VgKlSDgSisz37dM4%3D "Click to view additional information on this product.")  |
| IC | U22 | 1.8432 MHz oscillator, full can | 1 | Mouser [520-TCF184-X](http://www.mouser.com/ProductDetail/ECS/ECS-100AX-18432/?qs=sGAEpiMZZMt8zWNA7msRCkZF6o3VgKlSBPpGLyq2pks%3D "Click to view additional information on this product."),[73-XO54B184](http://www.mouser.com/ProductDetail/Vishay-Dale/XO54CTFDNA1M8432/?qs=sGAEpiMZZMt8zWNA7msRCu1XxScnrkrhewGkTIUizKw%3D "Click to view additional information on this product.") Jameco [27879](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_27879_-1)  |
| IC | U23 | 8 MHz oscillator, full can | 1 | Mouser [815-ACO-8-EK](http://www.mouser.com/ProductDetail/ABRACON/ACO-8000MHZ-EK/?qs=sGAEpiMZZMt8zWNA7msRCufK6FojpZgBol2LWy2yIwI%3D "Click to view additional information on this product."),[520-TCF800-X](http://www.mouser.com/ProductDetail/ECS/ECS-100AX-80/?qs=sGAEpiMZZMt8zWNA7msRCkZF6o3VgKlSdZ7QUqFOCa0%3D "Click to view additional information on this product.") Jameco [27991](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_27991_-1)  |
| IC | U24 | MAX232A | 1 | Mouser [595-TRS202ECN](http://www.mouser.com/ProductDetail/Texas-Instruments/TRS202ECN/?qs=sGAEpiMZZMtnIqnDeWcRHWI38aDrBTNBLAGTpxcqmuc%3D "Click to view additional information on this product."),[701-SP202ECP-L](http://www.mouser.com/ProductDetail/Exar/SP202ECP-L/?qs=sGAEpiMZZMtnIqnDeWcRHSgmUQC5j8NkoHNGApCEA9Y%3D "Click to view additional information on this product."),[700-MAX202CPE](http://www.mouser.com/ProductDetail/Maxim-Integrated-Products/MAX202CPE+/?qs=sGAEpiMZZMtnIqnDeWcRHUtumypDpQDCpJdkfz6bbNk%3D "Click to view additional information on this product."),[700-MAX232ACP](http://www.mouser.com/ProductDetail/Maxim-Integrated-Products/MAX232ACPE+/?qs=sGAEpiMZZMtnIqnDeWcRHUtumypDpQDCv4cSYmApFFc%3D "Click to view additional information on this product.") Jameco [875384](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_875384_-1),[1127599](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_1127599_-1),[1800552](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_1800552_-1),  |
| IC | U25 | DS1302 | 1 | Mouser [700-DS1302](http://www.mouser.com/ProductDetail/Maxim-Integrated-Products/DS1302+/?qs=sGAEpiMZZMvOtLZKYNhBPfvFGMWHxUVD%2Ffq1bsN5Huo%3D "Click to view additional information on this product."),[700-DS1302N](http://www.mouser.com/ProductDetail/Maxim-Integrated-Products/DS1302N+/?qs=sGAEpiMZZMvOtLZKYNhBPfvFGMWHxUVDqtwoJwAsIxs%3D "Click to view additional information on this product.") Jameco [176778](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_176778_-1),[780481](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_780481_-1),[1194644](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_1194644_-1)  |
| IC | U26 | DS1210 | 1 | Mouser [700-DS1210](http://www.mouser.com/ProductDetail/Maxim-Integrated-Products/DS1210+/?qs=sGAEpiMZZMutXGli8Ay4kC27Vf1CC6GrOwlPIFnsd9g%3D "Click to view additional information on this product."),[700-DS1210N](http://www.mouser.com/ProductDetail/Maxim-Integrated-Products/DS1210N+/?qs=sGAEpiMZZMutXGli8Ay4kC27Vf1CC6Grf9M4pGwveWo%3D "Click to view additional information on this product.") Jameco [114198](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_114198_-1),[2052040](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_2052040_-1),[861880](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_861880_-1)  |
| IC Socket | U1, U4 - U6 | 40 pin 600 mil DIP socket | 4 | Jameco [41111](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_41111_-1) Mouser [649-DILB40P223TLF](http://www.mouser.com/ProductDetail/FCI/DILB40P-223TLF/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tnWBa37eU7kEvItX7WAak1Y%3D "Click to view additional information on this product."),[517-4840-6000-CP](http://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/4840-6000-CP/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXo7HrzikVwIY8%3D "Click to view additional information on this product.")  |
| IC Socket | U2, U3 | 32 pin 600 mil DIP socket | 2 | Jameco [112301](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_112301_-1) Mouser [649-DILB32P223TL](http://www.mouser.com/ProductDetail/FCI/DILB32P223TLF/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tuCWXqks4O6emg1jqvuxPfs%3D "Click to view additional information on this product."),[517-4832-6000-CP](http://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/4832-6000-CP/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXooeQG9KGDPHw%3D "Click to view additional information on this product.")  |
| IC Socket | U7, U8 | 20 pin 300 mil DIP socket | 2 | Jameco [112248](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_112248_-1) Mouser [649-DILB20P-223TLF](http://www.mouser.com/ProductDetail/FCI/DILB20P-223TLF/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tqkewsuxcQXGl93XoFG0NGQ%3D "Click to view additional information on this product."),[517-4820-3000-CP](http://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/4820-3000-CP/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXoGLwqMMa088g%3D "Click to view additional information on this product.")  |
| IC Socket | U9 - U13, U24 | 16 pin 300 mil DIP socket | 6 | Jameco [37373](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_37373_-1) Mouser [649-DILB16P-223TLF](http://www.mouser.com/ProductDetail/FCI/DILB16P-223TLF/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tnWBa37eU7kEZ8uy8DVlop0%3D "Click to view additional information on this product."),[517-4816-3000-CP](http://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/4816-3000-CP/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXo2MaLGaLrmns%3D "Click to view additional information on this product.")  |
| IC Socket | U14 - U20 | 14 pin 300 mil DIP socket | 7 | Jameco [37162](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_37162_-1) Mouser [649-DILB14P-223TLF](http://www.mouser.com/ProductDetail/FCI/DILB14P-223TLF/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXoudDvhlAH3XM%3D "Click to view additional information on this product."),[517-4814-3000-CP](http://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/4814-3000-CP/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXolv7TyDO1KrY%3D "Click to view additional information on this product.")  |
| IC Socket | U25, U26 | 8 pin 300 mil DIP socket | 2 | Jameco [51571](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_51571_-1) Mouser [649-DILB8P223TLF](http://www.mouser.com/ProductDetail/FCI/DILB8P-223TLF/?qs=sGAEpiMZZMs%2FSh%2Fkjph1trsk3O0a2elqycTEeDCVfAg%3D "Click to view additional information on this product."),[517-4808-3000-CP](http://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/4808-3000-CP/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXoueZQAPgo6HQ%3D "Click to view additional information on this product.")  |
| Oscillator Socket | U21 - U23 | 4 pin 300 mil DIP full can oscillator socket | 3 | Jameco [133006](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_133006_-1) Mouser [535-1107741](http://www.mouser.com/ProductDetail/Aries/1107741/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXoVZs6QxzSzII%3D "Click to view additional information on this product.")  |
| Crystal | X1 | 32768 Hz crystal | 1 | Mouser [732-C002RX32.76K-EPB](http://www.mouser.com/ProductDetail/Epson-Toyocom/C-002RX-327680K-EPBFREE/?qs=sGAEpiMZZMsBj6bBr9Q9acukpafrIaZ1yd2OUFKhF0I%3D "Click to view additional information on this product."),[695-CFS206-327KB-U](http://www.mouser.com/ProductDetail/Citizen/CFS206-32768KDZB-UB/?qs=sGAEpiMZZMsBj6bBr9Q9aQX%2FBWSXR5XrkmCKe%2FKi0Qw%3D "Click to view additional information on this product.") Jameco [14584](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_14584_-1)  |

## Replacement Notes

* 74xx logic
  - TTL logic families: 74LS, 74ALS, 74F, or TTL-compatible CMOS: 74HCT and 74AHCT could be used.
  - Plain 74LS should work with CPU frequency up to 8 MHz. But it is recommended to use higher speed and lower power 74ALS ICs.
  - It is recommended to use 74F139 or 74ACT139 for U12, especially if using older 5.25" FDDs. I tested it with 74LS139, 74ALS139, and 74AHCT139 and it worked for me with modern 3.5" FDDs.
  - Tested with 74LS, 74ALS and 74HCT / 74AHCT (except of 74LS06) logic families. Works on frequency up to 20MHz.
* Z80-CPU
  - Either NMOS or CMOS Z80 CPU works. It is recommended to use at least 4 MHz CPU. 6 MHz or faster CPU is required for 1.44MB disk support. 8 MHz is recommended.
  - CMOS versions - Z84C00xxPEC or Z84C00xxPEG are recommended. Note: PEC or PEG suffixes mean 40 pin plastic DIP package, PEG is RoHS compliant, PEC is not.
  - Tested with CMOS Z84C00 (6MHz, 8MHz, 20MHz) and NMOS Z8400 (4MHz)
* 16550 UART
  - 8250, 16450, or 16550.
  - 16550 is recommended
  - Tested with: Texas Instruments TL16C550, Exar ST16C550, National Semiconductor NS16550AFN, California Micro Devices CM16C550, Goldstar GM16C450, and UMC 8250B
* 8255 PPI
  - It is recommended to use higher speed CMOS versions. For example 8 MHz Intersil / Harris CP82C55A part (note CP82C55A-5 is 5 MHz), 10 MHz Toshiba TMP82C55AP-10 or NEC D71055C-10 parts.
  - Tested with: Harris/Intersil CP82C55, TMP82C55AP-10, NEC D71055C-10, Intel 8255-5
* MAX232A
  - Can be replaced by pin compatible devices like Intersil HIN232 and Analog Devices ADM202. Make sure to use part that works with 0.1uF capacitors. See mods section below if using part that works only with 1uF capacitors.
* Bi-Level LED Indicator
  - Can be replaced by two 3 mm LEDs with pins bended at 90 degrees.

## Power Supply

Zeta SBC requires a **regulated** 5V power supply. Make sure that the tip of the power supply is the positive lead. System's power consumption varies depending on components used on SBC (CMOS CPU/PPI/UART vs. n-MOS components, CMOS logic vs. TTL/LS vs. TTL/ALS) and CPU clock frequency. Also floppy disk drives are relatively power hungry (about 1 A max). Jameco carries quite a few regulated switching 5V wall adapters with different amperage. See these catalog pages:

[http://www.jameco.com/Jameco/catalogs/c113/P105.pdf](http://www.jameco.com/Jameco/catalogs/c113/P105.pdf)

[http://www.jameco.com/Jameco/catalogs/c113/P106.pdf](http://www.jameco.com/Jameco/catalogs/c113/P106.pdf)

Alternatively it is possible to use a linear power supply with 7805 or similar voltage regulator (make sure to use a heatsink, especially if powering a floppy drive).

# Mods

Mods described here were intentionally not implemented on PCB to keep it simple.

* It is possible to use MAX232 for U24 instead of MAX232A, in this case capacitors C25 - C28 need to be replaced with 1uF electrolytic capacitors. Please refer to MAX232 datasheet for proper polarity.
  - Note: Zeta SBC version 1.3 has capacitors polarity marked on the silkscreen. The orientation of the capacitors on Zeta SBC version 1.3 differs from previous versions, so don't use its silkscreen to determine capacitors polarity on the previous PCB versions. Use [this picture](/w/file/50221014/POLARITY.JPG) instead (Sergio, thanks for the picture).
* It is possible to use half can oscillators instead of full can ones. In this case install oscillator at pins 4 - 11 and connect oscillator's pin 14 (VCC) to pin 11 using a piece of wire.
  - Note: Zeta SBC version 1.3 supports half can oscillators without any modifications.
* If using 8 MHz CPU it is possible to save one oscillator, by using single 8 MHz oscillator for both CPU and FDC. In this case connect pins 8 of U21 and U23 using a piece of wire. (Douglas says: I am doing this and it works great)
* It is possible to use FTDI DB9-USB-M module instead of the serial port connector P3. This module contains RS232 to USB converter IC and provides a mini USB connector. (Alexey, thank you for this tip). It even might be possible to use FTDI DB9-USB-D5-M module, eliminating MAX232A and related capacitors, and connecting the module directly to the UART.
* It can be possible to use 1 MiB 27C080 EPROM. It has a bit different pinout from 29F040, so doing this will require cutting a couple of traces and adding some wires. Please compare datasheets for proper connection. Connect pin 12 of U10 to A19 of 27C080.
* It is possible to use 128 KiB 29F010 or 256 KiB 29F020 flash, and 128 KiB SRAM. Lower size flash devices should work without any changes (note, some AMD AM29F002 parts use pin 1 as ~RESET pin, apparently in this case pin 1 should be connected to Vcc). 128 KiB SRAM parts have two chip select inputs, in this case the second chip select CE2, pin 30, should be connected to Vcc.
* If you don't plan to use 8255 PPI, it can be omitted. In this case it is not needed to install U4, C4, P4, and JP2.
* It is possible to build Zeta SBC without floppy disk controller (for example for the test purposes, or if you don't need floppy). In this case following components can be omitted: U6, U7, U8, U19, U20, U23, C6, C7, C8, C19, C20, C23, JP3, RR2, P5, P6 (Note U20 also used for UART interrupt, so don't take it out if using interrupt-driven UART I/O)
* It is possible to build system without RTC, in this case following components can be omitted: U11, C11, U25, X1
* If you don't want battery backup for SRAM, it is possible to omit U26. In this case it is needed to connect U26 pin 5 to pin 6 (~RAM_CS) and pin 1 to pin 8 (VCC).

# PCB Versions

## PCB Version 1.0

* First PCB run, no major issues reported.
* Reverse power supply polarity protection would be nice.

## PCB Version 1.1

* No changes to copper layers, a few minor updates to the silkscreen:
  - Added a drawing indicating power jack polarity.
  - Added outline for shrouded floppy interface connector, and moved floppy connector labels outside of that outline.
  - Added outline for keyed floppy power connected, and moved (+), (-) signs outside of the outline.
  - Added a logo.

## PCB Version 1.2

* No schematics changes
* Minor updates to copper layers and to the silkscreen:
  - 20% wider power traces - 24 mils instead of 20 mils.
  - Some minor traces optimization.
  - Updated version and copyright information on the silkscreen.
* Blue solder mask

## PCB Version 1.3 (Current Version)

* No schematics changes
* Footprint of MAX232 charge pump capacitors C24 - C28 changed to C1-1, allowing using either capacitors with 5.08 mm (0.2") lead pitch or with 2.54 mm (0.1") lead pitch, for example electrolytic capacitors.
* Added polarity (+) sign for C24 - C28 capacitors.
* Connected pin 11 of oscillators U21 - U23 to VCC, so that half size oscillators can be used without any modifications to PCB.
* Added half size oscillators footprint to the silkscreen.
* Rotated crystal X1 (32768 Hz) by 90 degrees. Added pads for horizontal mounting bracket.

## Various Ideas

* Image enhancements
  - NVRAM support (BIOS configuration using NVRAM), NVRAM configuration utility
* Enhance utility for programming the BIOS, CP/M, and ROM disk separately. (It already supports the full image programming)
* Add incorrect power supply polarity protection
  - Option 1: Schottky diode in series
  - Option 2: Diode connected in parallel to power supply, in reverse (could be dangerous if power supply is not short circuit protected)
  - Option 3: Use FET
* DSR/DTR signals from UART are currently exposed on RS-232 connector. However, 16C550C UART provides for auto flow control on the RTS/CTS lines which are not currently connected. Ideally, provide a mechanism (jumpers?) to choose whether to expose RTS/CTS as an alternative to DSR/DTR. The Z80 SBC V2 has an example of this.

# Files

| Link | Modified |
| :--- | :------- |
| [Complete System - Perspective View.jpg](files/Complete%20System%20-%20Perspective%20View.jpg) (146k) | Sergey Kiselev, Oct 9, 2012, 3:44 PM |
| [Complete System.jpg](files/Complete%20System.jpg) (127k) | Sergey Kiselev, Oct 9, 2012, 3:44 PM |
| [Zeta Board.jpg](files/Zeta%20Board.jpg) (282k) | Sergey Kiselev, Oct 9, 2012, 3:44 PM |
| [Zeta SBC - Board - Color - 1.0.pdf](files/Zeta%20SBC%20-%20Board%20-%20Color%20-%201.0.pdf) (1029k) | Sergey Kiselev, Oct 9, 2012, 3:50 PM |
| [Zeta SBC - Board - Color - 1.1.pdf](files/Zeta%20SBC%20-%20Board%20-%20Color%20-%201.1.pdf) (1030k) | Sergey Kiselev, Oct 9, 2012, 3:50 PM |
| [Zeta SBC - Board - Color - 1.2.pdf](files/Zeta%20SBC%20-%20Board%20-%20Color%20-%201.2.pdf) (1029k) | Sergey Kiselev, Oct 9, 2012, 3:50 PM |
| [Zeta SBC - Board - Color - 1.3.pdf](files/Zeta%20SBC%20-%20Board%20-%20Color%20-%201.3.pdf) (1039k) | Sergey Kiselev, Oct 9, 2012, 3:50 PM |
| [Zeta SBC - Gerber - 1.0.zip](files/Zeta%20SBC%20-%20Gerber%20-%201.0.zip) (262k) | Sergey Kiselev, Oct 9, 2012, 4:04 PM |
| [Zeta SBC - Gerber - 1.1.zip](files/Zeta%20SBC%20-%20Gerber%20-%201.1.zip) (268k) | Sergey Kiselev, Oct 9, 2012, 4:04 PM |
| [Zeta SBC - Gerber - 1.2.zip](files/Zeta%20SBC%20-%20Gerber%20-%201.2.zip) (268k) | Sergey Kiselev, Oct 9, 2012, 4:04 PM |
| [Zeta SBC - Gerber - 1.3.zip](files/Zeta%20SBC%20-%20Gerber%20-%201.3.zip) (271k) | Sergey Kiselev, Oct 9, 2012, 4:04 PM |
| [Zeta SBC - KiCAD - 1.0.zip](files/Zeta%20SBC%20-%20KiCAD%20-%201.0.zip) (209k) | Sergey Kiselev, Oct 9, 2012, 4:04 PM |
| [Zeta SBC - KiCAD - 1.1.zip](files/Zeta%20SBC%20-%20KiCAD%20-%201.1.zip) (216k) | Sergey Kiselev, Oct 9, 2012, 4:04 PM |
| [Zeta SBC - KiCAD - 1.2.zip](files/Zeta%20SBC%20-%20KiCAD%20-%201.2.zip) (222k) | Sergey Kiselev, Oct 9, 2012, 4:04 PM |
| [Zeta SBC - KiCAD - 1.3.zip](files/Zeta%20SBC%20-%20KiCAD%20-%201.3.zip) (225k) | Sergey Kiselev, Oct 9, 2012, 4:04 PM |
| [Zeta SBC - Schematics - BW - 1.0.pdf](files/Zeta%20SBC%20-%20Schematics%20-%20BW%20-%201.0.pdf) (226k) | Sergey Kiselev, Oct 9, 2012, 3:50 PM |
| [Zeta SBC - Schematics - Color - 1.0.pdf](files/Zeta%20SBC%20-%20Schematics%20-%20Color%20-%201.0.pdf) (223k) | Sergey Kiselev, Oct 9, 2012, 3:50 PM |
| [Zeta SBC - Schematics - Color - 1.3.pdf](files/Zeta%20SBC%20-%20Schematics%20-%20Color%20-%201.3.pdf) (227k) | Sergey Kiselev, Oct 9, 2012, 3:50 PM |
| [Zeta with ParPortProp - Perspective View.jpg](files/Zeta%20with%20ParPortProp%20-%20Perspective%20View.jpg) (190k) | Sergey Kiselev, Oct 9, 2012, 3:44 PM |
