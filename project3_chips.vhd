------------ Controller ------------

library ieee; 
use ieee.std_logic_1164.all;

entity controller is 
port (opCode : IN STD_LOGIC_VECTOR (3 downto 0);
func : IN STD_LOGIC_VECTOR (2 downto 0);
flush : IN STD_LOGIC;
isMPFC, isJumpD, isReadDigit, isPrintDigit, isR, isLW, isSW, isBranch, isJR : OUT STD_LOGIC
);
END controller;

architecture rtl of controller is
begin 
	get_result : process(flush, func, opCode) begin
		if flush = '1' then 
			isR <= '0';
			isMPFC <='0';
			isLW <= '0';
			isSW <= '0';
			isBranch <= '0';
			isReadDigit<='0';
			isPrintDigit <='0';
			isJumpD <= '0';
			isJR <= '0';
		end if;

		if flush = '0' then
			case opCode is when "0000" =>
				isR <= '1';
				if func = "1111" then 
					isMPFC <= '1';
				end if;
				when "0001" => isLW <='1';
				when "0010" => isSW <='1';
				when "0100" => isBranch <='1';
				when "0110" => isReadDigit <='1';
				when "0111" => isPrintDigit <= '1';
				when "1111" => isJumpD <= '1';
				when "1101" => isJR <= '1';
				when others => isR <='0';
			end case ;
		end if;
	end process;
end architecture rtl;

------------ Forwarder ------------

library ieee;
use ieee.std_logic_1164.all;

entity Forwarder is
generic (addr_size : INTEGER := 3);
	port (R1AD,R2AD, RegAD_EXMEM, RegAD_MEMWB : IN STD_LOGIC_VECTOR (addr_size-1 downto 0);
			S1, S2 : OUT STD_LOGIC_VECTOR(1 downto 0));
end entity Forwarder;

architecture behave of Forwarder is 
begin 
	process (RegAD_EXMEM, RegAD_MEMWB, R1AD, R2AD)
	begin
		S1 <= "00";
		S2 <= "00";
		if (R1AD = RegAD_EXMEM) then 
			S1 <= "10";
		elsif (R1AD = RegAD_MEMWB) then
			S1 <= "01";
		end if;
		if (R2AD = RegAD_EXMEM) then
			S2 <= "10";
		elsif (R2AD = RegAD_MEMWB) then 
			S2 <= "01";
		end if;
	end process;
end architecture behave;

------------ Hazard Unit ------------

library ieee;
use ieee.std_logic_1164.all;

entity hazardUnit is 
	port (isJR, isJump, wasJump, mustBranch : IN STD_LOGIC;
			flush, wasJumpOut : OUT STD_LOGIC;
			jRopcode : OUT STD_LOGIC_VECTOR (1 downto 0)
			);
end hazardUnit;

architecture behavior of hazardUnit is 
begin 
	process (isJR, isJump, wasJump, mustBranch)
	begin 
		flush <='0';
		if isJR= '1' OR isJump = '1' OR wasJump = '1' OR mustBranch = '1' then 
			flush <='1';
		end if;
		if isJump ='1' then  JRopcode <= "01" ;
		elsif mustBranch = '1' then JRopcode <="10";
		else JRopcode <="00";
		end if ;
	end process;
	wasJumpOut <= isJump;
end architecture behavior;

------------ Selector ------------

library ieee;
use ieee.std_logic_1164.all;

entity Selector is
generic ( n: INTEGER := 16);

port (Reg, Memory, Writeback : IN STD_LOGIC_VECTOR (n-1 downto 0);
		operation : IN STD_LOGIC_VECTOR(1 downto 0 );
		output : OUT STD_LOGIC_VECTOR(n-1 downto 0));
end Selector;

architecture behavior of Selector IS
begin 
	with operation select 
		output <= Reg when "00",
		Writeback when "01",
		Memory when "10",
		"0000000000000000" when "11";
end architecture behavior;

------------ Trap Unit ------------

library ieee;
use ieee.std_logic_1164.all;

entity trapUnit is 
	port (opcode : IN STD_LOGIC_VECTOR (3 downto 0);
			EOR : OUT STD_LOGIC
			);
END trapUnit;

architecture behavior of trapUnit is 
begin 
	process (opcode)
		begin 
			if opcode = "1110" then 
				EOR <= '1' ;
			else 
				EOR <= '0';
		end if;
	end process;
end architecture behavior;

------------ JRSelector ------------

library ieee;
use ieee.std_logic_1164.all;

entity JRSelector is
	generic (total_len : integer := 16);
	port (--input
			jumpAD, branchAD, PCP2AD : in std_logic_vector(total_len-1 downto 0);
			JRopcode : in std_logic_vector(1 downto 0);
			--output
			result : out std_logic_vector(total_len-1 downto 0)
			); 
end entity JRSelector;

architecture JRSelector_func of JRSelector is
	
	component mux4to1 is
		port(input0, input1, input2, input3 : in std_logic_vector(total_len-1 downto 0);
		  choice : in std_logic_vector(1 downto 0);
		  output : out std_logic_vector(total_len-1 downto 0));
	end component;

begin

	get_output: mux4to1 PORT MAP (PCP2AD, jumpAD, branchAD, PCP2AD, JRopcode, result);

end architecture JRSelector_func;

library ieee;
use ieee.std_logic_1164.all;
entity JROpcodeCalculator is
	generic (opcode_len : integer := 4);

	port (opcode : in std_logic_vector(opcode_len-1 downto 0);
			jropcode : out std_logic_vector(1 downto 0)
			);
end entity JROpcodeCalculator;

architecture JROpcodeCalculator_func of JROpcodeCalculator is
begin
	with opcode select jropcode <= 
			"10" when "0100",  -- branch
			"01" when "1111",  -- jump
			"00" when others;  -- pc + 2
end architecture JROpcodeCalculator_func;
------------ Program Counter ------------

library ieee;
use ieee.std_logic_1164.all;

entity PC is
	generic (n : integer := 16);
	port (input : in std_logic_vector(n-1 downto 0);
			clock, enable : in std_logic;
			output : out std_logic_vector(n-1 downto 0)
			);
end entity PC;

architecture PC_func of PC is
begin
	
	process (clock) begin
		if clock'event and clock='1' then
			if enable = '1' then
				output <= input;
			end if;
		end if;
	end process;
	
end architecture PC_func;
	
	
	
	
	


