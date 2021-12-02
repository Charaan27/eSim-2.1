EESchema Schematic File Version 2
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:power
LIBS:eSim_Plot
LIBS:transistors
LIBS:conn
LIBS:eSim_User
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:eSim_Analog
LIBS:eSim_Devices
LIBS:eSim_Digital
LIBS:eSim_Hybrid
LIBS:eSim_Miscellaneous
LIBS:eSim_Power
LIBS:eSim_Sources
LIBS:eSim_Subckt
LIBS:eSim_Nghdl
LIBS:eSim_Ngveri
LIBS:UART-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L uart U13
U 1 1 6199D170
P 4500 4600
F 0 "U13" H 7350 6400 60  0000 C CNN
F 1 "uart" H 7350 6600 60  0000 C CNN
F 2 "" H 7350 6550 60  0000 C CNN
F 3 "" H 7350 6550 60  0000 C CNN
	1    4500 4600
	1    0    0    -1  
$EndComp
$Comp
L counter8bit U9
U 1 1 6199D237
P 3100 4900
F 0 "U9" H 5950 6700 60  0000 C CNN
F 1 "counter8bit" H 5950 6900 60  0000 C CNN
F 2 "" H 5950 6850 60  0000 C CNN
F 3 "" H 5950 6850 60  0000 C CNN
	1    3100 4900
	1    0    0    -1  
$EndComp
Wire Wire Line
	6650 2700 5100 2700
Wire Wire Line
	5100 2700 5100 3100
Wire Wire Line
	4700 3100 5250 3100
Connection ~ 5100 3100
Wire Wire Line
	4700 3000 5250 3000
Wire Wire Line
	4700 2900 6650 2900
Wire Wire Line
	4700 2800 6650 2800
Wire Wire Line
	4700 3200 5200 3200
Wire Wire Line
	5200 3200 5200 3800
Wire Wire Line
	5200 3800 6650 3800
Wire Wire Line
	4700 3300 5050 3300
Wire Wire Line
	5050 3300 5050 3900
Wire Wire Line
	5050 3900 6650 3900
Wire Wire Line
	4700 3400 4950 3400
Wire Wire Line
	4950 3400 4950 4000
Wire Wire Line
	4950 4000 6650 4000
Wire Wire Line
	4700 3500 4850 3500
Wire Wire Line
	4850 3500 4850 4100
Wire Wire Line
	4850 4100 6650 4100
$Comp
L dac_bridge_2 U15
U 1 1 6199D5B9
P 8900 2550
F 0 "U15" H 8900 2550 60  0000 C CNN
F 1 "dac_bridge_2" H 8950 2700 60  0000 C CNN
F 2 "" H 8900 2550 60  0000 C CNN
F 3 "" H 8900 2550 60  0000 C CNN
	1    8900 2550
	1    0    0    -1  
$EndComp
$Comp
L dac_bridge_1 U14
U 1 1 6199D641
P 8650 3950
F 0 "U14" H 8650 3950 60  0000 C CNN
F 1 "dac_bridge_1" H 8650 4100 60  0000 C CNN
F 2 "" H 8650 3950 60  0000 C CNN
F 3 "" H 8650 3950 60  0000 C CNN
	1    8650 3950
	1    0    0    -1  
$EndComp
Wire Wire Line
	8050 3900 8050 3700
$Comp
L plot_v1 U16
U 1 1 6199D6C5
P 9550 2550
F 0 "U16" H 9550 3050 60  0000 C CNN
F 1 "plot_v1" H 9750 2900 60  0000 C CNN
F 2 "" H 9550 2550 60  0000 C CNN
F 3 "" H 9550 2550 60  0000 C CNN
	1    9550 2550
	1    0    0    -1  
$EndComp
Text GLabel 9950 2500 0    60   Input ~ 0
tx_out
Wire Wire Line
	8050 2700 8050 2500
Wire Wire Line
	8050 2500 8450 2500
Wire Wire Line
	8050 2800 8150 2800
Wire Wire Line
	8150 2800 8150 2600
Wire Wire Line
	8150 2600 8450 2600
Wire Wire Line
	9450 2500 9950 2500
Wire Wire Line
	9550 2350 9550 2500
