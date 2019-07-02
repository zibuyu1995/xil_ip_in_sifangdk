LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity irigb_decoder is
port 
(	
		Clk10KHz			: in std_logic;	--10Khz
		Clk         			: in std_logic;		--1KHz
		Reset       		: in std_logic;
		RX              		: in  std_logic;
		--------------------------------------------------------------
		UpdataFlag      : out std_logic;				
		--------------------------------------------------------------
		SECONDS	    : out std_logic_vector(6 downto 0);
		MINUTES			: out std_logic_vector(6 downto 0);
		HOURS			: out std_logic_vector(5 downto 0);
		DAYS				: out std_logic_vector(9 downto 0);		
		
		YEARS				: out std_logic_vector(7 downto 0);
		CNTLS				: out std_logic_vector(17 downto 0);
		SBS					: out std_logic_vector(16 downto 0)

);

end irigb_decoder;

architecture IMP of irigb_decoder is

  type STATE_TYPE is (stIdley, stCatchData,stCatchData1,stDataValid);
  signal State   : STATE_TYPE;

  signal serial_to_Par 	: std_logic_vector(99 downto 0);
  signal RxQ      		: std_logic_vector(0 to 19);

  signal CMDSynCaught	: std_logic;

  signal BitValue	:	 std_logic;
  signal BitPaternValid	:	 std_logic;
  signal BitSamplePoint	:	 std_logic;
  signal timer			: integer range 0 to 127;
  signal BitCount	: std_logic_vector(7 downto 0);
  signal FrameError	:	 std_logic;

  signal CMD_Data,POINTSYNC	:	 std_logic;

  signal TIMER_PROCESS  	: std_logic;		
			
  constant SynEndPoint: integer := 0; 	
  constant BitSamplePeriod: integer := 9; 	
	
  signal IRIG_RXQ      		: std_logic_vector(9 downto 0);
  signal	irig_rise,irig_fall,irig_ttl:std_logic;

