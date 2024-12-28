-------------------- IF / ID --------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity IF_ID is
	generic (total_len : integer := 16);
	port (inPC, inInstruction : in std_logic_vector(total_len-1 downto 0);
			clock, IF_FLUSH, IF_ID_ENABLE : in std_logic;
			outPC, outInstruction : out std_logic_vector(total_len-1 downto 0)
			);
end entity IF_ID;

architecture IF_ID_func of IF_ID is

begin
	process (clock, IF_FLUSH, IF_ID_ENABLE) begin
		if clock='1' and IF_ID_ENABLE = '1' then
			outPC <= std_logic_vector( unsigned(inPC) + 2 );
			outInstruction <= inInstruction;
		elsif clock = '1' and IF_FLUSH = '1' then
			outPC <= (OTHERS => '0');
			outInstruction <= (OTHERS => '0');
		end if;
	end process;
end architecture IF_ID_func;

-------------------- ID / EX --------------------
library ieee;
use ieee.std_logic_1164.all;
entity ID_EX is
	generic (total_len : integer := 16;
				jump_len : integer := 12;
				opcode_len : integer := 4;
			   regAd_len : integer := 3);
	port(-- inputs
			clock, isBranch, isEOR, isJR, isJump, isLW, isMFPC, isPrintDigit, isR, isReadDigit, isSW, wasJumpOut: in std_logic;  --controller
			ALUFunc : in std_logic_vector(opcode_len-1 downto 0);  --controller -> for alu
			R1Reg, R2Reg, Immeadiate16 : in std_logic_vector(total_len-1 downto 0);  --register file
			R1AD, R2AD : in std_logic_vector(regAD_len-1 downto 0);  --register file
			JumpShortAddr : in std_logic_vector(jump_len-1 downto 0);  --sign extender
			-- outputs
			isBranch_IDEX, isEOR_IDEX, isMFPC_IDEX, isR_IDEX, isLW_IDEX_GND, isPrintDigit_IDEX_GND, isReadDigit_IDEX_GND, isSW_IDEX_GND: out std_logic;
			ALUFunc_IDEX : out std_logic_vector(opcode_len-1 downto 0);
			R1Reg_IDEX, R2Reg_IDEX, Immeadiate16_IDEX : out std_logic_vector(total_len-1 downto 0);
			R1AD_IDEX, R2AD_IDEX : out std_logic_vector(regAD_len-1 downto 0);
			JumpShortAddr_IDEX : out std_logic_vector(jump_len-1 downto 0)
		);
end entity ID_EX;

architecture ID_EX_func of ID_EX is
begin

	process( clock ) begin
		if clock='1' then
			isBranch_IDEX <= isBranch;
			isEOR_IDEX <= isEOR;
			isMFPC_IDEX <= isMFPC;
			isR_IDEX <= isR;
			isLW_IDEX_GND <= isLW;
			isPrintDigit_IDEX_GND <= isPrintDigit;
			isReadDigit_IDEX_GND <= isReadDigit;
			isSW_IDEX_GND <= isSW;
			ALUFunc_IDEX <= ALUFunc;
			R1Reg_IDEX <= R1Reg;
			R2Reg_IDEX <= R2Reg;
			Immeadiate16_IDEX <= Immeadiate16;
			R1AD_IDEX <= R1AD;
			R2AD_IDEX <= R2AD;
			JumpShortAddr_IDEX <= JumpShortAddr;
		end if ;		
	end process ;

end architecture ID_EX_func;
-------------------- EX / MEM --------------------
library ieee;
use ieee.std_logic_1164.all;
entity EX_MEM is
	generic (total_len : integer := 16;
				regAD_len : integer := 3);
	port (clock, isLW, writeEnable, readDigit, printDigit : in std_logic;
			R2Reg, Result : in std_logic_vector(total_len-1 downto 0);
			RegAD : in std_logic_vector(regAD_len-1 downto 0);
			--output
			isLW_EXMEM, writeEnable_EXMEM, readDigit_EXMEM, printDigit_EXMEM : out std_logic;
			R2Reg_EXMEM, Result_EXMEM : out std_logic_vector(total_len-1 downto 0);
			RegAD_EXMEM : out std_logic_vector(regAD_len-1 downto 0));
end entity EX_MEM;

architecture EX_MEM_func of EX_MEM is
begin
	process(clock) begin
		if clock = '1' then 
			isLW_EXMEM <= isLW;
			writeEnable_EXMEM <= writeEnable;
			readDigit_EXMEM <= readDigit;
			printDigit_EXMEM <= printDigit;
			R2Reg_EXMEM <= R2Reg;
			Result_EXMEM <= Result;
			RegAD_EXMEM <= RegAD;
		end if;
	end process;
end architecture EX_MEM_func;


-------------------- MEM / WB --------------------
library ieee;
use ieee.std_logic_1164.all;
entity MEM_WB is
	generic (total_len : integer := 16;
				regAD_len : integer := 3
				);
	port (Result : in std_logic_vector(total_len-1 downto 0);
			RegAD : in std_logic_vector(regAD_len-1 downto 0);
			clk : in std_logic;
			writeData : out std_logic_vector(total_len-1 downto 0);
			writeAD : out std_logic_vector(regAD_len-1 downto 0)
			);
end entity MEM_WB;

architecture MEM_WB_func of MEM_WB is
begin
	process (clk) begin
		if clk = '1' then
			writeData <= Result;
			writeAd <= RegAD;
		end if;
	end process;

end architecture MEM_WB_func;



