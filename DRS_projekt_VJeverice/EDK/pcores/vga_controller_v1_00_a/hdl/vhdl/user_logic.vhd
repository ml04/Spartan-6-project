------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          user_logic.vhd
-- Version:           1.00.a
-- Description:       User logic.
-- Date:              Tue Dec 08 13:49:13 2015 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

-- DO NOT EDIT BELOW THIS LINE --------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

-- DO NOT EDIT ABOVE THIS LINE --------------------

--USER libraries added here

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--   C_NUM_REG                    -- Number of software accessible registers
--
-- Definition of Ports:
--   Bus2IP_Clk                   -- Bus to IP clock
--   Bus2IP_Reset                 -- Bus to IP reset
--   Bus2IP_Data                  -- Bus to IP data bus
--   Bus2IP_BE                    -- Bus to IP byte enables
--   Bus2IP_RdCE                  -- Bus to IP read chip enable
--   Bus2IP_WrCE                  -- Bus to IP write chip enable
--   IP2Bus_Data                  -- IP to Bus data bus
--   IP2Bus_RdAck                 -- IP to Bus read transfer acknowledgement
--   IP2Bus_WrAck                 -- IP to Bus write transfer acknowledgement
--   IP2Bus_Error                 -- IP to Bus error response
------------------------------------------------------------------------------

entity user_logic is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    --USER generics added here
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_SLV_DWIDTH                   : integer              := 32;
    C_NUM_REG                      : integer              := 10
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    --USER ports added here
	 clk25	:	in		std_logic;
	 rst		:	in		std_logic;
	 rgb_out	:	out	std_logic_vector(0 to 7);
	 hs_out	:	out	std_logic;
	 vs_out	:	out	std_logic;
    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Reset                   : in  std_logic;
    Bus2IP_Data                    : in  std_logic_vector(0 to C_SLV_DWIDTH-1);
    Bus2IP_BE                      : in  std_logic_vector(0 to C_SLV_DWIDTH/8-1);
    Bus2IP_RdCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    Bus2IP_WrCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    IP2Bus_Data                    : out std_logic_vector(0 to C_SLV_DWIDTH-1);
    IP2Bus_RdAck                   : out std_logic;
    IP2Bus_WrAck                   : out std_logic;
    IP2Bus_Error                   : out std_logic
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

  attribute MAX_FANOUT : string;
  attribute SIGIS : string;

  attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
  attribute SIGIS of Bus2IP_Reset  : signal is "RST";

end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is

  --USER signal declarations added here, as needed for user logic
  signal horizontal_counter : std_logic_vector (9 downto 0);-- := "0000000000";
  signal vertical_counter   : std_logic_vector (9 downto 0);-- := "0000000000";
  signal BG_color				 :	std_logic_vector (7 downto 0);
  signal location_x1				 : std_logic_vector (9 downto 0);
  signal finish_x1			 : std_logic_vector (2 downto 0);
  signal location_x2				 : std_logic_vector (9 downto 0);
  signal finish_x2			 : std_logic_vector (2 downto 0);
  signal location_x3				 : std_logic_vector (9 downto 0);
  signal finish_x3			 : std_logic_vector (2 downto 0);
  signal location_x4				 : std_logic_vector (9 downto 0);
  signal finish_x4			 : std_logic_vector (2 downto 0);

  ------------------------------------------
  -- Signals for user logic slave model s/w accessible register example
  ------------------------------------------
  signal slv_reg0                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg1                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg2                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg3                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg4                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg5                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg6                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg7                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg8                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg9                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg_write_sel              : std_logic_vector(0 to 9);
  signal slv_reg_read_sel               : std_logic_vector(0 to 9);
  signal slv_ip2bus_data                : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;

