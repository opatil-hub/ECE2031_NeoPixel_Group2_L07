-- DIG_IN.VHD (a peripheral module for SCOMP)
-- This module reads digital inputs directly

LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE LPM.LPM_COMPONENTS.ALL;
use ieee.numeric_std.all; 

ENTITY DIG_IN IS
  PORT(
	 CS          : IN    STD_LOGIC;
	 IO_WRITE    : IN    STD_LOGIC;
    DI          : IN    STD_LOGIC_VECTOR(15 DOWNTO 0);
    IO_DATA     : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	 KS          : IN    STD_LOGIC;
	 KS_DATA     : IN bit;
	 KS_7        : IN bit;
	 KS_DATA_O   : buffer unsigned(8 downto 0)
  );
END DIG_IN;

ARCHITECTURE a OF DIG_IN IS
  SIGNAL B_DI : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL K_DI : STD_LOGIC_VECTOR(1 DOWNTO 0);
 
  BEGIN
    -- Use LPM function to create bidirectional I/O data bus
    IO_BUS: lpm_bustri
    GENERIC MAP (
      lpm_width => 16
    )
    PORT MAP (
      data     => B_DI,
      enabledt => CS,
      tridata  => IO_DATA
    );

    PROCESS
    BEGIN
      WAIT UNTIL RISING_EDGE(CS);
      B_DI <= DI; -- sample the input on the rising edge of CS
    END PROCESS;
	 
	 process(KS)
		begin
			if KS = '1' then
				if KS_DATA = '1' then
					if KS_7 = '0' then
						KS_DATA_O <= KS_DATA_O + 1;
					end if;
				end if;
			else
				KS_DATA_O <= (others => '0');
			end if;
	 end process;
				

END a;