begin  
--**************************
	process(Clk10KHz,Reset)
	begin
		if Reset='1' then
    		IRIG_RXQ <= "0000000000";
		elsif Clk10KHz 'event and Clk10KHz='1' then
			IRIG_RXQ(0)<=Rx;
			for I in 1 to 9 loop
	    		IRIG_RXQ(I) <= IRIG_RXQ(I-1);
    		end loop;			
		end if;
	end process;
	
	--------------------------
	process(Clk10KHz,Reset)
	begin
		if Reset='1' then
    		irig_rise<='1';
		elsif Clk10KHz 'event and Clk10KHz='1' then
			if IRIG_RXQ(4 downto 0)="11111"  then
				irig_rise<='1';
			else
				irig_rise<='0';
			end if;			
		end if;
	end process;
	

	process(Clk10KHz,Reset)
	begin
		if Reset='1' then
    		irig_fall<='0';
		elsif Clk10KHz 'event and Clk10KHz='1' then
			if IRIG_RXQ(4 downto 0)="00000"  then
				irig_fall<='1';
			else
				irig_fall<='0';
			end if;			
		end if;
	end process;

	
	process(irig_rise,Reset,irig_fall)
	begin
		if Reset='1' or irig_fall='1' then
    		irig_ttl<='0';
		elsif irig_rise 'event and irig_rise='1' then
			irig_ttl<='1';
		end if;
	end process;
	--*************************
	process(Clk, Reset)
	begin
		if (Reset = '1') then
    		RxQ <= "00000000000000000000";
    	elsif Clk'event and Clk = '1' then  -- rising clock edge
    		RxQ(0) <= irig_ttl;
			for I in 1 to 19 loop
	    		RxQ(I) <= RxQ(I-1);
    		end loop;
    	end if;
	end process;
	
	CMDSynCaught <= '1' when RxQ(3 to 8) ="111111" and (RxQ(0) ='0' or RxQ(1) ='0') and  RxQ(13 to 18) ="111111" and (RxQ(10) ='0' or RxQ(11) ='0') else '0';

	process(Clk,Reset)
	begin
		if (Reset = '1') then
			BitValue <= '0';
			BitPaternValid <='0';

			POINTSYNC<='0';							
			
    	elsif Clk'event and Clk = '1' then  -- rising clock edge

			POINTSYNC<='0';							

			if RxQ(1 to 3)="000" and RxQ(6 to 8) ="111" then--value 1			
				BitValue <= '1';
				BitPaternValid <='1';
			elsif (RxQ(8) = '1' or RxQ(9) = '1') and RxQ(1 to 6) ="000000" then--value 0
				BitValue <= '0';
				BitPaternValid <='1';														
			elsif RxQ(3 to 8) = "111111" and (RxQ(0) ='0' or RxQ(1) ='0') then	--point
				BitValue <= '0';
				BitPaternValid <='1';		
				POINTSYNC<='1';
			else			
				BitValue <= '0';
				BitPaternValid <= '0';
				POINTSYNC<='0';				
			end if;		
		end if;
	end process;
		
	process(Clk,Reset)
	begin
	if (Reset = '1') then
		FrameError<='0';
    elsif Clk'event and Clk = '1' then  -- rising clock edge

		FrameError<='0';
		
		if BitSamplePoint='1' then
			if POINTSYNC='0' then
				if BitPaternValid = '1' then														
					serial_to_Par(CONV_INTEGER(BitCount-1))<=BitValue;						
				else
					FrameError<='1';
				end if;
			end if;
		end if;
		
	end if;
	end process;
	
	process(Clk, Reset,FrameError)
	begin
		if (Reset = '1')  or (FrameError='1') then
		
			State <= stIdley;
			Timer <= 0;
			BitCount <= X"00";		
			BitSamplePoint<='0';

		--	CMD_Data<='0';
			
			UpdataFlag<='0';
			TIMER_PROCESS<='0';
			
    	elsif Clk'event and Clk = '1' then  -- rising clock edge
						
			UpdataFlag<='0';
									
    		case State is
    			when stIdley =>			--sync header searching

					BitSamplePoint <= '0';
					
    				if CMDSynCaught='1'  then
    		--			CMD_Data <= '1';
						State <= stCatchData;
						Timer <= 0;	
						TIMER_PROCESS<='1';	
    				end if;

    				
    			when stCatchData =>				--sync searched		

					if timer = SynEndPoint then
						BitCount <=X"00";
						State <= stCatchData1;
						timer <= 0;
					else
						timer <= timer +1;	
					end if;
					
    			when stCatchData1 =>
					BitSamplePoint <= '0';
					if timer = BitSamplePeriod then					
						timer <= 0;
						
						BitCount <= BitCount+1;							
						BitSamplePoint <= '1';	
							
						if BitCount = X"61" then	--98 bit
							State <= stDataValid;									
						end if;																										
					
					else
						timer <= timer +1;	
					end if;	
					
    			when stDataValid =>
					State <= stIdley;
					UpdataFlag<='1';
					TIMER_PROCESS<='0';
					
					SECONDS(3 downto 0)<=serial_to_Par(3 downto 0);
					SECONDS(6 downto 4)<=serial_to_Par(7 downto 5);					
					
					MINUTES(3 downto 0)<=serial_to_Par(12 downto 9);					
					MINUTES(6 downto 4)<=serial_to_Par(16 downto 14);										
					

					HOURS(3 downto 0)<=serial_to_Par(22 downto 19);
					HOURS(5 downto 4)<=serial_to_Par(25 downto 24);					
					
					DAYS(3 downto 0)<=serial_to_Par(32 downto 29);
					DAYS(7 downto 4)<=serial_to_Par(37 downto 34);
					DAYS(9 downto 8)<=serial_to_Par(40 downto 39);

					YEARS(3 downto 0)<=serial_to_Par(52 downto 49);
					YEARS(7 downto 4)<=serial_to_Par(57 downto 54);
					
					CNTLS(8 downto 0)<=serial_to_Par(67 downto 59);
					CNTLS(17 downto 9)<=serial_to_Par(77 downto 69);
					
					SBS(8 downto 0)<=serial_to_Par(87 downto 79);
					SBS(16 downto 9)<=serial_to_Par(96 downto 89);
					
				when others =>	
					State <= stIdley;																					
				end case;			
							
    	end if;
	end process;

end IMP;