begin

  --USER logic implementation added here
  
  ---- create VGA output @ 480 x 640 resolution ----
	p3: process (rst,clk25)
		begin
			if rst = '1' then
				horizontal_counter <= (others => '0');
				vertical_counter <= (others => '0');
			elsif clk25'event and clk25 = '1' then
	  
			---- here make paintings ----   
			if (horizontal_counter >= "0010010000" ) -- 144
			and (horizontal_counter < "1100010000" ) -- 784
			and (vertical_counter >= "0000100111" )  -- 39
			and (vertical_counter < "1000000111" )   -- 519
			then
			
				
					rgb_out <= "11001100";
					
					if ((horizontal_counter >= 144 + 50) and (horizontal_counter <= 144 + 506) and (vertical_counter >= 39 + 39) and (vertical_counter <= 39 + 41)) 
					or ((horizontal_counter >= 144 + 50) and (horizontal_counter <= 144 + 506) and (vertical_counter >= 39 + 139) and (vertical_counter <= 39 + 141)) 
					or ((horizontal_counter >= 144 + 50) and (horizontal_counter <= 144 + 506) and (vertical_counter >= 39 + 239) and (vertical_counter <= 39 + 241))	
					or ((horizontal_counter >= 144 + 50) and (horizontal_counter <= 144 + 506) and (vertical_counter >= 39 + 339) and (vertical_counter <= 39 + 341)) 
					or ((horizontal_counter >= 144 + 50) and (horizontal_counter <= 144 + 506) and (vertical_counter >= 39 + 439) and (vertical_counter <= 39 + 441)) 
					then
					
					rgb_out <= "11111111";
					
					end if;
					----------------------------igraè 1------------------------
				   --glava
					if((horizontal_counter >= 144 + location_x1 - 3) and (horizontal_counter <= 144 + location_x1 + 3 ) and (vertical_counter >= 39 + 90 - 25) and (vertical_counter <= 39 + 90 - 16)) 
					--vrat
					or ((horizontal_counter >= 144 + location_x1 - 1) and (horizontal_counter <= 144 + location_x1 + 1) and (vertical_counter >= 39 + 90 - 15) and (vertical_counter <= 39 + 90 - 12))
					--tijelo
					or((horizontal_counter >= 144 + location_x1 - 4) and (horizontal_counter <= 144 + location_x1 + 4 ) and (vertical_counter >= 39 + 90 - 12) and (vertical_counter <= 39 + 90 + 3)) 
					--noga 1
					or ((horizontal_counter >= 144 + location_x1 - 4) and (horizontal_counter <= 144 + location_x1 - 2 ) and (vertical_counter >= 39 + 90 + 4) and (vertical_counter <= 39 + 90 + 24))
					--noga 2
					or ((horizontal_counter >= 144 + location_x1 + 2) and (horizontal_counter <= 144 + location_x1 + 4 ) and (vertical_counter >= 39 + 90 + 4) and (vertical_counter <= 39 + 90 + 24))
					--papak 1
					or((horizontal_counter >= 144 + location_x1 - 1) and (horizontal_counter <= 144 + location_x1 ) and (vertical_counter >= 39 + 90 + 22) and (vertical_counter <= 39 + 90 + 24))
					--papak 2
					or((horizontal_counter >= 144 + location_x1 + 5) and (horizontal_counter <= 144 + location_x1 + 7 ) and (vertical_counter >= 39 + 90 + 22) and (vertical_counter <= 39 + 90 + 24))
					-- ruka 1
					or((horizontal_counter = 144 + location_x1 + 5) and (vertical_counter >= 39 + 90 - 11) and(vertical_counter <= 39 + 90 -9))
					or((horizontal_counter = 144 + location_x1 + 6) and (vertical_counter >= 39 + 90 - 12) and(vertical_counter <= 39 + 90 -10))
					or((horizontal_counter = 144 + location_x1 + 7) and (vertical_counter >= 39 + 90 - 13) and(vertical_counter <= 39 + 90 -11))
					or((horizontal_counter = 144 + location_x1 + 8) and (vertical_counter >= 39 + 90 - 14) and(vertical_counter <= 39 + 90 -12))
					--ruka 2
					or((horizontal_counter = 144 + location_x1 + 5) and (vertical_counter >= 39 + 90 - 7) and(vertical_counter <= 39 + 90 -5))
					or((horizontal_counter = 144 + location_x1 + 6) and (vertical_counter >= 39 + 90 - 6) and(vertical_counter <= 39 + 90 -4))
					or((horizontal_counter = 144 + location_x1 + 7) and (vertical_counter >= 39 + 90 - 5) and(vertical_counter <= 39 + 90 -3))
					or((horizontal_counter = 144 + location_x1 + 8) and (vertical_counter >= 39 + 90 - 4) and(vertical_counter <= 39 + 90 -2))
					then
					
					rgb_out <= "11100000";
					
					end if;
					-------------------------------igraè 2------------------------------------------
					--glava
					if((horizontal_counter >= 144 + location_x2 - 3) and (horizontal_counter <= 144 + location_x2 + 3 ) and (vertical_counter >= 39 + 190 - 25) and (vertical_counter <= 39 + 190 - 16)) 
					--vrat
					or ((horizontal_counter >= 144 + location_x2 - 1) and (horizontal_counter <= 144 + location_x2 + 1) and (vertical_counter >= 39 + 190 - 15) and (vertical_counter <= 39 + 190 - 12))
					--tijelo
					or((horizontal_counter >= 144 + location_x2 - 4) and (horizontal_counter <= 144 + location_x2 + 4 ) and (vertical_counter >= 39 + 190 - 12) and (vertical_counter <= 39 + 190 + 3)) 
					--noga 1
					or ((horizontal_counter >= 144 + location_x2 - 4) and (horizontal_counter <= 144 + location_x2 - 2 ) and (vertical_counter >= 39 + 190 + 4) and (vertical_counter <= 39 + 190 + 24))
					--noga 2
					or ((horizontal_counter >= 144 + location_x2 + 2) and (horizontal_counter <= 144 + location_x2 + 4 ) and (vertical_counter >= 39 + 190 + 4) and (vertical_counter <= 39 + 190 + 24))
					--papak 1
					or((horizontal_counter >= 144 + location_x2 - 1) and (horizontal_counter <= 144 + location_x2 ) and (vertical_counter >= 39 + 190 + 22) and (vertical_counter <= 39 + 190 + 24))
					--papak 2
					or((horizontal_counter >= 144 + location_x2 + 5) and (horizontal_counter <= 144 + location_x2 + 7 ) and (vertical_counter >= 39 + 190 + 22) and (vertical_counter <= 39 + 190 + 24))
					-- ruka 1
					or((horizontal_counter = 144 + location_x2 + 5) and (vertical_counter >= 39 + 190 - 11) and(vertical_counter <= 39 + 190 -9))
					or((horizontal_counter = 144 + location_x2 + 6) and (vertical_counter >= 39 + 190 - 12) and(vertical_counter <= 39 + 190 -10))
					or((horizontal_counter = 144 + location_x2 + 7) and (vertical_counter >= 39 + 190 - 13) and(vertical_counter <= 39 + 190 -11))
					or((horizontal_counter = 144 + location_x2 + 8) and (vertical_counter >= 39 + 190 - 14) and(vertical_counter <= 39 + 190 -12))
					--ruka 2
					or((horizontal_counter = 144 + location_x2 + 5) and (vertical_counter >= 39 + 190 - 7) and(vertical_counter <= 39 + 190 -5))
					or((horizontal_counter = 144 + location_x2 + 6) and (vertical_counter >= 39 + 190 - 6) and(vertical_counter <= 39 + 190 -4))
					or((horizontal_counter = 144 + location_x2 + 7) and (vertical_counter >= 39 + 190 - 5) and(vertical_counter <= 39 + 190 -3))
					or((horizontal_counter = 144 + location_x2 + 8) and (vertical_counter >= 39 + 190 - 4) and(vertical_counter <= 39 + 190 -2))
					then
					
					rgb_out <= "11100011";
					
					end if;
					-------------------------igraè 3---------------------------------
					--glava
					if((horizontal_counter >= 144 + location_x3 - 3) and (horizontal_counter <= 144 + location_x3 + 3 ) and (vertical_counter >= 39 + 290 - 25) and (vertical_counter <= 39 + 290 - 16)) 
					--vrat
					or ((horizontal_counter >= 144 + location_x3 - 1) and (horizontal_counter <= 144 + location_x3 + 1) and (vertical_counter >= 39 + 290 - 15) and (vertical_counter <= 39 + 290 - 12))
					--tijelo
					or((horizontal_counter >= 144 + location_x3 - 4) and (horizontal_counter <= 144 + location_x3 + 4 ) and (vertical_counter >= 39 + 290 - 12) and (vertical_counter <= 39 + 290 + 3)) 
					--noga 1
					or ((horizontal_counter >= 144 + location_x3 - 4) and (horizontal_counter <= 144 + location_x3 - 2 ) and (vertical_counter >= 39 + 290 + 4) and (vertical_counter <= 39 + 290 + 24))
					--noga 2
					or ((horizontal_counter >= 144 + location_x3 + 2) and (horizontal_counter <= 144 + location_x3 + 4 ) and (vertical_counter >= 39 + 290 + 4) and (vertical_counter <= 39 + 290 + 24))
					--papak 1
					or((horizontal_counter >= 144 + location_x3 - 1) and (horizontal_counter <= 144 + location_x3 ) and (vertical_counter >= 39 + 290 + 22) and (vertical_counter <= 39 + 290 + 24))
					--papak 2
					or((horizontal_counter >= 144 + location_x3 + 5) and (horizontal_counter <= 144 + location_x3 + 7 ) and (vertical_counter >= 39 + 290 + 22) and (vertical_counter <= 39 + 290 + 24))
					-- ruka 1
					or((horizontal_counter = 144 + location_x3 + 5) and (vertical_counter >= 39 + 290 - 11) and(vertical_counter <= 39 + 290 -9))
					or((horizontal_counter = 144 + location_x3 + 6) and (vertical_counter >= 39 + 290 - 12) and(vertical_counter <= 39 + 290 -10))
					or((horizontal_counter = 144 + location_x3 + 7) and (vertical_counter >= 39 + 290 - 13) and(vertical_counter <= 39 + 290 -11))
					or((horizontal_counter = 144 + location_x3 + 8) and (vertical_counter >= 39 + 290 - 14) and(vertical_counter <= 39 + 290 -12))
					--ruka 2
					or((horizontal_counter = 144 + location_x3 + 5) and (vertical_counter >= 39 + 290 - 7) and(vertical_counter <= 39 + 290 -5))
					or((horizontal_counter = 144 + location_x3 + 6) and (vertical_counter >= 39 + 290 - 6) and(vertical_counter <= 39 + 290 -4))
					or((horizontal_counter = 144 + location_x3 + 7) and (vertical_counter >= 39 + 290 - 5) and(vertical_counter <= 39 + 290 -3))
					or((horizontal_counter = 144 + location_x3 + 8) and (vertical_counter >= 39 + 290 - 4) and(vertical_counter <= 39 + 290 -2))
					then
					
					rgb_out <= "00000000";
					
					end if;
					----------------------------------igraè 4-------------------------------
					--glava
					if((horizontal_counter >= 144 + location_x4 - 3) and (horizontal_counter <= 144 + location_x4 + 3 ) and (vertical_counter >= 39 + 390 - 25) and (vertical_counter <= 39 + 390 - 16)) 
					--vrat
					or ((horizontal_counter >= 144 + location_x4 - 1) and (horizontal_counter <= 144 + location_x4 + 1) and (vertical_counter >= 39 + 390 - 15) and (vertical_counter <= 39 + 390 - 12))
					--tijelo
					or((horizontal_counter >= 144 + location_x4 - 4) and (horizontal_counter <= 144 + location_x4 + 4 ) and (vertical_counter >= 39 + 390 - 12) and (vertical_counter <= 39 + 390 + 3)) 
					--noga 1
					or ((horizontal_counter >= 144 + location_x4 - 4) and (horizontal_counter <= 144 + location_x4 - 2 ) and (vertical_counter >= 39 + 390 + 4) and (vertical_counter <= 39 + 390 + 24))
					--noga 2
					or ((horizontal_counter >= 144 + location_x4 + 2) and (horizontal_counter <= 144 + location_x4 + 4 ) and (vertical_counter >= 39 + 390 + 4) and (vertical_counter <= 39 + 390 + 24))
					--papak 1
					or((horizontal_counter >= 144 + location_x4 - 1) and (horizontal_counter <= 144 + location_x4 ) and (vertical_counter >= 39 + 390 + 22) and (vertical_counter <= 39 + 390 + 24))
					--papak 2
					or((horizontal_counter >= 144 + location_x4 + 5) and (horizontal_counter <= 144 + location_x4 + 7 ) and (vertical_counter >= 39 + 390 + 22) and (vertical_counter <= 39 + 390 + 24))
					-- ruka 1
					or((horizontal_counter = 144 + location_x4 + 5) and (vertical_counter >= 39 + 390 - 11) and(vertical_counter <= 39 + 390 -9))
					or((horizontal_counter = 144 + location_x4 + 6) and (vertical_counter >= 39 + 390 - 12) and(vertical_counter <= 39 + 390 -10))
					or((horizontal_counter = 144 + location_x4 + 7) and (vertical_counter >= 39 + 390 - 13) and(vertical_counter <= 39 + 390 -11))
					or((horizontal_counter = 144 + location_x4 + 8) and (vertical_counter >= 39 + 390 - 14) and(vertical_counter <= 39 + 390 -12))
					--ruka 2
					or((horizontal_counter = 144 + location_x4 + 5) and (vertical_counter >= 39 + 390 - 7) and(vertical_counter <= 39 + 390 -5))
					or((horizontal_counter = 144 + location_x4 + 6) and (vertical_counter >= 39 + 390 - 6) and(vertical_counter <= 39 + 390 -4))
					or((horizontal_counter = 144 + location_x4 + 7) and (vertical_counter >= 39 + 390 - 5) and(vertical_counter <= 39 + 390 -3))
					or((horizontal_counter = 144 + location_x4 + 8) and (vertical_counter >= 39 + 390 - 4) and(vertical_counter <= 39 + 390 -2))
					then
					
					rgb_out <= "00000011";
					
					end if;
					
					--------------------------------------poredak 1----------------------------
					if (finish_x1 = "001")
					then
						if ((horizontal_counter >= 144 + 590) and (horizontal_counter <= 144 + 600) and (vertical_counter >= 39 + 90 - 30) and (vertical_counter <= 39 + 90 + 30))
						then
					
						rgb_out <= "00000000";
						end if;
					
					
					elsif (finish_x1 = "010")
					then
						if ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 90 - 30) and (vertical_counter <= 39 + 90 - 20))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 90 - 20) and (vertical_counter <= 39 + 90 - 5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 90 -5) and (vertical_counter <= 39 + 90 +5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 590) and (vertical_counter >= 39 + 90 +5) and (vertical_counter <= 39 + 90 + 20))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 90 + 20) and (vertical_counter <= 39 + 90 + 30))
						then
						
						rgb_out <= "00000000";
						end if;
					
					
					elsif (finish_x1 = "011")
					then
						if ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 90 - 30) and (vertical_counter <= 39 + 90 - 20))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 90 - 20) and (vertical_counter <= 39 + 90 - 5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 90 -5) and (vertical_counter <= 39 + 90 +5))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 90 +5) and (vertical_counter <= 39 + 90 + 20))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 90 + 20) and (vertical_counter <= 39 + 90 + 30))
						then
						
						rgb_out <= "00000000";
						end if;
						
					elsif (finish_x1 = "100")
					then
						if ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 590) and (vertical_counter >= 39 + 90 - 30) and (vertical_counter <= 39 + 90 - 5))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 90 - 30) and (vertical_counter <= 39 + 90 - 5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 90 -5) and (vertical_counter <= 39 + 90 +5))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 90 +5) and (vertical_counter <= 39 + 90 + 30))
						then
						
						rgb_out <= "00000000";
						end if;
					
					end if;
					
					---------------------------------------poredak 2-------------------------------------------
					if (finish_x2 = "001")
					then
						if ((horizontal_counter >= 144 + 590) and (horizontal_counter <= 144 + 600) and (vertical_counter >= 39 + 190 - 30) and (vertical_counter <= 39 + 190 + 30))
						then
					
						rgb_out <= "00000000";
						end if;
					
					
					elsif (finish_x2 = "010")
					then
						if ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 190 - 30) and (vertical_counter <= 39 + 190 - 20))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 190 - 20) and (vertical_counter <= 39 + 190 - 5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 190 -5) and (vertical_counter <= 39 + 190 +5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 590) and (vertical_counter >= 39 + 190 +5) and (vertical_counter <= 39 + 190 + 20))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 190 + 20) and (vertical_counter <= 39 + 190 + 30))
						then
						
						rgb_out <= "00000000";
						end if;
					
					
					elsif (finish_x2 = "011")
					then
						if ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 190 - 30) and (vertical_counter <= 39 + 190 - 20))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 190 - 20) and (vertical_counter <= 39 + 190 - 5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 190 -5) and (vertical_counter <= 39 + 190 +5))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 190 +5) and (vertical_counter <= 39 + 190 + 20))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 190 + 20) and (vertical_counter <= 39 + 190 + 30))
						then
						
						rgb_out <= "00000000";
						end if;
						
					elsif (finish_x2 = "100")
					then
						if ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 590) and (vertical_counter >= 39 + 190 - 30) and (vertical_counter <= 39 + 190 - 5))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 190 - 30) and (vertical_counter <= 39 + 190 - 5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 190 -5) and (vertical_counter <= 39 + 190 +5))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 190 +5) and (vertical_counter <= 39 + 190 + 30))
						then
						
						rgb_out <= "00000000";
						end if;
					
					end if;
					
					---------------------------------poredak 3----------------------------------------------------
					if (finish_x3 = "001")
					then
						if ((horizontal_counter >= 144 + 590) and (horizontal_counter <= 144 + 600) and (vertical_counter >= 39 + 290 - 30) and (vertical_counter <= 39 + 290 + 30))
						then
					
						rgb_out <= "00000000";
						end if;
					
					
					elsif (finish_x3 = "010")
					then
						if ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 290 - 30) and (vertical_counter <= 39 + 290 - 20))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 290 - 20) and (vertical_counter <= 39 + 290 - 5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 290 -5) and (vertical_counter <= 39 + 290 +5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 590) and (vertical_counter >= 39 + 290 +5) and (vertical_counter <= 39 + 290 + 20))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 290 + 20) and (vertical_counter <= 39 + 290 + 30))
						then
						
						rgb_out <= "00000000";
						end if;
					
					
					elsif (finish_x3 = "011")
					then
						if ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 290 - 30) and (vertical_counter <= 39 + 290 - 20))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 290 - 20) and (vertical_counter <= 39 + 290 - 5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 290 -5) and (vertical_counter <= 39 + 290 +5))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 290 +5) and (vertical_counter <= 39 + 290 + 20))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 290 + 20) and (vertical_counter <= 39 + 290 + 30))
						then
						
						rgb_out <= "00000000";
						end if;
						
					elsif (finish_x3 = "100")
					then
						if ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 590) and (vertical_counter >= 39 + 290 - 30) and (vertical_counter <= 39 + 290 - 5))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 290 - 30) and (vertical_counter <= 39 + 290 - 5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 290 -5) and (vertical_counter <= 39 + 290 +5))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 290 +5) and (vertical_counter <= 39 + 290 + 30))
						then
						
						rgb_out <= "00000000";
						end if;
					
					end if;
					
					------------------------------------poredak 4-----------------------------------------------
					
					if (finish_x4 = "001")
					then
						if ((horizontal_counter >= 144 + 590) and (horizontal_counter <= 144 + 600) and (vertical_counter >= 39 + 390 - 30) and (vertical_counter <= 39 + 390 + 30))
						then
					
						rgb_out <= "00000000";
						end if;
					
					
					elsif (finish_x4 = "010")
					then
						if ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 390 - 30) and (vertical_counter <= 39 + 390 - 20))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 390 - 20) and (vertical_counter <= 39 + 390 - 5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 390 -5) and (vertical_counter <= 39 + 390 +5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 590) and (vertical_counter >= 39 + 390 +5) and (vertical_counter <= 39 + 390 + 20))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 390 + 20) and (vertical_counter <= 39 + 390 + 30))
						then
						
						rgb_out <= "00000000";
						end if;
					
					
					elsif (finish_x4 = "011")
					then
						if ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 390 - 30) and (vertical_counter <= 39 + 390 - 20))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 390 - 20) and (vertical_counter <= 39 + 390 - 5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 390 -5) and (vertical_counter <= 39 + 390 +5))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 390 +5) and (vertical_counter <= 39 + 390 + 20))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 390 + 20) and (vertical_counter <= 39 + 390 + 30))
						then
						
						rgb_out <= "00000000";
						end if;
						
					elsif (finish_x4 = "100")
					then
						if ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 590) and (vertical_counter >= 39 + 390 - 30) and (vertical_counter <= 39 + 390 - 5))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 390 - 30) and (vertical_counter <= 39 + 390 - 5))
						or ((horizontal_counter >= 144 + 580) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 390 -5) and (vertical_counter <= 39 + 390 +5))
						or ((horizontal_counter >= 144 + 610) and (horizontal_counter <= 144 + 620) and (vertical_counter >= 39 + 390 +5) and (vertical_counter <= 39 + 390 + 30))
						then
						
						rgb_out <= "00000000";
						end if;
					
					end if;
					
	
					--if (horizontal_counter >= 144 + location) and (horizontal_counter <= 144 + location + 100) and (vertical_counter = 100) then
					--rgb_out <= "00000000";
					--end if;
				
			else
				rgb_out <= (others => '0');
			end if;
    
			---- horizontal an vertical synchronization ----
			if (horizontal_counter > "0000000000" )
				and (horizontal_counter < "0001100001" ) -- 96+1
			then
				hs_out <= '0';
			else
				hs_out <= '1';
			end if;
			if (vertical_counter > "0000000000" )
				and (vertical_counter < "0000000011" ) -- 2+1
			then
				vs_out <= '0';
			else
				vs_out <= '1';
			end if;
		
			---- horizontal and vertical counters ----
			horizontal_counter <= horizontal_counter + 1;
			if (horizontal_counter="1100100000") then
				vertical_counter <= vertical_counter + 1;
				horizontal_counter <= "0000000000";
			end if;
			if (vertical_counter="1000001001") then
				vertical_counter <= "0000000000";
			end if;
		end if;
	end process;

  ------------------------------------------
  -- Example code to read/write user logic slave model s/w accessible registers
  -- 
  -- Note:
  -- The example code presented here is to show you one way of reading/writing
  -- software accessible registers implemented in the user logic slave model.
  -- Each bit of the Bus2IP_WrCE/Bus2IP_RdCE signals is configured to correspond
  -- to one software accessible register by the top level template. For example,
  -- if you have four 32 bit software accessible registers in the user logic,
  -- you are basically operating on the following memory mapped registers:
  -- 
  --    Bus2IP_WrCE/Bus2IP_RdCE   Memory Mapped Register
  --                     "1000"   C_BASEADDR + 0x0
  --                     "0100"   C_BASEADDR + 0x4
  --                     "0010"   C_BASEADDR + 0x8
  --                     "0001"   C_BASEADDR + 0xC
  -- 
  ------------------------------------------
  slv_reg_write_sel <= Bus2IP_WrCE(0 to 9);
  slv_reg_read_sel  <= Bus2IP_RdCE(0 to 9);
  slv_write_ack     <= Bus2IP_WrCE(0) or Bus2IP_WrCE(1) or Bus2IP_WrCE(2) or Bus2IP_WrCE(3) or Bus2IP_WrCE(4) or Bus2IP_WrCE(5) or Bus2IP_WrCE(6) or Bus2IP_WrCE(7) or Bus2IP_WrCE(8) or Bus2IP_WrCE(9);
  slv_read_ack      <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1) or Bus2IP_RdCE(2) or Bus2IP_RdCE(3) or Bus2IP_RdCE(4) or Bus2IP_RdCE(5) or Bus2IP_RdCE(6) or Bus2IP_RdCE(7) or Bus2IP_RdCE(8) or Bus2IP_RdCE(9);

  -- implement slave model software accessible register(s)
  SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  begin

    if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
      if Bus2IP_Reset = '1' then
        slv_reg0 <= (others => '0');
        slv_reg1 <= (others => '0');
        slv_reg2 <= (others => '0');
        slv_reg3 <= (others => '0');
        slv_reg4 <= (others => '0');
        slv_reg5 <= (others => '0');
        slv_reg6 <= (others => '0');
        slv_reg7 <= (others => '0');
        slv_reg8 <= (others => '0');
        slv_reg9 <= (others => '0');
      else
        case slv_reg_write_sel is
          when "1000000000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg0(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0100000000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg1(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0010000000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg2(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0001000000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg3(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0000100000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg4(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0000010000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg5(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0000001000" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg6(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0000000100" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg7(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0000000010" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg8(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "0000000001" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg9(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when others => null;
        end case;
      end if;
    end if;

  end process SLAVE_REG_WRITE_PROC;
  
 --BG_color <= slv_reg0(24 to 31);
 --location <= slv_reg1(22 to 31);
 
 BG_color <= slv_reg0(24 to 31);
 location_x1 <= slv_reg1(22 to 31);
 finish_x1 <= slv_reg2(29 to 31);
 location_x2 <= slv_reg3(22 to 31);
 finish_x2 <= slv_reg4(29 to 31);
 location_x3 <= slv_reg5(22 to 31);
 finish_x3 <= slv_reg6(29 to 31);
 location_x4 <= slv_reg7(22 to 31);
 finish_x4 <= slv_reg8(29 to 31);

  -- implement slave model software accessible register(s) read mux
  SLAVE_REG_READ_PROC : process( slv_reg_read_sel, slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4, slv_reg5, slv_reg6, slv_reg7, slv_reg8, slv_reg9 ) is
  begin

    case slv_reg_read_sel is
      when "1000000000" => slv_ip2bus_data <= slv_reg0;
      when "0100000000" => slv_ip2bus_data <= slv_reg1;
      when "0010000000" => slv_ip2bus_data <= slv_reg2;
      when "0001000000" => slv_ip2bus_data <= slv_reg3;
      when "0000100000" => slv_ip2bus_data <= slv_reg4;
      when "0000010000" => slv_ip2bus_data <= slv_reg5;
      when "0000001000" => slv_ip2bus_data <= slv_reg6;
      when "0000000100" => slv_ip2bus_data <= slv_reg7;
      when "0000000010" => slv_ip2bus_data <= slv_reg8;
      when "0000000001" => slv_ip2bus_data <= slv_reg9;
      when others => slv_ip2bus_data <= (others => '0');
    end case;

  end process SLAVE_REG_READ_PROC;

  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
  IP2Bus_Data  <= slv_ip2bus_data when slv_read_ack = '1' else
                  (others => '0');

  IP2Bus_WrAck <= slv_write_ack;
  IP2Bus_RdAck <= slv_read_ack;
  IP2Bus_Error <= '0';

end IMP;
