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
	AND NineSwitch
	JPOS NeoPixel16Block
	JUMP NeoPixel24
SingleOrAll:
	IN Switches
	AND EightSwitch
	JPOS NeoPixel_Single
	JUMP NeoPixel_All
	JUMP Start
NeoPixel16Block:
	IN Switches
	AND RedMask
	OR  RedAdditional
	SHIFT -10
	OR OutColor
	STORE OutColor
	IN Switches
	AND GreenMask
	OR GreenAdditional
	SHIFT -6
	OR OutColor
	STORE OutColor
	IN Switches
	AND BlueMask
	OR BlueAdditional
	OR OutColor
	STORE OutColor
	LOAD OutColor
	OUT NeoPixel16
	JUMP SingleOrAll
NeoPixel24:
	IN    Switches
	AND   RedMask
	OR  RedAdditional
	SHIFT -10
	OUT NeoPixelR
	IN Switches
	AND GreenMask
	OR GreenAdditional
	SHIFT -6
	OUT NeoPixelG
	IN Switches
	AND BlueMask
	OR BlueAdditional
	OUT NeoPixelB
	JUMP SingleOrAll
NeoPixel_Single:
	; Will Depend on the Key1 Push Button -- implement later
	IN Switches
	AND SevenSwitch
	JPOS NeoPixelSingleExecuteBlock
	OUT  NeoPixelSingle
	OUT  Hex0
	JUMP NeoPixel_Single
NeoPixelSingleExecuteBlock:
	OUT NeoPixelSingleExecute
	JUMP Start
NeoPixel_All:
	; Do NOT call OUT NeoPixelSingle, the enable signal must remain 0 as we are not attempting to manipulate a specific signal
	JUMP  Start	

OutColor:  DW 0
RedMask:   DW &B100
RedAdditional: DW &B110
GreenMask: DW &B010
GreenAdditional: DW &B011
BlueMask:  DW &B001
BlueAdditional: DW &B011
NineSwitch: DW &B1000000000
EightSwitch: DW &B0100000000
SevenSwitch: DW &B0010000000

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
NeoPixelSingle:  EQU &H0A2
NeoPixelSingleExecute: EQU &H0A5
