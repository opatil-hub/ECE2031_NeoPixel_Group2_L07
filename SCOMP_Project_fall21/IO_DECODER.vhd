-- IO DECODER for SCOMP
-- This eliminates the need for a lot of AND decoders or Comparators 
--    that would otherwise be spread around the top-level BDF

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY IO_DECODER IS

  PORT
  (
    IO_ADDR       : IN STD_LOGIC_VECTOR(10 downto 0);
    IO_CYCLE      : IN STD_LOGIC;
    SWITCH_EN     : OUT STD_LOGIC;
    LED_EN        : OUT STD_LOGIC;
    TIMER_EN      : OUT STD_LOGIC;
    HEX0_EN       : OUT STD_LOGIC;
    HEX1_EN       : OUT STD_LOGIC;
    I2C_CMD_EN    : OUT STD_LOGIC;
    I2C_DATA_EN   : OUT STD_LOGIC;
    I2C_RDY_EN    : OUT STD_LOGIC;
    NeoPixel16      : OUT STD_LOGIC;
	 NeoPixelB      : OUT STD_LOGIC;
	 NeoPixelG      : OUT STD_LOGIC;
	 NeoPixelR      : OUT STD_LOGIC;
	 NeoPixelsingle      : OUT STD_LOGIC;
	 NeoPixelSingleExecute : OUT STD_LOGIC;
	 NeoPixelAutoInc : oUT STD_LOGIC
  );

END ENTITY;

ARCHITECTURE a OF IO_DECODER IS

  SIGNAL  ADDR_INT  : INTEGER RANGE 0 TO 2047;
  
begin

  ADDR_INT <= TO_INTEGER(UNSIGNED(IO_ADDR));
        
  SWITCH_EN    <= '1' WHEN (ADDR_INT = 16#000#) and (IO_CYCLE = '1') ELSE '0';
  LED_EN       <= '1' WHEN (ADDR_INT = 16#001#) and (IO_CYCLE = '1') ELSE '0';
  TIMER_EN     <= '1' WHEN (ADDR_INT = 16#002#) and (IO_CYCLE = '1') ELSE '0';
  HEX0_EN      <= '1' WHEN (ADDR_INT = 16#004#) and (IO_CYCLE = '1') ELSE '0';
  HEX1_EN      <= '1' WHEN (ADDR_INT = 16#005#) and (IO_CYCLE = '1') ELSE '0';
  I2C_CMD_EN   <= '1' WHEN (ADDR_INT = 16#090#) and (IO_CYCLE = '1') ELSE '0';
  I2C_DATA_EN  <= '1' WHEN (ADDR_INT = 16#091#) and (IO_CYCLE = '1') ELSE '0';
  I2C_RDY_EN   <= '1' WHEN (ADDR_INT = 16#092#) and (IO_CYCLE = '1') ELSE '0';
  NeoPixel16     <= '1' WHEN (ADDR_INT = 16#0A0#) and (IO_CYCLE = '1') ELSE '0';
  NeoPixelB     <= '1' WHEN (ADDR_INT = 16#0A1#) and (IO_CYCLE = '1') ELSE '0';
  NeoPixelG     <= '1' WHEN (ADDR_INT = 16#0A3#) and (IO_CYCLE = '1') ELSE '0';
  NeoPixelR     <= '1' WHEN (ADDR_INT = 16#0A4#) and (IO_CYCLE = '1') ELSE '0';
	NeoPixelsingle    <= '1' WHEN (ADDR_INT = 16#0A2#) and (IO_CYCLE = '1') ELSE '0';
	NeoPixelSingleExecute <= '1' WHEN (ADDR_INT = 16#0A5#) and (IO_CYCLE = '1') ELSE '0';
	NeoPixelAutoInc <= '1' WHEN (ADDR_INT = 16#0A6#) and (IO_CYCLE = '1') ELSE '0';
END a;
