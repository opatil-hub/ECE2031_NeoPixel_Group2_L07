-- WS2812 communication interface.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

	entity NeoPixelController is
	
	
	port(
		clk_10M  : in   std_logic;
		resetn   : in   std_logic;
		latch16    : in   std_logic;
		latchB    : in   std_logic;
		latchG    : in   std_logic;
		latchR    : in   std_logic;
		latchsingle : in std_logic;
		shift_amount: in unsigned(15 downto 0);
		Bdata     : in   std_logic_vector(15 downto 0);
		Gdata     : in   std_logic_vector(15 downto 0);
		Rdata     : in   std_logic_vector(15 downto 0);
		data     : in   std_logic_vector(15 downto 0);
		sda      : out  std_logic;
		latchall : in std_logic;
		latchautoinc : in std_logic
	); 

end entity;

architecture internals of NeoPixelController is
	--shared variable buffer_bits: integer := 23;
	--shared variable hold_bits : integer := 23;

	-- Signal to store the pixel's color data
	-- signal led_buffer : std_logic_vector(buffer_bits downto 0);
	signal led_16color : std_logic_vector(23 downto 0) := (others => '0');
	signal led_24color : std_logic_vector(23 downto 0) := (others => '0');
	signal led_color  : std_logic_vector(23 downto 0) := (others => '0');
	signal led_Bcolor : std_logic_vector(7 downto 0) := (others => '0');
	signal led_Gcolor : std_logic_vector(7 downto 0) := (others => '0');
	signal led_Rcolor : std_logic_vector(7 downto 0) := (others => '0');
	
	signal led_buffer : unsigned(119 downto 0) := (others => '0');
	--signal led_hold : unsigned(6144 downto 0) := (others => '0');
	
	type state_type is (ledsingle, ledall, ledincrement);
	signal state : state_type := ledall;
	
	signal shift_amount_int :integer;
	shared variable Colorsize : bit :='0';
	shared variable ledBufferSingle : unsigned(119 downto 0);
	shared variable ledBufferAll : unsigned(119 downto 0);
	shared variable ledBufferAutoInc : unsigned(119 downto 0);
	shared variable singleOrAll : bit := '0';
	shared variable shift_amount_int2: integer := 0;
	shared variable autoin : bit := '0';
	
	
	
begin
	shift_amount_int<= 24 * to_integer(shift_amount);
	process (clk_10M, resetn)
		-- protocol timing values (in 100s of ns)
		constant t1h : integer := 8;
		constant t1l : integer := 4;
		constant t0h : integer := 3;
		constant t0l : integer := 9;

		-- which bit in the 24 bits is being sent
		variable bit_count   : integer range 0 to 119;
		-- counter to count through the bit encoding
		variable enc_count   : integer range 0 to 31;
		-- counter for the reset pulse
		variable reset_count : integer range 0 to 10000000;
		
		
	begin
		if resetn = '0' then
			-- reset all counters
			bit_count := 119;
			enc_count := 0;
			reset_count := 10000000;
			-- set sda inactive
			sda <= '0';
			state <= ledall;
		elsif (rising_edge(clk_10M)) then

			-- This IF block controls the various counters
			if reset_count > 0 then
				-- during reset period, ensure other counters are reset
				bit_count := 119;
				enc_count := 0;
				-- decrement the reset count
				reset_count := reset_count - 1;
				
			else -- not in reset period (i.e. currently sending data)
				-- handle reaching end of a bit
				if led_buffer(bit_count) = '1' then -- current bit is 1
					if enc_count = (t1h+t1l-1) then -- is end of the bit?
						enc_count := 0;
						if bit_count = 0 then -- is end of the LED's data?
							-- begin the reset period
							reset_count := 10000000;
						else
							-- if not end of data, decrement count
							bit_count := bit_count - 1;
						end if;
					else
						-- within a bit, count to achieve correct pulse widths
						enc_count := enc_count + 1;
					end if;
				else -- current bit is 0
					if enc_count = (t0h+t0l-1) then -- is end of the bit?
						enc_count := 0;
						if bit_count = 0 then -- is end of the LED's data?
							-- begin the reset period
							reset_count := 1000000;
						else
							bit_count := bit_count - 1;
						end if;
					else
						-- within a bit, count to achieve correct pulse widths
						enc_count := enc_count + 1;
					end if;
				end if;
			end if;
			
			-- This IF block controls sda
			if reset_count > 0 then
				-- sda is 0 during reset/latch
				sda <= '0';
			elsif 
				-- sda is 1 if it's the first part of a bit, which depends on if it's 1 or 0
				( ((led_buffer(bit_count) = '1') and (enc_count < t1h))
				or
				((led_buffer(bit_count) = '0') and (enc_count < t0h)) )
				then sda <= '1';
			else
				sda <= '0';
			end if;
			
			case state is
				when ledall =>
					autoin := '0';
					if latchsingle = '1' then
						state <= ledsingle;
					elsif latchautoinc = '1' then
						state <= ledincrement;
					end if;
				when ledsingle =>
					autoin := '0';
					if latchautoinc = '1' then
						state <= ledincrement;
					end if;
				when ledincrement =>
					autoin := '1';
					if latchsingle = '1' then
						state <= ledsingle;
					else
						state <= ledall;
					end if;
			end case;
			