Connection ~ 9550 2500
$Comp
L plot_v1 U18
U 1 1 6199DAC0
P 10150 2650
F 0 "U18" H 10150 3150 60  0000 C CNN
F 1 "plot_v1" H 10350 3000 60  0000 C CNN
F 2 "" H 10150 2650 60  0000 C CNN
F 3 "" H 10150 2650 60  0000 C CNN
	1    10150 2650
	1    0    0    -1  
$EndComp
Text GLabel 10550 2600 2    60   Input ~ 0
tx_empty
Wire Wire Line
	9450 2600 10550 2600
Wire Wire Line
	10150 2450 10150 2600
Connection ~ 10150 2600
$Comp
L plot_v1 U17
U 1 1 6199DB7F
P 9900 3950
F 0 "U17" H 9900 4450 60  0000 C CNN
F 1 "plot_v1" H 10100 4300 60  0000 C CNN
F 2 "" H 9900 3950 60  0000 C CNN
F 3 "" H 9900 3950 60  0000 C CNN
	1    9900 3950
	1    0    0    -1  
$EndComp
Text GLabel 10300 3900 2    60   Input ~ 0
rx_empty
Wire Wire Line
	9200 3900 10300 3900
Wire Wire Line
	9900 3750 9900 3900
Connection ~ 9900 3900
$Comp
L plot_v1 U8
U 1 1 6199DE62
P 2850 2950
F 0 "U8" H 2850 3450 60  0000 C CNN
F 1 "plot_v1" H 3050 3300 60  0000 C CNN
F 2 "" H 2850 2950 60  0000 C CNN
F 3 "" H 2850 2950 60  0000 C CNN
	1    2850 2950
	1    0    0    -1  
$EndComp
$Comp
L plot_v1 U10
U 1 1 6199DEED
P 3250 2950
F 0 "U10" H 3250 3450 60  0000 C CNN
F 1 "plot_v1" H 3450 3300 60  0000 C CNN
F 2 "" H 3250 2950 60  0000 C CNN
F 3 "" H 3250 2950 60  0000 C CNN
	1    3250 2950
	1    0    0    -1  
$EndComp
$Comp
L plot_v1 U7
U 1 1 6199DFE2
P 2400 2950
F 0 "U7" H 2400 3450 60  0000 C CNN
F 1 "plot_v1" H 2600 3300 60  0000 C CNN
F 2 "" H 2400 2950 60  0000 C CNN
F 3 "" H 2400 2950 60  0000 C CNN
	1    2400 2950
	1    0    0    -1  
$EndComp
$Comp
L plot_v1 U6
U 1 1 6199E05C
P 2000 2950
F 0 "U6" H 2000 3450 60  0000 C CNN
F 1 "plot_v1" H 2200 3300 60  0000 C CNN
F 2 "" H 2000 2950 60  0000 C CNN
F 3 "" H 2000 2950 60  0000 C CNN
	1    2000 2950
	1    0    0    -1  
$EndComp
$Comp
L plot_v1 U5
U 1 1 6199E0E6
P 1650 2950
F 0 "U5" H 1650 3450 60  0000 C CNN
F 1 "plot_v1" H 1850 3300 60  0000 C CNN
F 2 "" H 1650 2950 60  0000 C CNN
F 3 "" H 1650 2950 60  0000 C CNN
	1    1650 2950
	1    0    0    -1  
$EndComp
$Comp
L plot_v1 U4
U 1 1 6199E15C
P 1350 2950
F 0 "U4" H 1350 3450 60  0000 C CNN
F 1 "plot_v1" H 1550 3300 60  0000 C CNN
F 2 "" H 1350 2950 60  0000 C CNN
F 3 "" H 1350 2950 60  0000 C CNN
	1    1350 2950
	1    0    0    -1  
$EndComp
$Comp
L plot_v1 U3
U 1 1 6199E1D4
P 1000 2950
F 0 "U3" H 1000 3450 60  0000 C CNN
F 1 "plot_v1" H 1200 3300 60  0000 C CNN
F 2 "" H 1000 2950 60  0000 C CNN
F 3 "" H 1000 2950 60  0000 C CNN
	1    1000 2950
	1    0    0    -1  
$EndComp
$Comp
L plot_v1 U2
U 1 1 6199E25E
P 700 2950
F 0 "U2" H 700 3450 60  0000 C CNN
F 1 "plot_v1" H 900 3300 60  0000 C CNN
F 2 "" H 700 2950 60  0000 C CNN
F 3 "" H 700 2950 60  0000 C CNN
	1    700  2950
	1    0    0    -1  
