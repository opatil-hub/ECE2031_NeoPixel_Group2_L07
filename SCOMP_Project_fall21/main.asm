; This code uses the switches to control the color
; of the NeoPixel.
; SW1-0 controls blue,
; SW3-2 controls green,
; SW5-4 controls red.
; The brightness is kept low by only controlling
; low bits in the values:
; ---RR---GG----BB
; Even though green accepts six bits, this doesn't use
; the lowest bit so that green is the same magnitude
; as red and blue.

ORG 0
Start:
	; Zero the color variable
	LOADI 0
	STORE OutColor
	
	IN Switches
	
	AND RedMask
	
	OR  RedAdditional
	SHIFT -7
	OUT NeoPixel
	
	JUMP  Start	

OutColor:  DW 0
RedMask:   DW &B100
RedAdditional: DW &B110
GreenMask: DW &B010
BlueMask:  DW &B001
NineSwitch: DW &B1000000000

; IO address constants
Switches:  EQU &H000
LEDs:      EQU &H001
Timer:     EQU &H002
Hex0:      EQU &H004
Hex1:      EQU &H005
I2C_cmd:   EQU &H090
I2C_data:  EQU &H091
I2C_rdy:   EQU &H092
NeoPixel16:  EQU &H0A0
NeoPixelB:  EQU &H0A1
NeoPixelG:  EQU &H0A3
NeoPixelR:  EQU &H0A4

NeoPixelsingle:  EQU &H0A2
