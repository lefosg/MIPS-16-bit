-- OMADA 8
-- p3190031 - Georgiadis Eleftherios
-- p3180284 - Tsiggelis Aristotelis	
 
------------ 1 bit register ------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
entity reg1bit is
	port(d, clk, enable : in std_logic;
		  q: out std_logic);
end reg1bit;

architecture reg1bit_beh of reg1bit is
	component myNand is
		port (a, b : in std_logic;
			output : out std_logic);
	end component;
	
	component myNot is
		port (a : in std_logic;
				f : out std_logic);
	end component;
	
	component myAnd is
		port (a, b :in std_logic;
				f : out std_logic);
	end component;
	
	component myAnd3Bit is
		port (a, b, c : in std_logic;
				output  : out std_logic);
	end component;

	signal p1, p2, p3, p4, five, six, afterClock, temp: std_logic;
	
	begin
		step0: myNand PORT MAP (p1, p4, p3);
		step1: myNand PORT MAP (afterClock, p3, p1);
		step2: myAnd3Bit PORT MAP (afterClock, p1, p4, temp);
		step3: myNot PORT MAP (temp, p2);
		step4: myNand PORT MAP (d, p2, p4);
		step5: myNand PORT MAP (p1, six, five);
		step6: myNand PORT MAP (five, p2, six);
		step7: myAnd PORT MAP (clk, enable, afterClock);
		q <= five;
end reg1bit_beh;

------------ 3 bit register ------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
entity reg3 is 
	generic (n : integer:= 3);
	port (input : in std_logic_vector(n-1 downto 0);
			clock, enable : in std_logic;
			output : out std_logic_vector(n-1 downto 0));
end reg3;

architecture reg3_beh of reg3 is
	component reg1bit is 
		port(d, clk, enable : in std_logic;
			  q: out std_logic);
	end component;
	
	begin
	
	mainLoop: for i in 0 to n-1 generate
		ff: reg1bit PORT MAP (input(i), clock, enable, output(i));
	end generate;
	
end reg3_beh;


------------ 4 bit register ------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
entity reg4 is 
	generic (n : integer:= 4);
	port (input : in std_logic_vector(n-1 downto 0);
			clock, enable : in std_logic;
			output : out std_logic_vector(n-1 downto 0));
end reg4;

architecture reg4_beh of reg4 is
	component reg1bit is 
		port(d, clk, enable : in std_logic;
			  q: out std_logic);
	end component;
	
	begin
	
	mainLoop: for i in 0 to n-1 generate
		ff: reg1bit PORT MAP (input(i), clock, enable, output(i));
	end generate;
	
end reg4_beh;

------------ 12 bit register ------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
entity reg12 is 
	generic (n : integer:= 12);
	port (input : in std_logic_vector(n-1 downto 0);
			clock, enable : in std_logic;
			output : out std_logic_vector(n-1 downto 0));
end reg12;

architecture reg12_beh of reg12 is
	component reg1bit is 
		port(d, clk, enable : in std_logic;
			  q: out std_logic);
	end component;
	
	begin
	
	mainLoop: for i in 0 to n-1 generate
		ff: reg1bit PORT MAP (input(i), clock, enable, output(i));
	end generate;
	
end reg12_beh;

------------ 16 bit register ------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
entity reg16 is 
	generic (n : integer:= 16);
	port (input : in std_logic_vector(n-1 downto 0);
			clock, enable : in std_logic;
			output : out std_logic_vector(n-1 downto 0));
end reg16;

architecture reg16_beh of reg16 is
	component reg1bit is 
		port(d, clk, enable : in std_logic;
			  q: out std_logic);
	end component;
	
	begin
	
	mainLoop: for i in 0 to n-1 generate
		ff: reg1bit PORT MAP (input(i), clock, enable, output(i));
	end generate;
	
end reg16_beh;

------------ Zero Register ------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;

entity reg0 is
generic (n : integer := 16);
	port (input : in std_logic_vector(n-1 downto 0);
			clock, enable: in std_logic;
			output : out std_logic_vector(n-1 downto 0));
end entity reg0;

architecture reg0_beh of reg0 is
begin
	output <= (others => '0');
end architecture reg0_beh;

------------ Register File ------------
library ieee;
use ieee.std_logic_1164.all;

entity regFile is
generic (reg_size : integer := 16;
			reg_index_size : integer := 3;
			num_of_registers : integer := 8
			);
	port (clock : in std_logic;
			Read1AD, Read2AD, Write1AD : in std_logic_vector(reg_index_size-1 downto 0);
			Write1 : in std_logic_vector(reg_size-1 downto 0);
			Read1, Read2 : out std_logic_vector(reg_size-1 downto 0);
			OUTAll : out std_logic_vector(reg_size*num_of_registers-1 downto 0)
			);
end entity regFile;


architecture regFile_beh of regFile is
	-- to decode Read1AD, Read1AD, Write1AD
	component decoder3to8 is
		port ( sel : in STD_LOGIC_VECTOR (reg_index_size-1 downto 0);
				 output : out STD_LOGIC_VECTOR (num_of_registers-1 downto 0));
	end component;
	
	-- to select register after decoding
	component mux8to1 is
		port(input0, input1, input2, input3, input4, input5, input6, input7: in std_logic_vector(reg_size-1 downto 0);
			  choice : in std_logic_vector(reg_index_size-1 downto 0);
			  output : out std_logic_vector(reg_size-1 downto 0));
	end component;
	
	component reg0 is
		port (input : in std_logic_vector(reg_size-1 downto 0);
				enable, clock : in std_logic;
				output : out std_logic_vector(reg_size-1 downto 0));
	end component;
	
	component reg16 is 
		port (input : in std_logic_vector(reg_size-1 downto 0);
				clock, enable : in std_logic;
				output : out std_logic_vector(reg_size-1 downto 0));
	end component;
	
	--signals
	signal enableSigs : std_logic_vector(num_of_registers-1 downto 0);
	signal re0, re1, re2, re3, re4, re5, re6, re7 : std_logic_vector(reg_size-1 downto 0);
	
begin
	
	decoder: decoder3to8 PORT MAP (Write1AD, enableSigs);  -- find register to write to

	register0: reg0 PORT MAP(Write1, clock, enableSigs(0), re0);
	register1: reg16 PORT MAP(Write1, clock, enableSigs(1), re1);
	register2: reg16 PORT MAP(Write1, clock, enableSigs(2), re2);
	register3: reg16 PORT MAP(Write1, clock, enableSigs(3), re3);
	register4: reg16 PORT MAP(Write1, clock, enableSigs(4), re4);
	register5: reg16 PORT MAP(Write1, clock, enableSigs(5), re5);
	register6: reg16 PORT MAP(Write1, clock, enableSigs(6), re6);
----	register7: reg16 PORT MAP(Write1, clock, enableSigs(7), re7);
	
	mux1: mux8to1 PORT MAP (re0, re1, re2, re3, re4, re5, re6, re7, Read1AD, Read1);  -- Read1AD - input = index of Read1 reagister (Read1 - output)
	mux2: mux8to1 PORT MAP (re0, re1, re2, re3, re4, re5, re6, re7, Read2AD, Read2);  -- same for second register

	OUTAll <= re7 & re6 & re5 & re4 & re3 & re2 & re1 & re0;
	
end architecture regFile_beh;















