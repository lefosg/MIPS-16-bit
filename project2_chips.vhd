-- OMADA 8
-- p3190031 - Georgiadis Eleftherios
-- p3180284 - Tsiggelis Aristotelis

------------ Multiplexer 8 to 1 ------------
library ieee;
use ieee.std_logic_1164.all;

entity mux8to1 is
generic (
		n : integer := 16
	);
port(input0, input1, input2, input3, input4, input5, input6, input7: in std_logic_vector(n-1 downto 0);
	  choice : in std_logic_vector(2 downto 0);
	  output : out std_logic_vector(n-1 downto 0));
end mux8to1;

architecture mux8to1_beh of mux8to1 is
begin
	with choice select output<=
		input0 when "000",
		input1 when "001",
		input2 when "010",
		input3 when "011",
		input4 when "100",
		input5 when "101",
		input6 when "110",
		input7 when "111",
		x"0000" when others;
end mux8to1_beh;

------------ Multiplexer 4 to 1 ------------
library ieee;
use ieee.std_logic_1164.all;

entity mux4to1 is
generic (
		n : integer := 16
	);
port(input0, input1, input2, input3 : in std_logic_vector(n-1 downto 0);
	  choice : in std_logic_vector(1 downto 0);
	  output : out std_logic_vector(n-1 downto 0));
end mux4to1;

architecture mux4to1_beh of mux4to1 is
begin
	with choice select output<=
		input0 when "00",
		input1 when "01",
		input2 when "10",
		input3 when others;
end mux4to1_beh;

------------ Multiplexer 2 to 1 ------------
library ieee;
use ieee.std_logic_1164.all;

entity mux2to1 is
	generic ( n : integer := 16 );
	port(input0, input1 : in std_logic_vector(n-1 downto 0);
		  choice : in std_logic;
		  output : out std_logic_vector(n-1 downto 0));
end mux2to1;

architecture mux2to1_beh of mux2to1 is
begin
	with choice select output<=
		input0 when '0',
		input1 when '1',
		x"0000" when others;
end mux2to1_beh;

------------ Decoder 3 to 8 ------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder3to8 is
	port ( sel : in STD_LOGIC_VECTOR (2 downto 0);
			 output : out STD_LOGIC_VECTOR (7 downto 0));
end decoder3to8;

architecture Behavioral of decoder3to8 is
begin
with sel select
	output<="00000001" when "000",
	"00000010" when "001",
	"00000100" when "010",
	"00001000" when "011",
	"00010000" when "100",
	"00100000" when "101",
	"01000000" when "110",
	"10000000" when "111",
	"00000000" when others;
end Behavioral;
------------ Sign Extender ------------
library ieee;
use IEEE.STD_LOGIC_1164.ALL;

entity signExtender is
	generic (
		n: integer :=16;
		k: integer := 6
		);
	port (immediate : in std_logic_vector (k-1 downto 0);
			extended : out std_logic_vector (n-1 downto 0)
			);
end signExtender;

architecture logicfunc of signExtender is
begin 
	extended <= (n-1 downto k=> immediate(k-1)) & (immediate);
end logicfunc;

------------ Jump Address ------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity jumpAD is
generic (
			n : integer := 16;
			k : integer := 12
			);
	port (jumpADR : in std_logic_vector(k-1 downto 0);
			instrP2AD : in std_logic_vector(n-1 downto 0);
			EjumpAD : out std_logic_vector(n-1 downto 0)
			);
end entity jumpAD;

architecture jumpAD_beh of jumpAD is
	signal extended, multed : std_logic_vector(n-1 downto 0);
begin
	extended <= (n-1 downto k => jumpADR(k-1)) & (jumpADR);
	process(instrP2AD) begin
		multed <= extended(n-2 downto 0) & '0';
		EjumpAD <= std_logic_vector( unsigned(multed) + unsigned(instrP2AD));
	end process;
end architecture jumpAD_beh;

------------ ALU Control ------------
library ieee;
use ieee.std_logic_1164.all;

entity aluControl is
	port (opcode : in std_logic_vector(3 downto 0);
			func : in std_logic_vector(2 downto 0);
			output: out std_logic_vector(3 downto 0));
end aluControl;

architecture aluControl_beh of aluControl is
begin
process (opcode, func)
	begin
		case opcode is
			when "0000" =>  -- if opcode is zero its R type instruction
				output(3) <= '0';
				output(2 downto 0) <= func(2 downto 0);
			when others => output <= opcode;  -- else it I/J type instruction
		end case;
	end process;
end aluControl_beh;