--			case state is
--				when ledall =>
--					led_buffer <= ledBufferSingle;
--				when ledsingle =>
--					led_buffer <= ledBufferAll;
--				when ledincrement =>
--					led_buffer <= ledBufferAutoInc;
--			end case;
			
			if state = ledsingle then
				led_buffer <= ledBufferSingle;
			elsif state = ledall then
				led_buffer <= ledBufferAll;
			elsif state = ledincrement then
				autoin := '1';
				led_buffer <= ledBufferAutoInc;
			end if;
		
--			if singleOrAll = '1' then
--				led_buffer <= ledBufferSingle;
--			else
--				led_buffer <= ledBufferAll;
--			end if;
			
		end if;
	end process;
	
	-- Process to handle OUTs from SCOMP
	
	process(latch16)
	--variable counter : Integer:=0;
	 
	begin
		if rising_edge(latch16) then
			
			led_16color<=data(10 downto 5) & "00" & data(15 downto 11) & "000" & data(4 downto 0) & "000" ;
			
		end if;
	end process;
	
	-- This process block implements outputting either a single LED or all LEDs on the
	-- NeoPixel Strip
	
	process(latchsingle, resetn)
	variable ledHolder : unsigned(119 downto 0);
	--constant shiftNum : integer := shift_amount_int;
	begin
		if resetn = '0' then
			singleOrAll := '0';
		elsif rising_edge(latchsingle) then
			ledHolder := (others => '0');
			if (colorsize ='0') then
				ledHolder := ledHolder or unsigned(led_16color);			
				--led_buffer <= std_logic_vector(shift_left(unsigned(std_logic_vector(led_hold) or led_16color), 24*shift_amount_int));
			else
				ledHolder := ledHolder or unsigned(led_24color);
				--led_buffer <= std_logic_vector(shift_left(unsigned(std_logic_vector(led_hold) or led_24color), 24*shift_amount_int));
			end if;
			--for i in 1 to shiftNum loop
				--ledHolder := shift_left(ledHolder, 1);
			--end loop;
			--led_hold <= shift_left(led_hold, shift_amount_int);
			ledHolder := shift_left(ledHolder, shift_amount_int);
			
			ledBufferSingle := led_buffer xor ledHolder;
			ledBufferSingle := ledBufferSingle or ledHolder;
			singleOrAll := '1';
		end if;
	end process;
	
	process(latchall)
	begin
		if rising_edge(latchall) then
		ledBufferAll := shift_left(led_buffer,24);
			if (colorsize = '0') then
				ledBufferAll := ledBufferAll or unsigned(led_16color);
			else
				ledBufferAll := ledBufferAll or unsigned(led_24color);
			end if;
		end if;
	end process;
	
	process(latchautoinc, resetn)
	variable shift_count   : integer range 0 to 10000000;
	variable ledHolder2 : unsigned(119 downto 0);
	constant shiftNum : integer := shift_amount_int2;
	begin
		if (autoin = '1') then
			if resetn = '0' then
				shift_count := 10000000;
			elsif(shift_amount_int2=6120) then
				shift_amount_int2:=0;
			elsif (rising_edge(clk_10M)) then
	
				-- This IF block controls the various counters
				if shift_count > 0 then
					shift_count := shift_count - 1;
				else
					shift_amount_int2:=shift_amount_int2+24;
					shift_count:= 10000000;
					--ledHolder2 := (others => '0');
					ledHolder2 := ledHolder2 or unsigned(led_16color);
					ledHolder2 := shift_left(ledHolder2, shift_amount_int2);
--					for k in 0 to shiftNum loop
--						ledHolder2 := shift_left(ledHolder2, 1);						
--					end loop;
					--ledBufferAutoInc := (others => '0');
					--ledBufferAutoInc := led_buffer xor ledHolder2;
					ledBufferAutoInc := ledBufferAutoInc or ledHolder2;
				end if;
			end if;
		end if;
	end process;
		
	
	process(latchB)
	begin 
		if rising_edge(latchB) then
			led_Bcolor<=data(7 downto 0);
			led_24color <= led_Gcolor & led_Rcolor & led_Bcolor;
			colorsize :='1';
		end if;
	end process;
	
	process(latchG)
	begin 
		if rising_edge(latchG) then
			led_Gcolor<=data(7 downto 0);
		end if;
	end process;
	
	process(latchR)
	begin 
		if rising_edge(latchR) then
			led_Rcolor<=data(7 downto 0);
			
		end if;
	end process;
	
	
end internals;
