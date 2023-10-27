## Introduction

Zeta SBC V2 is a redesigned version of [Zeta SBC](http://www.malinov.com/Home/sergeys-projects/zeta-sbc). Compared to the first version this version features updated MMU with four banks, each one of those banks can be mapped to any 16 KiB page in 1 MiB on-board memory. It adds Z80 CTC which is used for generating periodic interrupts and as a vectored interrupt controller for UART and PPI. The FDC is replaced with 37C65. Compared to FDC9266 used in Zeta SBC it integrates input/output buffers and floppy disk control latch. Additionally 37C65 FDC is easier to obtain than FDC9266. And lastly it is made using CMOS technology and more power efficient than FDC9266

## Pictures

### Complete Board

![Zeta SBC V2 - Assembled Board](files/Zeta%20SBC%20V2%20-%20Assembled%20Board.JPG)

### Zeta SBC with ParPortProp and a Floppy Drive

(FIXME: Picture shows Zeta SBC V1. Replace with Zeta SBC V2 when available.)
![Zeta SBC with ParPortProp](files/Zeta%20with%20ParPortProp%20-%20Perspective%20View.jpg)

# Specifications

Zeta SBC V2 features following components:

* Z80 CPU
* 16550 UART - for connecting a console
* 8255 PPI - can be used for attaching a ParPortProp board, a hard drive using PPIDE or controlling some external devices
* Z80 CTC - can be used to generate periodic interrupts, and as an interrupt controller for UART and PPI
* Western Digital WD37C65, SMC FDC37C65, or GoldStar GM82C765B floppy disk controller.
* 512 KiB of battery backed SRAM
* 512 KiB of flash memory
* RTC

Zeta SBC V2 is compact and easy to build:

* Footprint of an 3.5" floppy drive (100 mm x 170.18 mm) and PCB can be mounted under a 3.5" drive.
* Uses only through hole components.
* Assumes using commonly available 3.5" floppy drives (not many people have 5.25" drives and even less 8" ones). Although it should work with 5.25" drives too.
* Only 2 configuration jumpers.
* Easy to use flash memory instead of UV EPROM.
* PCB mounted connectors, no need to build cables.
* Uses widely available components
* An easy way to get a "taste" of CP/M era computing.

# Hardware Documentation

File downloads are at the bottom of this page.

## KiCad Design Files

[Zeta SBC V2 - KiCad - 2.0.zip](files/Zeta%20SBC%20V2%20-%20KiCad%20-%202.0.zip)

## Schematic

[Zeta SBC V2 - Schematic - Color - 2.0.pdf](files/Zeta%20SBC%20V2%20-%20Schematic%20-%20Color%20-%202.0.pdf)

### PCB Version 2.0

[Zeta SBC V2 - Board - Color - 2.0.pdf](files/Zeta%20SBC%20V2%20-%20Board%20-%20Color%20-%202.0.pdf)

[Zeta SBC V2 - Gerber - 2.0.zip](files/Zeta%20SBC%20V2%20-%20Gerber%20-%202.0.zip)

## Input/Output Ports

* 20h - 23h (aliases 24h - 27h) - CTC Registers
  - 20h: Channel 0
  - 21h: Channel 1
  - 22h: Channel 2
  - 23h: Channel 3
  - See **Interrupts** section for Zeta SBC V2 specific CTC implementation and programming notes
* 28h (aliases 29h - 2Fh) - FDC CCR Register
  - Write only
  - FIXME: Add detailed description
* 30h (aliases 32h, 34h, 36h) - FDC Main Status Register
* 31h (aliases 33h, 35h, 37h) - FDC Data Register
* 38h (aliases 39h - 3Fh)
  - Write - FDC Diginal Output Register (DOR), also known as latch.
    + FIXME: Add detailed description
  - Read - Pulse FDC's /DACK and TC control lines
    + This port should be read following FDC data transfer command (read, write, format, etc.) to properly terminate data transfer.
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
    + Bit 7 - Disk Changed (DC) output from floppy drive. This can be used by the OS to detect floppy disk change. In such case CP/M should be warm rebooted.
* 78h-7Bh (alias 7Ch-7Fh) - Memory page select registers.
  - Write only
  - 78h - MPGSEL_0 - Page select register for bank #0 (0000h - 3FFFh)
  - 79h - MPGSEL_1 - Page select register for bank #1 (4000h - 7FFFh)
  - 7Ah - MPGSEL_2 - Page select register for bank #2 (8000h - 0BFFFh)
  - 7Bh - MPGSEL_3 - Page select register for bank #3 (0C000h - 0FFFFh)
  - Note: While these registers implemented as 8-bit registers, only 7 lower bits are decoded on board. 6 of these are actually used by on board memory, which contains of 64 pages, 16 KiB each.
* 7Ch (aliases 7Dh-7Fh) - MPGENA - Enable memory paging
  - Bits 0:
    + 0 = Disable memory paging (default after reset). When memory paging is disabled the memory page 0 (lower 16 KiB of the Flash ROM) is mapped to all banks.
    + 1 = Enable memory paging. Make sure that memory page select registers are configured properly before enabling paging.
  - Bits 1-7 - unused

## Memory

Zeta SBC V2 features a 512 KiB Flash ROM, and 512 KiB SRAM. The Flash ROM is used for the boot loader, monitor, OS (CP/M and ZSDOS at this point), and ROM disk. The SRAM is battery-backed, and is used for applications and for a RAM disk.

### Memory Banks and Paging

The 64 KiB Z80 memory address space is divided into four 16 KiB memory banks:

* Bank #0 (0000h - 3FFFh
* Bank #1 (4000h - 7FFFh)
* Bank #2 (8000h - 0BFFFh)
* Bank #3 (0C000h - 0FFFFh)

The physical memory (512 KiB Flash ROM and 512 KiB SRAM) is divided into 16 KiB pages:

* Pages 0 - 31 are mapped to the Flash ROM: page #0 starts at ROM address 00000h, and page #31 ends at ROM address 7FFFFh.
* Pages 32 - 63 are mapped to the SRAM: page #32 starts at RAM address 00000h, and page #63 ends at RAM address 7FFFFh.

Page select registers are used to map physical memory pages to the banks in Z80 address space:

* MPGSEL_0 (78h) - Page select register for bank #0
* M PGSEL_1 (79h) - Page select register for bank #1
* M PGSEL_2 (7Ah) - Page select register for bank #2
* M PGSEL_3 (7Bh) - Page select register for bank #3

Following a power on or a hard reset the memory paging mechanism is disabled, and memory address lines MA19 - MA14 are pulled down. So that page #0 (ROM addresses 00000h to 03FFF) is mapped to all four banks. That page should contain a boot loader that (among other things) configures and enables memory paging. Once page select registers are configured properly the memory paging can be enabled by setting bit 1 of MPGENA (7Ch) register.

### Programming Notes

1. The content of page select registers is unknown after a power on or a reboot. These registers need to be initialized before enabling memory paging. During the initialization the page select register for bank #0 needs to be set to page #0. So that CPU continues to execute instructions from that page.
2. The page select registers are implemented as 8-bit registers. Only 7 lower bits are decoded by Zeta SBC V2 memory chip select logic, and only 6 lower bits are actually used to address the memory. For future compatibility it is recommended that two higher bits of page select registers will be set to

## Interrupts

Zeta SBC V2 uses CTC as the source of vectored interrupts. For interrupts to function properly Z80 needs to be set to **interrupt mode 2**.

* Channels 0 and 1 are chained together. So that channel 1 can be used to generate low-frequency periodic interrupts:
  - Channel's 0 CLK/TG input is connected to UART_CLK/2 signal (921.6 kHz frequency)
  - Channel's 1 CLK/TG input in connected to c hannel's 0 ZC/TO output
* Channels 2 and 3 are connected to UART and FDC interrupt outputs. They can be used to generate vectored interrupts for these controllers:
  - Channel's 2 CLK/TG input is connected to UART interrupt output
  - Channel's 3 CLK/TG input is connected to 8255 PPI port PC3. This port is used as the interrupt output in PPI modes 1 and 2.

### Programming CTC to Generate Periodic Interrupts

CTC can generate periodic interrupts by dividing CTC clock (921.6 kHz) using channels 0 and 1 configured in counter mode. The CTC clock is connected to the trigger input of channel 0, and the ZC (zero count) output of channel 0 is connected the trigger input of channel 1. So that channel 0 will divide the clock, and the resulting signal will be divided further using channel 1.

In this example channel 0 is programmed with time constant of 256, so it will divide the input clock by 256, resulting in 3.6 kHz pulses. The channel 1 is programmed with down counter of 240, and will divide 3.6 kHz clock by 240, resulting in 15 Hz signal. That channel is also programmed to generate an interrupt every time counter reaches 0.

* Output `01000111 `to the channel 0. Configure the channel in the counter mode.
* Output `00000000&#xA0;`to the channel 0. Set the time constant to 256.
* Output `11000111 `to the channel 1. Configure the channel in the counter mode and enable interrupt when counter reaches 0.
* Output `11110000` to the channel 1. Set the time constant to 240, so that the interrupt will be generated every 1/15 of a second.
* Output `VVVVV000&#xA0;`to the channel 0. Set bits 7-3 of the interrupt vector. Bits 15-8 are set to the value of I register, bits 2 and 1 are set to the CTC channel number that caused the interrupt. Bit 0 is always 0. Note that each interrupt vector takes 2 bytes of memory and it should start on an even address.

### Programming CTC as an Interrupt Controller

CTC can be used as interrupt controller for UART and 8255 PPI using channels 2 and 3 respectively. In this case a CTC channel needs to be programmed for counter mode operation with time constant of 1. So that the first transition on CLK/TG input will result in counter going to 0 and CTC generating an interrupt.

* Output `110L0111` to the selected channel. This configures the channel in the counter mode with interrupts enabled. Bit 4 (L) sets the triggering edge: 0 - falling edge; 1 - rising edge.
* Output `00000001` to the selected channel. This loads value 1 to the time constant, so that an interrupt will be generated after detecting the first edge on the trigger input.
* Output `VVVVV000&#xA0;`to the channel 0. This sets bits 7-3 of the interrupt vector. Bits 15-8 are set to the I register, bits 2 and 1 are set to the CTC channel number that caused the interrupt. Bit 0 is always 0. Note that each interrupt vector takes 2 bytes of memory and it should start on an even address.

## Real Time Clock

Zeta SBC V2 includes a Maxim DS1302 RTC chip for timekeeping. It uses a CR2032 battery for power backup. The DS1302 has a 3-wire serial interface, and it is programmed through the RTC register (70h) using bit-banging. See Input/Output Ports section for the RTC register description. Please refer to [DS1302 datasheet](http://datasheets.maximintegrated.com/en/ds/DS1302.pdf) for programming information, and to the RomWBW (dsrtc.asm) for an RTC interface implementation.

## Jumpers and Connectors

### Jumper JP1 - CONFIG

JP1 is a software configuration jumper. It can be read by software using RTC port (70h) bit 6. This jumper is used by the RomWBW firmware with the ParPortProp support to configure the console device: it will use UART when this jumper is installed, and ParPortProp / VGA terminal when the jumper is not installed.

### Jumper JP2 - PIN25_GND/VCC

JP2 connects pin 25 of the parallel port P4 to either GND or Vcc (+5). Note that pin 1 is the pin that is closer to the parallel connector.

Warning: If JP2 is set incorrectly, it is possible to create a short circuit of the 5 Volt power supply.

| **Jumper Position** | **Description** |
| :------------------ | :-------------- |
| 1-2 | P4 pin 25 is connected to the ground |
| 2-3 | P4 pin 25 is connected to Vcc. Use this position with PPIDE, make sure to set jumper K1 on PPIDE to position 2-3. Please refer to [PPIDE documentation](https://sites.google.com/w/file/28373213/ppide-Install.txt) for more information. |
| **no jumper*** | P4 pin 25 is left open |

\* default

### Connector P1 - POWER

Connect regulated +5V power supply to this connector.

| Pin | Description |
| :-- | :---------- |
| tip (the inner contact) | Positive terminal - +5V |
| barrel / sleeve | Negative terminal - ground |

### Connector P2 - RESET

P2 is a connector for an external reset button.

### Connector P3 - SERIAL

P3 is the serial port connector. It is normally used for connecting a console or terminal. P3 uses pinout similar to that of IBM AT serial port (with some signals missing). Use a null modem cable to connect to a PC.

| **Pin Number** | **Signal Name** | **Description and Notes** |
| :------------- | :-------------- | :------------------------ |
| 1 | DCD | Carrier Detect; Not used - Not connected on the SBC |
| **2** | **RX** | **Receive Data; Input to SBC** |
| **3** | **TX** | **Transmit Data; Output from SBC** |
| 4 | DTR | Data Terminal Ready;Not used - Not connected on the SBC |
| **5** | **Signal Ground** | **Connected to the SBC GND signal** |
| 6 | DSR | Data Set Ready;Not used - Not connected on the SBC |
| **7** | **RTS** | **Request to Send; Output from SBC** |
| **8** | **CTS** | **Clear to Send; Input to SBC** |
| 9 | RI | Ring Indicator;Not used - Not connected on the SBC |
| **Shield** | **DE9 Shield** | **Connected to the SBC GND signal** |

### Connector P4 - PARALLEL

P4 is the parallel port connector. It is connected directly to the 8255 PPI and can be used for attaching, a ParPortProp board, an IDE hard disk using the PPIDE mini board, or for controlling external devices (e.g. printer, watering system), or for extending the SBC (e.g. connecting an LCD display and a keyboard). The pinout of P4 is the same as in other N8VEM boards (SBC V1, SBC V2, SBC-188).

| **Pin Number** | **Description** | **Pin Number** | **Description** | **Pin Number** | **Description** | **Pin Number** | **Description** |
| :------------- | :-------------- | :------------- | :-------------- | :------------- | :-------------- | :------------- | :-------------- |
| 1 | PC0 | 9 | PC4 | 17 | PB7 | 25 | GND or VCC (see JP2) |
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

**Warning P6 connector's key is reversed compared to Zeta SBC V 1.x. Please pay attention when upgrading from older boards. The polarity marking on the silkscreen is correct.**

## Bill of Materials (BOM)

### BOM Notes

Disclaimer: I did my best to make sure that components listed in this BOM will be compatible with Zeta SBC V2. Obviously I didn't order all of components listed here, and I was not able to actually verify that they will work. Please make sure to double check specifications on manufacturer's and seller's web site before ordering. Please let me know if you found any problems or incompatibilities.

Many components have multiple part numbers listed in BOM. There are some differences between various part numbers, such as:

* Different manufacturer. For example Texas Instruments vs. National Semiconductor for IC. Usually ICs built using the same technology will be 100% compatible. For some other components, for example connectors, sockets, or capacitors, it could be some difference in the quality. It is likely to get a better quality connector from TE (was AMP/Tyco) than from some obscure manufacturer (e.g. components sold under Jameco ValuePro brand).
* Specification differences
  - IC built using different different technologies (CMOS, TTL, NMOS) will have different specifications, and you might prefer to use certain IC family.
  - Difference in IC frequency or speed rating, especially for CPU, PPI, and memory.
  - Mechanical differences, especially for switches. Pick whatever suits best in your enclosure.
  - Some other minor differences. For example: RoHS or Pb-free vs. regular components; thickness of gold plating on connectors; frequency stability of oscillators and crystals.
* Price differences
  - For some reason some components are priced much higher than other otherwise similar parts.
  - One extreme example would be 512 KiB SRAM chips sold by Jameco (157358 and 242448) for almost $19 each, while AS6C4008-55PCN part sold by Mouser costs less than $5.
  - Some eBay sellers ask premium price for components because of their perceived uniqueness (keywords: vintage, rare, NOS, collectible), or special packaging (e.g. pink ceramic vs. plastic, gold plating).

If unsure what to order, read specifications on seller's and manufacturer's web sites. Also please read Replacement Notes below. Finally, consult people on [N8VEM news group](http://groups.google.com/group/n8vem).

## BOM

| **Component type** | **Reference** | **Description** | **Quantity** | **Possible sources and notes** |
| :----------------- | :------------ | :-------------- | :----------- | :----------------------------- |
| PCB |  | Zeta SBC V2 PCB Version 2.0 | 1 | Order from Sergey |
| Battery Holder | BT1 | CR2032 batter holder, 20 mm lead spacing | 1 | Mouser [122-2420-GR](http://www.mouser.com/ProductDetail/Eagle-Plastic-Devices/122-2420-GR/?qs=sGAEpiMZZMupuRtfu7GC%252beZOrkV%252bKN9%2FAB%252buxIS5wOM%3D "Click to view additional information on this product."),[122-2620-GR](http://www.mouser.com/ProductDetail/Eagle-Plastic-Devices/122-2620-GR/?qs=sGAEpiMZZMupuRtfu7GC%252bdT30ZRn29lxdufOO0Kb9bU%3D "Click to view additional information on this product.");Jameco [355434](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_355434_-1) |
| Capacitor | C1 - C24 | 0.1 uF ceramic, 5.08 mm lead spacing | 24 | Mouser [810-FK28X7R1H104K](http://www.mouser.com/search/refine.aspx?Keyword=810-FK28X7R1H104K),[80-C323C104K5R](http://www.mouser.com/ProductDetail/Kemet/C323C104K5R5TA/?qs=sGAEpiMZZMuAYrNc52CMZJc2YQhHPlYVWR1uyzMGvKQ%3D); Jameco [25523](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_25523_-1) |
| Capacitor | C25 | 47 uF, 6.3 V electrolytic | 1 | Mouser [667-ECA-1HHG470](http://www.mouser.com/ProductDetail/Panasonic-Electronic-Components/ECA-1HHG470/?qs=sGAEpiMZZMtZ1n0r9vR22be70OeCKE1EbiDEkso9tdM%3D "Click to view additional information on this product.");Jameco [31114](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_31114_-1) |
| Capacitor | C26 | 10 uF ceramic, 5.08 mm lead spacing | 1 | Mouser [810-FK24X5R1C106K](http://www.mouser.com/search/refine.aspx?Keyword=810-FK24X5R1C106K) Note: Can be replaced with tantalum or electrolytic capacitors |
| Diode | D1 | 1N4148 | 1 | Mouser [512-1N4148](http://www.mouser.com/ProductDetail/Fairchild-Semiconductor/1N4148/?qs=sGAEpiMZZMutXGli8Ay4kC4Bz7vbB60woGEFXf9TQ98%3D "Click to view additional information on this product."),[771-1N4148-T/R](http://www.mouser.com/ProductDetail/NXP-Semiconductors/1N4148113/?qs=sGAEpiMZZMutXGli8Ay4kE3wRMDwmh%2F%252bGmXBTkVQdt4%3D "Click to view additional information on this product.");Jameco [36038](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_36038_-1),[179215](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_179215_-1) |
| Diode | D2, D3 | Bi-level LED indicator | 1 | Mouser [696-SSF-LXH240GYD](http://www.mouser.com/ProductDetail/Lumex/SSF-LXH240GYD/?qs=sGAEpiMZZMurHQmwyojo5EtA%252bKO7aifq%2F8Iq2xqPbQI%3D "Click to view additional information on this product."); Jameco: Search for uni-color bi-level LED |
| Standoff | HOLE1, HOLE2, HOLE3, HOLE4 | Standoff, M3 male / female, 20 mm | 4 | Mouser [534-24317](http://www.mouser.com/ProductDetail/Keystone-Electronics/24317/?qs=sGAEpiMZZMs6x5FGDTpfsIdmmWiq5V9U4wJ1XZo48xk%3D "Click to view additional information on this product."),[534-25505](http://www.mouser.com/ProductDetail/Keystone-Electronics/25505/?qs=sGAEpiMZZMs6x5FGDTpfsIdmmWiq5V9Utxx9C%2Fw3Z7E%3D "Click to view additional information on this product."),[855-R30-3012002](http://www.mouser.com/ProductDetail/Harwin/R30-3012002/?qs=sGAEpiMZZMtzcnMBgC2bs6Id%2FK%2FNPiw4hN1Xmhg%2FQVw%3D "Click to view additional information on this product.") Note: The length of male end of these standoffs is 8 mm. It is too long for some floppy disk drives (you'll notice that standoff doesn't go completely inside the floppy drive mount hole). In this case cut a few millimeters using a file or a fine saw. |
| Screw | HOLE1, HOLE2, HOLE3, HOLE4 | Screw, M3, 6 mm | 4 | Use regular 3 mm floppy or CD-ROM drive mounting screws. Mouser [534-29311](http://www.mouser.com/ProductDetail/Keystone-Electronics/29311/?qs=sGAEpiMZZMs6x5FGDTpfsIdmmWiq5V9UXRwmMEDRMDY%3D) |
| Connector | JP1, P2 | 2x1 pin header | 2 | Mouser [649-78229-102HLF](http://www.mouser.com/ProductDetail/FCI/78229-102HLF/?qs=sGAEpiMZZMtsLRyDR9nM1%252b9K9ogxAkAjs2jx2M%252b94WE%3D "Click to view additional information on this product.");Jameco [108338](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_108338_-1) |
| Connector | JP2 | 3x1 pin header | 1 | Mouser [649-69190-103HLF](http://www.mouser.com/ProductDetail/FCI/69190-103HLF/?qs=sGAEpiMZZMvlX3nhDDO4AIYfP1TbgJhjYISz3bCP%2Fwo%3D "Click to view additional information on this product."),[649-78229-103HLF](http://www.mouser.com/ProductDetail/FCI/78229-103HLF/?qs=sGAEpiMZZMtsLRyDR9nM14Vjyw4ze%252bjtWzL%2FZN0BySE%3D "Click to view additional information on this product.");Jameco [109576](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_109576_-1) |
| Connector | P1 | DC jack | 1 | Mouser [806-KLDX-0202-A](http://www.mouser.com/ProductDetail/Kycon/KLDX-0202-A/?qs=sGAEpiMZZMu2f9RNbWupYrp4fVeNia8SgJaG%252bI5Hr1k%3D "Click to view additional information on this product.");Jameco [101178](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_101178_-1) |
| Connector | P3 | DE9M, right angle PCB mount | 1 | Mouser [806-K22X-E9P-N](http://www.mouser.com/ProductDetail/Kycon/K22X-E9P-N/?qs=sGAEpiMZZMu857ZbtCGHt0PbUrjjd%2FNBm0naypBlx9c%3D "Click to view additional information on this product."),[806-K22X-E9P-N-99](http://www.mouser.com/ProductDetail/Kycon/K22X-E9P-N-99/?qs=sGAEpiMZZMu857ZbtCGHt%2FwNqbkdXVI1Hsm1P%252bducYc%3D "Click to view additional information on this product.") (teal color),[571-7478404](http://www.mouser.com/ProductDetail/TE-Connectivity-AMP/747840-4/?qs=sGAEpiMZZMu857ZbtCGHtwpRvUYYjR%2Fb0tNi%2FPWGuJ4%3D "Click to view additional information on this product.");Jameco [104943](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_104943_-1),[614459](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_614459_-1),[614432](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_614432_-1); |
| Connector | P4 | 13x2 pin header | 1 | Mouser [649-68602-126HLF](http://www.mouser.com/ProductDetail/FCI/68602-126HLF/?qs=sGAEpiMZZMtsLRyDR9nM1%252bmbmmVUI0dAYWKlImNZbew%3D),[649-77313-824-26LF](http://www.mouser.com/ProductDetail/FCI/77313-824-26LF/?qs=sGAEpiMZZMtsLRyDR9nM14Vjyw4ze%252bjtilYVPfgiHws%3D);Jameco [53495](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_53495_-1) Note: don't use shrouded connector, as it will interfere with the standoff and other components. |
| Connector | P5 | 17x2 pin header shrouded | 1 | Mouser [517-30334-6002](http://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/30334-6002HB/?qs=sGAEpiMZZMs%252bGHln7q6pmwu5ra4CY41if6I7inkHkkA%3d "Click to view additional information on this product."),[571-1033087](http://www.mouser.com/ProductDetail/TE-Connectivity/103308-7/?qs=sGAEpiMZZMs%252bGHln7q6pm48SVpWlpfsEybwRttC6%252baA%3d "Click to view additional information on this product."),[571-5103308-7](http://www.mouser.com/ProductDetail/TE-Connectivity/5103308-7/?qs=sGAEpiMZZMs%252bGHln7q6pm%252bE9wskmeR%2fSsajGI7pSzh4%3d "Click to view additional information on this product.");Jameco [68583](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_68583_-1),[753547](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_753547_-1) |
| Connector | P6 | 2 pin header with friction lock | 1 | Mouser [571-6404562](http://www.mouser.com/ProductDetail/TE-Connectivity-AMP/640456-2/?qs=sGAEpiMZZMtsLRyDR9nM16DGeeXFND9gHLFcjtDJkhM%3D),[571-3-641126-2](http://www.mouser.com/ProductDetail/TE-Connectivity-AMP/3-641126-2/?qs=sGAEpiMZZMtsLRyDR9nM18mJd%252baLxMG9uKUwnVJVJ8s%3D),[571-3-641215-2](http://www.mouser.com/ProductDetail/TE-Connectivity-AMP/3-641215-2/?qs=sGAEpiMZZMtsLRyDR9nM16DGeeXFND9gdDlMjBZrVXQ%3D);Jameco [232266](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_232266_-1),[613931](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_613931_-1); Corresponding female connector: Mouser [571-770602-2](http://www.mouser.com/ProductDetail/TE-Connectivity-AMP/770602-2/?qs=sGAEpiMZZMtsLRyDR9nM168vwp4yW2ZSGNK4xeaBpHA%3D);Jameco [234798](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_234798_-1)Contacts (2 contacts needed):Mouser [571-770666-1](http://www.mouser.com/ProductDetail/TE-Connectivity-AMP/770666-1/?qs=sGAEpiMZZMtsLRyDR9nM18mJd%252baLxMG9GrlfGo%252bW7aE%3D);Jameco [234923](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_234923_-1),[736501](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_736501_-1); It is recommended to use a polarized header to avoid incorrect power polarity. |
| Resistor | R1 | 10 Ohm, 1/4 W | 1 | Mouser [291-10-RC](http://www.mouser.com/ProductDetail/Xicon/291-10-RC/?qs=sGAEpiMZZMu61qfTUdNhG5WVxMYmJR0O1OUR1xbHmxs%3D);Jameco [690380](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_690380_-1) |
| Resistor | R2 | 10 kOhm, 1/4 W | 1 | Mouser [291-10K-RC](http://www.mouser.com/ProductDetail/Xicon/291-10K-RC/?qs=sGAEpiMZZMu61qfTUdNhG6xwTrVwTvbz8PPav3aExs8%3D); Jameco [691104](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_691104_-1) |
| Resistor | R3, R4 | 470 Ohm, 1/4 W | 2 | Mouser [291-470-RC](http://www.mouser.com/ProductDetail/Xicon/291-470-RC/?qs=sGAEpiMZZMu61qfTUdNhG1AdbDi3ermZfsjMZ8nKiDY%3D); Jameco [690785](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_690785_-1) |
| Resistor Array | RR1, RR2 | 1 kOhm, 6 pin, bussed resistor array | 2 | Mouser [264-1.0K-RC](http://www.mouser.com/ProductDetail/Xicon/264-10K-RC/?qs=sGAEpiMZZMvrmc6UYKmaNQbJ%252b29QTxaEngMB%2FdVaAdM%3D "Click to view additional information on this product."),[652-4306R-1LF-1K](http://www.mouser.com/ProductDetail/Bourns/4306R-101-102LF/?qs=sGAEpiMZZMvrmc6UYKmaNTNUNwWuH088chgRi4yNveI%3D "Click to view additional information on this product.") Note: When using CMOS U11, RR2 can have a higher value, for example 4.7k. This will reduce the power consumption. |
| Resistor Array | RR3, RR4 | 4.7 kOhm, 6 pin, bussed resistor array | 2 | Mouser [264-4.7K-RC](http://www.mouser.com/ProductDetail/Xicon/264-47K-RC/?qs=sGAEpiMZZMvrmc6UYKmaNVNDE5UWkgN%2FsgYW0PIGqes%3D "Click to view additional information on this product."),[652-4306R-1LF-4.7K](http://www.mouser.com/ProductDetail/Bourns/4306R-101-472LF/?qs=sGAEpiMZZMvrmc6UYKmaNWgIZ6biHU4EEgaZTof5r6w%3D "Click to view additional information on this product.") |
| Switch | SW1 | Tactile switch, right angle | 1 | Mouser [653-B3F-3100](http://www.mouser.com/ProductDetail/Omron-Electronics/B3F-3100/?qs=sGAEpiMZZMsgGjVA3toVBC93MDPUOLghd%252bGul%252bd9MzM%3d "Click to view additional information on this product."),[653-B3F-3152](http://www.mouser.com/ProductDetail/Omron-Electronics/B3F-3152/?qs=sGAEpiMZZMsgGjVA3toVBLOYoGzF1EI%252bcD5nMscmqSU%3d "Click to view additional information on this product."),[706-95C06A2RAT](http://www.mouser.com/ProductDetail/Grayhill/95C06A2RAT/?qs=sGAEpiMZZMsgGjVA3toVBGztKQtvElzogNtUxy25yuk%3d "Click to view additional information on this product."),[706-95C06C2RAT](http://www.mouser.com/ProductDetail/Grayhill/95C06C2RAT/?qs=sGAEpiMZZMsgGjVA3toVBGztKQtvElzoxqE4Q1H5TNc%3d "Click to view additional information on this product."),[706-95C06F2RAT](http://www.mouser.com/ProductDetail/Grayhill/95C06F2RAT/?qs=sGAEpiMZZMsgGjVA3toVBGztKQtvElzoEUXifV0kpgg%3d "Click to view additional information on this product.")Note: Switches can have different actuator length. You might want to select the switch according your own preferences, for example the enclosure type you want to use, and whatever you want the reset button to stick out of the enclosure or to stay hidden inside. Jameco [1953575](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_1953575_-1) |
| IC | U1 | Z80 CPU, CMOS, 40 pin DIP - Z84C00xxPEG | 1 | Mouser [692-Z84C0010PEG](http://www.mouser.com/ProductDetail/ZiLOG/Z84C0010PEG/?qs=sGAEpiMZZMvu0Nwh4cA1wSoSQ2enekUq2IMsKtAiEbo%3D),[692-Z84C0008PEG](http://www.mouser.com/ProductDetail/ZiLOG/Z84C0008PEG/?qs=sGAEpiMZZMvu0Nwh4cA1wWtRoPcQBaz3A%252bL%2FQ9ovAB8%3D); Jameco [35705](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_35705_-1),[35781](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_35781_-135781) Frequency of U17 (CPU clock) oscillator should be less or equal to CPU frequency. 8MHz CPU recommended for 1.44 MB floppy disks support. |
| IC | U2 | 512 KiB flash, 32 pin DIP - 39SF040,29F040, 29C040 | 1 | Mouser [804-39SF0407CPHE](http://www.mouser.com/ProductDetail/Microchip-Technology/SST39SF040-70-4C-PHE/?qs=sGAEpiMZZMtI%252bQ06EiAoGwr0W47sj3OOZ45%252baf2mLJ4%3D "Click to view additional information on this product."); Jameco [242667](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_242667_-1) |
| IC | U3 | 512 KiB SRAM, 32 pin DIP -AS6C4008-55PCN | 1 | Mouser [913-AS6C4008-55PCN](http://www.mouser.com/ProductDetail/Alliance-Memory/AS6C4008-55PCN/?qs=sGAEpiMZZMt9mBA6nIyysPeGHDtAZQ%252bHv1ODopTep98%3D) Note: Jameco 242448 and 157358 (BS62LV4006P) should work too, but they are way too expensive |
| IC | U4 | 16550 UART | 1 | Mouser [926-PC16550DN/NOPB](http://www.mouser.com/ProductDetail/Texas-Instruments/PC16550DN-NOPB/?qs=sGAEpiMZZMuyKkoWRCJ2WLeElKNr3DluUI5Xg6bwOh4%3d); Jameco [288809](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_288809_-1) |
| IC | U5 | 8255 PPI | 1 | Mouser [968-CP82C55AZ](http://www.mouser.com/ProductDetail/Intersil/CP82C55AZ/?qs=cbl4%252bYHJGOF3%2FjEgaAvGRe5K%2FILMXjQ3),[968-CP82C55A](http://www.mouser.com/ProductDetail/Intersil/CP82C55A/?qs=B4b5rvZIvWUoKcRPBZOAqTe8YvZ7Q5In); Jameco [52417](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_52417_-1) Unicorn Electronics (order 82C55) |
| IC | U6 | FDC, 40 pin DIP WD37C65, FDC37C65, GM82C765 | 1 | Buy from eBay |
| IC | U7 | Z80 CTC, CMOS, 28 pin DIP -Z84C30xxPEG | 1 | Mouser [692-Z84C3010PEG](http://www.mouser.com/ProductDetail/ZiLOG/Z84C3010PEG/?qs=sGAEpiMZZMtp5ziQ9mm%252bAlDnLybnUSNF),[692-Z84C3008PEG](http://www.mouser.com/ProductDetail/ZiLOG/Z84C3008PEG/?qs=sGAEpiMZZMsn4IaorHFpML59rb7vgZ39); Jameco [35609](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_35609_-1) |
| IC | U8, U9 | 74LS670 | 2 | Mouser [595-SN74LS670N](http://www.mouser.com/search/refine.aspx?Keyword=595-SN74LS670N),[771-HCT670N652](http://www.mouser.com/search/refine.aspx?Keyword=771-HCT670N652); Jameco [47976](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_47976_-1) Unicorn Electronics 74LS670 |
| IC | U10 | 74LS174 | 1 | Mouser [595-SN74ALS174N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74ALS174N/?qs=sGAEpiMZZMvxP%252bvr8KwMwH1qxRiYd9fqotp0hrbNkvI%3D),[595-SN74LS174N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74LS174N/?qs=sGAEpiMZZMvxP%252bvr8KwMwOIDaP0%252beD%2FyRsSdiADfoLM%3D),[595-SN74AHCT174N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT174N/?qs=sGAEpiMZZMvxP%252bvr8KwMwH1qxRiYd9fqkE7X46My71M%3D); Unicorn Electronics; Jameco [46931](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_46931_-1) |
| IC | U11 | 74ALS139 | 1 | Mouser [595-SN74ALS139N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74ALS139N/?qs=sGAEpiMZZMtxONTBFIcRfq4mebfZO%252bELhxGgXnQWC8c%3D),[595-SN74LS139AN](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74LS139AN/?qs=sGAEpiMZZMtxONTBFIcRfpKvrGTByBdi%2FBZhV6RAyCA%3D),[595-CD74ACT139E](http://www.mouser.com/ProductDetail/Texas-Instruments/CD74ACT139E/?qs=sGAEpiMZZMtxONTBFIcRfsQCBiNmETR9yYy7yqk6Oio%3D),[595-SN74AHCT139N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT139N/?qs=sGAEpiMZZMtxONTBFIcRfsQCBiNmETR9s6YW4lCucrQ%3D); Unicorn Electronics; Jameco [46623](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_46623_-1),[301268](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_301268_-1) |
| IC | U12 | 74LS138 | 1 | Mouser [595-SN74ALS138AN](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74ALS138AN/?qs=sGAEpiMZZMtxONTBFIcRfgMIbQHDmxevHm7M5LBU91I%3D),[595-SN74LS138N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74LS138N/?qs=sGAEpiMZZMtxONTBFIcRfpKvrGTByBdiQjlbb3Ynr4s%3D),[595-SN74AHCT138N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT138N/?qs=sGAEpiMZZMtxONTBFIcRfsQCBiNmETR9UG1XXuubiis%3D); Unicorn Electronics; Jameco [46607](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_46607_-1),[301233](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_301233_-1),[44927](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_44927_-1) |
| IC | U13 | 74LS125 | 1 | Mouser [595-SN74LS125AN](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74LS125AN/?qs=sGAEpiMZZMuiiWkaIwCK2WAncryyStC7ZVuQLUtSxbI%3D),[595-SN74AHCT125N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT125N/?qs=sGAEpiMZZMuiiWkaIwCK2YBcf8bvyFlOxbSCg1DZEdI%3D); Unicorn Electronics; Jameco [46501](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_46501_-1) |
| IC | U14 | 74LS74 | 1 | Mouser [595-SN74ALS74AN](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74ALS74AN/?qs=sGAEpiMZZMvxP%252bvr8KwMwD64K6n%252b0blWYVcQejy%2Fn2o%3D),[595-SN74AHCT74N](http://www.mouser.com/search/refine.aspx?Keyword=595-SN74AHCT74N); Jameco [48004](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_48004_-1),[295726](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_295726_-1),[45137](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_45137_-1) Unicorn Electronics 74ALS74, 74AHCT74 |
| IC | U15 | 74LS32 | 1 | Mouser [595-SN74ALS32N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74ALS32N/?qs=sGAEpiMZZMtMa9lbYwD6ZFfNaxHsgUwaIDUbKItpOSQ%3D),[595-SN74LS32N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74LS32N/?qs=sGAEpiMZZMtMa9lbYwD6ZOuZLcSXNpUacHuLMioAEnk%3D),[595-SN74ACT32N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74ACT32N/?qs=sGAEpiMZZMtMa9lbYwD6ZHl%252bb36l%252bC4R5ep%252b6HLRK5U%3d),[595-CD74ACT32E](http://www.mouser.com/ProductDetail/Texas-Instruments/CD74ACT32E/?qs=sGAEpiMZZMtMa9lbYwD6ZOqMILV%2fSzgW%252bsQ3Heghbw0%3d); Unicorn Electronics; Jameco [47466](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_47466_-1),[295515](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_295515_-1) |
| IC | U16 | 74LS14 | 1 | Mouser [595-SN74LS14N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74LS14N/?qs=sGAEpiMZZMuyBeSSR239Ias%252b1yN%2FIiBNAdJP0U6%2Fu9k%3D),[595-SN74AHCT14N](http://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT14N/?qs=sGAEpiMZZMuyBeSSR239Ias%252b1yN%2FIiBNVP9ThiduLa4%3D); Unicorn Electronics; Jameco [46640](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_46640_-1),[295460](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_295460_-1),[44935](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_44935_-1) |
| IC | U17 | CPU clock oscillator, full can | 1 | See frequency selection note for U1. 4 MHz: Mouser [815-ACO-4-EK](http://www.mouser.com/ProductDetail/ABRACON/ACO-4000MHZ-EK/?qs=sGAEpiMZZMt8zWNA7msRCufK6FojpZgBkZbpC3y2DKw%3D),[520-TCF400-X](http://www.mouser.com/ProductDetail/ECS/ECS-100AX-40/?qs=sGAEpiMZZMt8zWNA7msRCkZF6o3VgKlS%252bNJe%252bsVHAhg%3D);Jameco [27967](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_27967_-1) 6 MHz: Mouser [520-TCF600-X](http://www.mouser.com/ProductDetail/ECS/ECS-100AX-60/?qs=sGAEpiMZZMt8zWNA7msRCkZF6o3VgKlSVVceCglATlo%3D) 8 MHz: Mouser [815-ACO-8-EK](http://www.mouser.com/ProductDetail/ABRACON/ACO-8000MHZ-EK/?qs=sGAEpiMZZMt8zWNA7msRCufK6FojpZgBol2LWy2yIwI%3D),[520-TCF800-X](http://www.mouser.com/ProductDetail/ECS/ECS-100AX-80/?qs=sGAEpiMZZMt8zWNA7msRCkZF6o3VgKlSdZ7QUqFOCa0%3D);Jameco [27991](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_27991_-1) 10 MHz: Mouser [815-ACO-10-EK](http://www.mouser.com/ProductDetail/ABRACON/ACO-10000MHZ-EK/?qs=sGAEpiMZZMt8zWNA7msRCufK6FojpZgBI8%252bDSKO898Q%3D),[520-TCF1000-X](http://www.mouser.com/ProductDetail/ECS/ECS-100AX-100/?qs=sGAEpiMZZMt8zWNA7msRCkZF6o3VgKlSWiBx3iH%252buXU%3D);Jameco [27887](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_27887_-1) 20 MHz: Mouser [815-ACO-20-EK](http://www.mouser.com/ProductDetail/ABRACON/ACO-20000MHZ-EK/?qs=sGAEpiMZZMt8zWNA7msRCufK6FojpZgBfQRL%252bhz7SWY%3D),[520-TCF2000-X](http://www.mouser.com/ProductDetail/ECS/ECS-100AX-200/?qs=sGAEpiMZZMt8zWNA7msRCkZF6o3VgKlSDgSisz37dM4%3D);Jameco [27932](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_27932_-1) |
| IC | U18 | 1.8432 MHz oscillator, full can | 1 | Mouser [520-TCF184-X](http://www.mouser.com/ProductDetail/ECS/ECS-100AX-18432/?qs=sGAEpiMZZMt8zWNA7msRCkZF6o3VgKlSBPpGLyq2pks%3D); Jameco [27879](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_27879_-1) |
| IC | U19 | 16 MHz oscillator, full can | 1 | Mouser [520-TCF1600-X](http://www.mouser.com/ProductDetail/ECS/ECS-100AX-160/?qs=sGAEpiMZZMt8zWNA7msRCkZF6o3VgKlScoRySUymIsQ%3d),[815-ACO-16-EK](http://www.mouser.com/ProductDetail/ABRACON/ACO-16000MHZ-EK/?qs=sGAEpiMZZMt8zWNA7msRCufK6FojpZgBy%252bhs2PoDreA%3d) |
| IC | U20 | MAX202 | 1 | Mouser [595-TRS202ECN](http://www.mouser.com/ProductDetail/Texas-Instruments/TRS202ECN/?qs=sGAEpiMZZMtnIqnDeWcRHWI38aDrBTNBLAGTpxcqmuc%3D),[701-SP202ECP-L](http://www.mouser.com/ProductDetail/Exar/SP202ECP-L/?qs=sGAEpiMZZMtnIqnDeWcRHSgmUQC5j8NkoHNGApCEA9Y%3D),[700-MAX202CPE](http://www.mouser.com/ProductDetail/Maxim-Integrated-Products/MAX202CPE+/?qs=sGAEpiMZZMtnIqnDeWcRHUtumypDpQDCpJdkfz6bbNk%3D),[700-MAX232ACP](http://www.mouser.com/ProductDetail/Maxim-Integrated-Products/MAX232ACPE+/?qs=sGAEpiMZZMtnIqnDeWcRHUtumypDpQDCv4cSYmApFFc%3D); Jameco [1800552](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_1800552_-1),[142535](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_142535_-1) |
| IC | U21 | DS1302 | 1 | Mouser [700-DS1302](http://www.mouser.com/ProductDetail/Maxim-Integrated-Products/DS1302+/?qs=sGAEpiMZZMvOtLZKYNhBPfvFGMWHxUVD%2Ffq1bsN5Huo%3D),[700-DS1302N](http://www.mouser.com/ProductDetail/Maxim-Integrated-Products/DS1302N+/?qs=sGAEpiMZZMvOtLZKYNhBPfvFGMWHxUVDqtwoJwAsIxs%3D); Jameco [176778](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_176778_-1),[780481](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_780481_-1) |
| IC | U22 | DS1210 | 1 | Mouser [700-DS1210](http://www.mouser.com/ProductDetail/Maxim-Integrated-Products/DS1210+/?qs=sGAEpiMZZMutXGli8Ay4kC27Vf1CC6GrOwlPIFnsd9g%3D); Jameco [114198](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_114198_-1) |
| IC Socket | U1, U4 - U6 | 40 pin 600 mil DIP socket | 4 | Mouser [517-4840-6000-CP](http://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/4840-6000-CP/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXo7HrzikVwIY8%3D),[649-DILB40P223TLF](http://www.mouser.com/ProductDetail/FCI/DILB40P-223TLF/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tnWBa37eU7kEvItX7WAak1Y%3D);Jameco [41111](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_41111_-1) |
| IC Socket | U2, U3 | 32 pin 600 mil DIP socket | 2 | Mouser [517-4832-6000-CP](http://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/4832-6000-CP/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXooeQG9KGDPHw%3D),[649-DILB32P223TL](http://www.mouser.com/ProductDetail/FCI/DILB32P223TLF/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tuCWXqks4O6emg1jqvuxPfs%3D);Jameco [112301](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_112301_-1) |
| IC Socket | U7 | 28 pin 600 mil DIP socket | 1 | Mouser [517-4828-6000-CP](http://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/4828-6000-CP/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXoFUUv0bvk4oI%3D),[649-DILB28P223TLF](http://www.mouser.com/ProductDetail/FCI/DILB28P-223TLF/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tnWBa37eU7kELM2y4cpXfjk%3D) |
| IC Socket | U8 - U12, U24 | 16 pin 300 mil DIP socket | 6 | Mouser [517-4816-3000-CP](http://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/4816-3000-CP/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXo2MaLGaLrmns%3D),[649-DILB16P-223TLF](http://www.mouser.com/ProductDetail/FCI/DILB16P-223TLF/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tnWBa37eU7kEZ8uy8DVlop0%3D);Jameco [37373](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_37373_-1) |
| IC Socket | U13 - U16 | 14 pin 300 mil DIP socket | 4 | Mouser [517-4814-3000-CP](http://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/4814-3000-CP/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXolv7TyDO1KrY%3D),[649-DILB14P-223TLF](http://www.mouser.com/ProductDetail/FCI/DILB14P-223TLF/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXoudDvhlAH3XM%3D);Jameco [37162](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_37162_-1) |
| IC Socket | U21, U22 | 8 pin 300 mil DIP socket | 2 | Mouser [517-4808-3000-CP](http://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/4808-3000-CP/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXoueZQAPgo6HQ%3D),[649-DILB8P223TLF](http://www.mouser.com/ProductDetail/FCI/DILB8P-223TLF/?qs=sGAEpiMZZMs%2FSh%2Fkjph1trsk3O0a2elqycTEeDCVfAg%3D);Jameco [51571](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_51571_-1) |
| Oscillator Socket | U17 - U19 | 4 pin 300 mil DIP full can oscillator socket | 3 | Mouser [535-1107741](http://www.mouser.com/ProductDetail/Aries/1107741/?qs=sGAEpiMZZMs%2FSh%2Fkjph1tvt1%2FmEPT%2FXoVZs6QxzSzII%3D);Jameco [133006](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_133006_-1) |
| Crystal | X1 | 32768 Hz crystal | 1 | Mouser [695-CFS206-327KB-U](http://www.mouser.com/ProductDetail/Citizen/CFS206-32768KDZB-UB/?qs=sGAEpiMZZMsBj6bBr9Q9aQX%2FBWSXR5XrkmCKe%2FKi0Qw%3D),[520-ECS327-6-13-X](http://www.mouser.com/ProductDetail/ECS/ECS-327-6-13X/?qs=sGAEpiMZZMsBj6bBr9Q9aWDZfF25lWfigWLFR7cXhrY%3d),[628-VT200F-6PF20PPM](http://www.mouser.com/ProductDetail/Seiko-Semiconductors/VT200F-6PF20PPM/?qs=sGAEpiMZZMsBj6bBr9Q9adSJD6Mp4Ig7%2frXOtYo1IGc%3d);Jameco [14584](http://www.jameco.com/webapp/wcs/stores/servlet/Product_10001_10001_14584_-1) |

### Replacement Notes

* 74xx logic
  - TTL logic families: 74LS, 74ALS, 74F, or TTL-compatible CMOS: 74HCT, 74AHCT, and 74ACT could be used.
  - Plain 74LS should work with CPU frequency up to 8 MHz. But it is recommended to use higher speed and lower power 74ALS ICs.
  - (FIXME: NOT TESTED YET) Tested with 74LS, 74ALS and 74HCT / 74AHCT logic families. Works on frequency up to 20MHz.
* Z80 CPU, Z80 CTC
  - Either NMOS or CMOS parts work. It is recommended to use at least 4 MHz CPU. 6 MHz or faster CPU is required for 1.44MB disk support. 8 MHz is recommended.
  - CMOS versions - Z84C00xxPEG or Z84C00xxPEC, and Z84C30xxPEG or Z84C30xxPEC are recommended.
  - Note: PEG or PEC suffixes mean 40 pin plastic DIP package, PEG is RoHS compliant, PEC is not.
  - Tested with CMOS Z84C00 (6MHz, 8MHz, 20MHz) and NMOS Z8400 (4MHz) CPUs, and CMOS Z84C0010PEG CTC
* 16550 UART
  - 16550 UART is recommended. 8250 or 16450 UARTs can be used as well, but they don't have FIFO.
  - Tested with: Texas Instruments TL16C550, Exar ST16C550, National Semiconductor NS16550AFN, California Micro Devices CM16C550, Goldstar GM16C450, and UMC 8250B
* 8255 PPI
  - It is recommended to use higher speed CMOS versions. For example 8 MHz Intersil / Harris CP82C55A part (note CP82C55A-5 is 5 MHz), 10 MHz Toshiba TMP82C55AP-10 or NEC D71055C-10 parts.
  - Tested with: Harris/Intersil CP82C55, TMP82C55AP-10, NEC D71055C-10, Intel 8255-5
* MAX202
  - Can be replaced by pin compatible devices like Maxim MAX232A, Texas Instruments TRS202, or Analog Devices ADM202, that use 0.1uF capacitors for charge pumps.
  - It is possible to use MAX232 or other parts that need 1uF capacitors. In this case capacitors C21 - C24 have to be replaced with 1uF capacitors. Pay attention to capacitors' polarity if using electrolytic capacitors.
* Bi-Level LED Indicator
  - Can be replaced by two 3 mm LEDs with pins bent at 90 degrees.
* Oscillators
  - It is possible to use half can oscillators instead of full can oscillators. In this case install oscillator at pins 4 - 11 . Refer to the PCB silkscreen for oscillator placement.

## Power Supply

Zeta SBC V2 requires a **regulated** 5V power supply. Make sure that the tip of the power supply is the positive lead. System's power consumption varies depending on components used on SBC (CMOS CPU/PPI/UART vs. NMOS components, CMOS logic vs. TTL/LS vs. TTL/ALS) and CPU clock frequency. Also floppy disk drives are relatively power hungry (about 1 A max). Jameco carries quite a few regulated switching 5V wall adapters with different amperage. See these catalog pages:

[http://www.jameco.com/Jameco/catalogs/c113/P105.pdf](http://www.jameco.com/Jameco/catalogs/c113/P105.pdf)

[http://www.jameco.com/Jameco/catalogs/c113/P106.pdf](http://www.jameco.com/Jameco/catalogs/c113/P106.pdf)

Alternatively it is possible to use a linear power supply with 7805 or similar voltage regulator (make sure to use a heatsink, especially if powering a floppy drive).

# Mods

Mods described here were intentionally not implemented on PCB to keep it simple.

* It is possible to use FTDI DB9-USB-M module (Mouser [895-DB9-USB-RS232-M](http://www.mouser.com/ProductDetail/FTDI/DB9-USB-M/?qs=sGAEpiMZZMtcidiSkZ6c9v%252b4CMhdZ6iS)) instead of the serial port connector P3. This module contains RS232 to USB converter IC and provides a mini USB connector. (Alexey, thank you for this tip). It even might be possible to use FTDI DB9-USB-D5-M module, eliminating MAX232A and related capacitors, and connecting the module directly to the UART.
* If you don't plan to use 8255 PPI, it can be omitted. In this case it is not needed to install U5, C5, P4, and JP2.
* It is possible to build Zeta SBC V2 without floppy disk controller (for example for the test purposes, or if you don't need floppy). In this case following components can be omitted: U6, U19, C6, C19, RR1, P5, P6.
* It is possible to build system without RTC, in this case following components can be omitted: U21, X1
* If you don't want battery backup for SRAM, it is possible to omit U22 and BT1. In this case it is needed to connect U22 pin 5 to pin 6 (~RAM_CS) and pin 1 to pin 8 (VCC).

# PCB Versions

## PCB Version 2.0 (Changes from Zeta SBC 1.3)

* Major schematic and PCB change. Board rerouted, most of ICs moved around or shifted.
* Added Z80 CTC
* Replaced FDC9266 floppy disk controller and related discrete logic with WD37C65
* New memory banking implementation.
* Serial port uses RTS/CTS for flow control instead of DSR/DTS.

## Various Ideas

* Image enhancements
  - NVRAM support (BIOS configuration using NVRAM), NVRAM configuration utility
* Enhance utility for programming the BIOS, CP/M, and ROM disk separately. (It already supports the full image programming)
* Add incorrect power supply polarity protection
  - Option 1: Schottky diode in series
  - Option 2: Diode connected in parallel to power supply, in reverse (could be dangerous if power supply is not short circuit protected)
  - Option 3: Use FET

# Files

| Link | Modified |
| :--- | :------- |
| [Zeta SBC V2 - Assembled Board.JPG](files/Zeta%20SBC%20V2%20-%20Assembled%20Board.JPG) (853k) | Sergey Kiselev, Mar 30, 2015, 9:11 AM |
| [Zeta SBC V2 - Board - Color - 2.0.pdf](files/Zeta%20SBC%20V2%20-%20Board%20-%20Color%20-%202.0.pdf) (1200k) | Sergey Kiselev, Jun 15, 2015, 10:48 AM |
| [Zeta SBC V2 - Gerber - 2.0.zip](files/Zeta%20SBC%20V2%20-%20Gerber%20-%202.0.zip) (260k) | Sergey Kiselev, Jun 15, 2015, 10:47 AM |
| [Zeta SBC V2 - KiCad - 2.0.zip](files/Zeta%20SBC%20V2%20-%20KiCad%20-%202.0.zip) (457k) | Sergey Kiselev, Jun 15, 2015, 10:47 AM |
| [Zeta SBC V2 - Schematic - Color - 2.0.pdf](files/Zeta%20SBC%20V2%20-%20Schematic%20-%20Color%20-%202.0.pdf) (210k) | Sergey Kiselev, Jun 15, 2015, 10:48 AM |
| [Zeta with ParPortProp - Perspective View.jpg](files/Zeta%20with%20ParPortProp%20-%20Perspective%20View.jpg) (190k) | Sergey Kiselev, Jan 23, 2015, 11:40 AM |