$EndComp
$Comp
L plot_v1 U1
U 1 1 6199EB99
P 100 2950
F 0 "U1" H 100 3450 60  0000 C CNN
F 1 "plot_v1" H 300 3300 60  0000 C CNN
F 2 "" H 100 2950 60  0000 C CNN
F 3 "" H 100 2950 60  0000 C CNN
	1    100  2950
	1    0    0    -1  
$EndComp
Wire Wire Line
	3250 2750 3250 2800
Wire Wire Line
	3250 2800 3550 2800
Wire Wire Line
	2850 2750 2850 2900
Wire Wire Line
	2850 2900 3550 2900
Wire Wire Line
	2400 2750 2400 3000
Wire Wire Line
	2400 3000 3550 3000
Wire Wire Line
	2000 2750 2000 3100
Wire Wire Line
	2000 3100 3550 3100
Wire Wire Line
	1650 2750 1650 3200
Wire Wire Line
	1650 3200 3550 3200
Wire Wire Line
	1350 2750 1350 3300
Wire Wire Line
	1350 3300 3550 3300
Wire Wire Line
	1000 2750 1000 3400
Wire Wire Line
	1000 3400 3550 3400
Wire Wire Line
	700  2750 700  4350
Wire Wire Line
	700  3500 3550 3500
$Comp
L adc_bridge_8 U12
U 1 1 6199EFA7
P 4150 2850
F 0 "U12" H 4150 2850 60  0000 C CNN
F 1 "adc_bridge_8" H 4150 3000 60  0000 C CNN
F 2 "" H 4150 2850 60  0000 C CNN
F 3 "" H 4150 2850 60  0000 C CNN
	1    4150 2850
	1    0    0    -1  
$EndComp
$Comp
L adc_bridge_1 U11
U 1 1 6199F080
P 4100 4200
F 0 "U11" H 4100 4200 60  0000 C CNN
F 1 "adc_bridge_1" H 4100 4350 60  0000 C CNN
F 2 "" H 4100 4200 60  0000 C CNN
F 3 "" H 4100 4200 60  0000 C CNN
	1    4100 4200
	1    0    0    -1  
$EndComp
Wire Wire Line
	4650 4150 6650 4150
Wire Wire Line
	6650 4150 6650 4200
Wire Wire Line
	100  2750 100  4300
Wire Wire Line
	100  4150 3500 4150
$Comp
L pulse v1
U 1 1 6199F281
P 100 4750
F 0 "v1" H -100 4850 60  0000 C CNN
F 1 "pulse" H -100 4700 60  0000 C CNN
F 2 "R1" H -200 4750 60  0000 C CNN
F 3 "" H 100 4750 60  0000 C CNN
	1    100  4750
	1    0    0    -1  
$EndComp
$Comp
L pulse v2
U 1 1 6199F371
P 700 4800
F 0 "v2" H 500 4900 60  0000 C CNN
F 1 "pulse" H 500 4750 60  0000 C CNN
F 2 "R1" H 400 4800 60  0000 C CNN
F 3 "" H 700 4800 60  0000 C CNN
	1    700  4800
	1    0    0    -1  
$EndComp
$Comp
L pulse v3
U 1 1 6199F3E3
P 1050 4800
F 0 "v3" H 850 4900 60  0000 C CNN
F 1 "pulse" H 850 4750 60  0000 C CNN
F 2 "R1" H 750 4800 60  0000 C CNN
F 3 "" H 1050 4800 60  0000 C CNN
	1    1050 4800
	1    0    0    -1  
$EndComp
$Comp
L pulse v4
U 1 1 6199F451
P 1450 4850
F 0 "v4" H 1250 4950 60  0000 C CNN
F 1 "pulse" H 1250 4800 60  0000 C CNN
F 2 "R1" H 1150 4850 60  0000 C CNN
F 3 "" H 1450 4850 60  0000 C CNN
	1    1450 4850
	1    0    0    -1  
$EndComp
$Comp
L pulse v5
U 1 1 6199F4C7
P 1850 4800
F 0 "v5" H 1650 4900 60  0000 C CNN
F 1 "pulse" H 1650 4750 60  0000 C CNN
F 2 "R1" H 1550 4800 60  0000 C CNN
F 3 "" H 1850 4800 60  0000 C CNN
	1    1850 4800
	1    0    0    -1  
