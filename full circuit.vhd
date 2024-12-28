-- OMADA 8
-- p3190031 - Georgiadis Eleftherios
-- p3180284 - Tsiggelis Aristotelis

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity full_circuit is
	generic (n : integer:=16);
	port (input1, input2: in std_logic_vector(n-1 downto 0);
			operation : in std_logic_vector(2 downto 0);
			clock, enable : in std_logic;
			ALUout: out signed(n-1 downto 0);
			ALUcarryOut: out std_logic;
			ff1out, ff2out, ffaluOut : out std_logic_vector(n-1 downto 0));
end full_circuit;

architecture full_circuit_beh of full_circuit is
	component alu is
		port (input1, input2 : in signed(n-1 downto 0);
			opcode   : in std_logic_vector(2 downto 0);
			output   : out signed(n-1 downto 0);
			carryOut : out std_logic);
	end component;
	
	component reg is
		port (input : in std_logic_vector(n-1 downto 0);
			clock, enable : in std_logic;
			output : out std_logic_vector(n-1 downto 0));
	end component;
	
	signal alu_input1, alu_input2, alu_out : signed(n-1 downto 0);
	signal ff1_out, ff2_out, aluout_vector : std_logic_vector(n-1 downto 0);
	
	begin
	
	ff1: reg PORT MAP (input1, clock, enable, ff1_out);
	ff2: reg PORT MAP (input2, clock, enable, ff2_out);
	alu_input1 <= signed(ff1_out); -- we need to split the output of the flip flops to 2 other signals
	ff1out <= ff1_out;
	alu_input2 <= signed(ff2_out); -- same for the other flip flop
	ff2out <= ff2_out;
	run_alu: alu PORT MAP (alu_input1, alu_input2, operation, alu_out, ALUcarryOut);
	aluout_vector <= std_logic_vector(alu_out);  -- same for the output of the alu
	ALUout <= alu_out;
	ff3: reg PORT MAP (aluout_vector, clock, enable, ffaluOut);
	
end full_circuit_beh;