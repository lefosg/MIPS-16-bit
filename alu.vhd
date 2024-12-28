-- OMADA 8
-- p3190031 - Georgiadis Eleftherios
-- p3180284 - Tsiggelis Aristotelis

------------ Invert Vector ------------

--Inverts the magnitude of the number (multiplies by one)
--First we invert all the bits, then add 1
--If opcode is ADD (000) then return input, else return the inverted input

LIBRARY ieee ;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity invert is
	generic (n : integer:= 16;
				opcode_len : integer := 4);
	port (input : in signed(n-1 downto 0);
		  opcode : in std_logic_vector(opcode_len-1 downto 0);
			output: out signed(n-1 downto 0));
end invert;

architecture invert_beh of invert is
	
	component myNot is
		port (a : in std_logic;
				f : out std_logic);
	end component;
	
	component fullAdder is
		port (A, B, carryIn :in std_logic;
					sum, carryOut :out std_logic);
	end component;

	signal inverted_input, temp_output, one : signed(n-1 downto 0);
	signal carryTransfer : std_logic_vector(n downto 0);
	
	begin
	-- negate the bits
	forloop1: for i in 0 to n-1 generate
		notGate: myNot PORT MAP (input(i), inverted_input(i));
	end generate;
	-- add one
	one <= x"0001";
	forloop2: for i in 0 to n-1 generate
		addOne: fullAdder PORT MAP (inverted_input(i), one(i), carryTransfer(i), temp_output(i), carryTransfer(i+1));
	end generate;
	
	with opcode select output <=
		input when "0010",  --ADD
		temp_output when "0011",  --SUB
		NULL when others;

end invert_beh;

------------ Greater Or Equal Circuit -------------

--Checks the magnitude of a given number
--If positive, return 1, else return 0

LIBRARY ieee ;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity geq is
	generic (n : integer:= 16);
	port(input  : in signed(n-1 downto 0);
		  output : out std_logic_vector(n-1 downto 0));
end geq;

architecture geq_beh of geq is
signal u_input : std_logic_vector(n-1 downto 0);
begin
	process (input)
	begin
		u_input <= std_logic_vector(input);
		if input(n-1) = '0' then  -- if the msb of a two's complement number is 0 => positive, else negative
			output <= x"0001";
		else
			output <= x"0000";
		end if;
	end process;
end geq_beh;

------------ Not Operation ------------

--If input = 0 return 000..01 else return 000..00

LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
use ieee.numeric_std.all;
entity notOperation is
	generic (n : integer:= 16);
	port (input : in signed(n-1 downto 0);
			output: out std_logic_vector(n-1 downto 0));
end notOperation;

architecture notOperation_beh of notOperation is
signal u_input : std_logic_vector(n-1 downto 0);
	begin
	process (input)
		begin
		u_input <= std_logic_vector(input);
			if (input = x"0000") then
				output <= x"0001";
			else
				output <= x"0000";
			end if;
	end process;
end notOperation_beh;

------------ Full Adder -------------

--Adds 2 bits

LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
entity fullAdder is
	port (A, B, carryIn :in std_logic;
				sum, carryOut :out std_logic);
end fullAdder;

architecture fullAdder_beh of fullAdder is

	component myAnd
	port (a, b :in std_logic;
			f : out std_logic);
	end component;
	
	component myOr
	port (a, b :in std_logic;
			f : out std_logic);
	end component;
	
	component myXor
	port (a, b :in std_logic;
			f : out std_logic); 
	end component;

	signal ab_sum, abcin, ab : std_logic;
	begin
	-- sum <= a xor b xor cin
	-- carryOut <= (a and b) or (b and carryIn) or (a and carryIn)
	-- start with sum calculation
	ADD_A_B:    myXor PORT MAP (A,B,ab_sum);
	ADD_AB_CIN: myXor PORT MAP (ab_sum, carryIn, sum);
	-- now the carryOut calculation
	AB_AND_CIN: myAnd PORT MAP (ab_sum, carryIn, abcin);
	A_AND_B:    myAnd PORT MAP (A, B, ab);
	CARRY_OUT:  myOr PORT MAP (ab, abcin, carryOut);
end fullAdder_beh;
		
------------ Full Adder, And, Or Basic Circuit ------------

--Includes the ADD, SUB, AND, OR operations

LIBRARY ieee;
USE ieee.std_logic_1164.all; 
entity and_or_add_circuit is
generic (opcode_len: integer := 4);
	port(a, b, carryIn    : in std_logic;
		  result, carryOut : out std_logic;
		  operation : in std_logic_vector(opcode_len-1 downto 0));
end and_or_add_circuit;

architecture and_or_add_circuit_functionality of and_or_add_circuit is
	
	component fullAdder is
		port (A, B, carryIn :in std_logic;
				sum, carryOut :out std_logic);
	end component;
	
	component myAnd is
		port (a, b : in std_logic;
				f    : out std_logic);
	end component;
	
	component myOr is
		port (a, b : in std_logic;
				f    : out std_logic);
	end component;
		
	signal sum, and_result, or_result : std_logic;
	begin
	
		adder: fullAdder PORT MAP (a, b, carryIn, sum, carryOut); 
		my_and: myAnd PORT MAP (a, b, and_result);
		my_or: myOr PORT MAP (a, b, or_result);
		
		with operation select result <=
			and_result when "0000",    --AND
			or_result when "0001",     --OR
			sum when "0010" | "0011",  --ADD/SUB
			NULL when others;
end and_or_add_circuit_functionality;
		
		
------------ 16 bit alu ------------

--16 bit alu that executes the commands ADD, SUB, AND, OR, GEQ, NOT

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity alu is
	generic (n : integer:= 16;  -- n is the length of the input
				opcode_len : integer := 4
				);
	port (input1, input2 : in signed(n-1 downto 0);
			opcode : in std_logic_vector(opcode_len-1 downto 0);
			output   : out signed(n-1 downto 0);
			carryOut : out std_logic);
	end alu;

architecture alu_functionality of alu is

	component and_or_add_circuit is
		port(a, b, carryIn : in std_logic;
		  result, carryOut : out std_logic;
		  operation : in std_logic_vector(opcode_len-1 downto 0));
	end component;

	component geq is
		port(input    : in signed(n-1 downto 0);
			  output : out std_logic_vector(n-1 downto 0));
	end component;
	
	component notOperation is
		port (input : in signed(n-1 downto 0);
				output: out std_logic_vector(n-1 downto 0));
	end component;
	
	component invert is
		port (input : in signed(n-1 downto 0);
			  opcode : in std_logic_vector(opcode_len-1 downto 0);
			   output: out signed(n-1 downto 0));
	end component;

	signal carry_transfer : std_logic_vector(n downto 0);
	signal inverted_input2 : signed(n-1 downto 0);
	signal temp_sum, temp_geq, temp_not: std_logic_vector(n-1 downto 0);

begin
	invert_b: invert PORT MAP (input2, opcode, inverted_input2);
	carry_transfer(0) <= '0';
	mainLoop: for i in 0 to n-1 generate
		  run: 	and_or_add_circuit PORT MAP (input1(i), inverted_input2(i), carry_transfer(i), temp_sum(i), carry_transfer(i+1), opcode);
	end generate;
	carryOut <= carry_transfer(n);
	greater_equal: geq PORT MAP (input1, temp_geq);
	not_operation: notOperation PORT MAP(input1, temp_not);
	
	with opcode select output <=
		signed(temp_sum) when "0000" | "0001" | "0010" | "0011",
		signed(temp_geq) when "0101",
		signed(temp_not) when "0110",
		NULL when others;

end alu_functionality;