-- OMADA 8
-- p3190031 - Georgiadis Eleftherios
-- p3180284 - Tsiggelis Aristotelis

-- Gates Implementation
------------ Not Gate ------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
entity myNot is
	port (a : in std_logic;
			f : out std_logic);
end myNot;

architecture myNot_beh of myNot is  
	begin
		process(a)
			begin
				if a = '0' then
					f <= '1';
				else 
					f <= '0';
				end if;
		end process;
end myNot_beh;

------------ AND Gate ------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
entity myAnd is
	port (a, b :in std_logic;
			f : out std_logic);
end myAnd;

architecture myAnd_beh of myAnd is  
	begin
		process(a, b)
			begin
				if (a = '1') and (b = '1') then
					f <= '1';
				else 
					f <= '0';
				end if;
		end process;
end myAnd_beh;

------------ OR Gate ------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
entity myOr is
	port (a, b :in std_logic;
			f : out std_logic);
end myOr;

architecture myOr_beh of myOr is  
	begin
		process(a, b)
			begin
				if (a = '1') or (b = '1') then
					f <= '1';
				else 
					f <= '0';
				end if;
		end process;
end myOr_beh;

------------ XOR Gate ------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
entity myXor is
	port (a, b :in std_logic;
			f : out std_logic);
end myXor;

architecture myXor_beh of myXor is  
	begin
		process(a, b)
			begin
				if ((a = '1') and (b = '0')) or ((a = '0') and (b = '1')) then
					f <= '1';
				else 
					f <= '0';
				end if;
		end process;
end myXor_beh;

------------ Nand Gate ------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
entity myNand is
	port (a, b : in std_logic;
			output : out std_logic);
end myNand;
 
architecture myNand_beh of myNand is
	component myNot is
		port (a : in std_logic;
				f : out std_logic);
	end component;
	
	component myAnd is
		port (a, b :in std_logic;
				f : out std_logic);
	end component;
	
	signal and_output : std_logic;
	begin
	step1: myAnd PORT MAP (a, b, and_output);
	step2: myNot PORT MAP (and_output, output);
end myNand_beh;

------------ 3 Bit And Gate ------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
entity myAnd3Bit is
	port (a, b, c : in std_logic;
			output  : out std_logic);
end myAnd3Bit;

architecture myAnd3Bit_beh of myAnd3Bit is
	component myAnd is
		port (a, b :in std_logic;
				f : out std_logic);
	end component;
	signal first_and : std_logic;
	begin
	and1: myAnd PORT MAP (a, b, first_and);
	and2: myAnd PORT MAP (first_and, c, output);
end myAnd3Bit_beh;