$EndComp
$Comp
L pulse v6
U 1 1 6199F531
P 2200 4800
F 0 "v6" H 2000 4900 60  0000 C CNN
F 1 "pulse" H 2000 4750 60  0000 C CNN
F 2 "R1" H 1900 4800 60  0000 C CNN
F 3 "" H 2200 4800 60  0000 C CNN
	1    2200 4800
	1    0    0    -1  
$EndComp
$Comp
L pulse v7
U 1 1 6199F5A7
P 2600 4800
F 0 "v7" H 2400 4900 60  0000 C CNN
F 1 "pulse" H 2400 4750 60  0000 C CNN
F 2 "R1" H 2300 4800 60  0000 C CNN
F 3 "" H 2600 4800 60  0000 C CNN
	1    2600 4800
	1    0    0    -1  
$EndComp
$Comp
L pulse v8
U 1 1 6199F625
P 3150 4800
F 0 "v8" H 2950 4900 60  0000 C CNN
F 1 "pulse" H 2950 4750 60  0000 C CNN
F 2 "R1" H 2850 4800 60  0000 C CNN
F 3 "" H 3150 4800 60  0000 C CNN
	1    3150 4800
	1    0    0    -1  
$EndComp
$Comp
L pulse v9
U 1 1 6199F69F
P 3500 4800
F 0 "v9" H 3300 4900 60  0000 C CNN
F 1 "pulse" H 3300 4750 60  0000 C CNN
F 2 "R1" H 3200 4800 60  0000 C CNN
F 3 "" H 3500 4800 60  0000 C CNN
	1    3500 4800
	1    0    0    -1  
$EndComp
Connection ~ 100  4150
Connection ~ 700  3500
Wire Wire Line
	1050 3200 1050 4350
Connection ~ 1050 3400
Wire Wire Line
	1450 4400 1450 3300
Wire Wire Line
	1450 3300 1400 3300
Connection ~ 1400 3300
Wire Wire Line
	1850 4350 1850 3200
Wire Wire Line
	1850 3200 1800 3200
Connection ~ 1800 3200
Wire Wire Line
	2200 4350 2200 3100
Connection ~ 2200 3100
Wire Wire Line
	2600 4350 2600 3000
Connection ~ 2600 3000
Wire Wire Line
	3150 4350 3150 2900
Connection ~ 3150 2900
Wire Wire Line
	3500 4350 3500 2800
Connection ~ 3500 2800
$Comp
L GND #PWR01
U 1 1 6199FBD1
P 1700 5750
F 0 "#PWR01" H 1700 5500 50  0001 C CNN
F 1 "GND" H 1700 5600 50  0000 C CNN
F 2 "" H 1700 5750 50  0001 C CNN
F 3 "" H 1700 5750 50  0001 C CNN
	1    1700 5750
	1    0    0    -1  
$EndComp
Wire Wire Line
	100  5200 100  5750
Wire Wire Line
	100  5750 1700 5750
Wire Wire Line
	700  5250 700  5750
Connection ~ 700  5750
Wire Wire Line
	1050 5250 1050 5750
Wire Wire Line
	1050 5750 1000 5750
Connection ~ 1000 5750
Wire Wire Line
	1450 5300 1450 5750
Connection ~ 1450 5750
Wire Wire Line
	1850 5250 1850 5750
Wire Wire Line
	1600 5750 3500 5750
Connection ~ 1600 5750
Wire Wire Line
	2200 5750 2200 5250
Connection ~ 1850 5750
Wire Wire Line
	2600 5750 2600 5250
Connection ~ 2200 5750
Wire Wire Line
	3150 5750 3150 5250
Connection ~ 2600 5750
Wire Wire Line
	3500 5750 3500 5250
Connection ~ 3150 5750
Text GLabel 2200 3100 0    60   Input ~ 0
reset
Text GLabel 3500 2800 0    60   Input ~ 0
txclk
Text GLabel 3150 2900 0    60   Input ~ 0
ldtxdata
Text GLabel 2600 3000 0    60   Input ~ 0
countclk
Text GLabel 1800 3200 0    60   Input ~ 0
txen
Text GLabel 1400 3300 0    60   Input ~ 0
rxclk
Text GLabel 700  3500 0    60   Input ~ 0
rxen
Text GLabel 100  4150 0    60   Input ~ 0
rxin
Text GLabel 1050 3200 0    60   Input ~ 0
uldtxen
$EndSCHEMATC
