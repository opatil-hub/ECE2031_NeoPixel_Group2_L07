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
	
	; Get the switch value, mask out the
	; desired bits for red, and insert
	; them into the appropriate place in
	; the output variable.
	IN    Switches
	AND   RedMask
	; These bits are currently in 5-4, and
	; they need to be in 12-11.
	SHIFT -4
	;OR    OutColor
	;STORE OutColor
	out NeoPixelR
	; Repeat for green
	IN    Switches
	AND   GreenMask
	; These bits are currently in 3-2, and
	; they need to be in 7-6.
	SHIFT -2
	out NeoPixelG
	;OR    OutColor
	;STORE OutColor
	
	; Repeat for blue
	IN    Switches
	AND   BlueMask
	; These bits are currently in 1-0, and
	; are already there.
	;OR    OutColor
	;STORE OutColor
	out NeoPixelB
	; Send to the NeoPixel controller
	;OUT   NeoPixel16
	in switches
	shift -6
	out	  NeoPixelsingle
	JUMP  Start	

OutColor:  DW 0
RedMask:   DW &B110000
GreenMask: DW &B1100
BlueMask:  DW &B11

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
