library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
	generic (total_len : integer := 16;
				jump_len : integer := 12;
				immediate_len : integer := 6;
				opcode_len : integer := 4;
				function_len : integer := 3;
				regAD_len : integer := 3;
				num_of_registers : integer := 8
				);
				
	port (instruction : in std_logic_vector(total_len-1 downto 0);
			clock : in std_logic;
			
			pcOut, instrOut, dataAD, toData, printCode, printData : out std_logic_vector(total_len-1 downto 0);
			printEnable, keyEnable, DataWriteFlag : out std_logic;
			regOut : out std_logic_vector((num_of_registers+1)*total_len-1 downto 0)  --OUTAll & instruction
			
			);
end entity cpu;


architecture cpu_functionality of cpu is

	---------- IF/ID Stage ----------
	
	component IF_ID is
		port (--input
				inPC, inInstruction : in std_logic_vector(total_len-1 downto 0);
				clock, IF_FLUSH, IF_ID_ENABLE : in std_logic;
				--output
				outPC, outInstruction : out std_logic_vector(total_len-1 downto 0)
				);
	end component;
	
	component PC is
		port (--input
				input : in std_logic_vector(total_len-1 downto 0);
				clock, enable : in std_logic;
				--output 
				output : out std_logic_vector(total_len-1 downto 0)
				);
	end component;
	
	component jumpAD is
		port (--input
				jumpADR : in std_logic_vector(jump_len-1 downto 0);
				instrP2AD : in std_logic_vector(total_len-1 downto 0);
				--output
				EjumpAD : out std_logic_vector(total_len-1 downto 0)
				);
	end component;
	
	component JRSelector is
		port (--input
				jumpAD, branchAD, PCP2AD : in std_logic_vector(total_len-1 downto 0);
				JRopcode : in std_logic_vector(1 downto 0);
				--output
				result : out std_logic_vector(total_len-1 downto 0)
				); 
	end component;
		
	component trapUnit is
		port (--input
				opcode : IN STD_LOGIC_VECTOR (opcode_len-1 downto 0);
				--output
				EOR : OUT STD_LOGIC
				);
	end component;
	
	---------- ID/EX Stage ----------

	component ID_EX is
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
	end component;
	
	component regFile is
		port (clock : in std_logic;
				Read1AD, Read2AD, Write1AD : in std_logic_vector(regAD_len-1 downto 0);
				Write1 : in std_logic_vector(total_len-1 downto 0);
				Read1, Read2 : out std_logic_vector(total_len-1 downto 0);
				OUTAll : out std_logic_vector(total_len*num_of_registers-1 downto 0)
				);
	end component;
	
	component signExtender is
		generic (k : integer := 6);
		port (immediate : in std_logic_vector (k-1 downto 0);
				extended : out std_logic_vector (total_len-1 downto 0)
				);
	end component;
	
	component aluControl is
		port (opcode : in std_logic_vector(3 downto 0);
				func : in std_logic_vector(2 downto 0);
				output: out std_logic_vector(3 downto 0));
	end component;
	
	component controller is
		port (opCode : IN STD_LOGIC_VECTOR (3 downto 0);
				func : IN STD_LOGIC_VECTOR (2 downto 0);
				flush : IN STD_LOGIC;
				isMPFC, isJumpD, isReadDigit, isPrintDigit, isR, isLW, isSW, isBranch, isJR : OUT STD_LOGIC
				);
	end component;
	
	component hazardUnit is
		port (isJR, isJump, wasJump, mustBranch : IN STD_LOGIC;
				flush, wasJumpOut : OUT STD_LOGIC;
				jRopcode : OUT STD_LOGIC_VECTOR (1 downto 0)
				);
	end component;
	
	---------- EX/MEM ----------
	
	component EX_MEM is
		port (clock, isLW, WriteEnable, ReadDigit, PrintDigit : IN std_logic; 
				R2Reg, Result : IN std_logic_vector (total_len-1 downto 0);
				RegAD : IN std_logic_vector(regAD_len-1 downto 0);
				isLW_EXMEM, WriteEnable_EXMEM, ReadDigit_EXMEM, PrintDigit_EXMEM : OUT std_logic;
				R2Reg_EXMEM, Result_EXMEM : OUT std_logic_vector(total_len-1 downto 0);
				RegAD_EXMEM : OUT std_logic_vector(regAD_len-1 downto 0) );
	end component;		
	
	component mux8to1 is
		port(input0, input1, input2, input3, input4, input5, input6, input7: in std_logic_vector(total_len-1 downto 0);
			  choice : in std_logic_vector(2 downto 0);
			  output : out std_logic_vector(total_len-1 downto 0));
	end component;
		
	component alu is 
		port (input1, input2 : in signed(total_len-1 downto 0);
				opcode : in std_logic_vector(opcode_len-1 downto 0);
				output   : out signed(total_len-1 downto 0);
				carryOut : out std_logic);
	end component;
	
	component mux2to1 is
		port(input0, input1 : in std_logic_vector(total_len-1 downto 0);
			  choice : in std_logic;
			  output : out std_logic_vector(total_len-1 downto 0));	
	end component;
	
	component Forwarder is
		port (R1AD, R2AD, RegAD_EXMEM, RegAD_MEMWB : IN STD_LOGIC_VECTOR (regAD_len-1 downto 0);
			S1, S2 : OUT STD_LOGIC_VECTOR(1 downto 0));
	end component;
	
	component Selector is
		port (Reg, Memory, Writeback : IN STD_LOGIC_VECTOR (total_len-1 downto 0);
			operation : IN STD_LOGIC_VECTOR(1 downto 0 );
			output : OUT STD_LOGIC_VECTOR(total_len-1 downto 0));
	end component;
	
	---------- MEM/WB Stage ----------

	component MEM_WB is
		port (Result : IN std_logic_vector(total_len-1 downto 0);
				RegAD : IN std_logic_vector(regAD_len-1 downto 0);
				clk : IN std_logic;
				writeData : OUT std_logic_vector(total_len-1 downto 0);
				writeAD : OUT std_logic_vector(regAD_len-1 downto 0) );
	end component;

	-------------------- SIGNALS --------------------
	signal opcode : std_logic_vector(opcode_len-1 downto 0);
	signal function_code : std_logic_vector(function_len-1 downto 0);
	signal jump_field : std_logic_vector(jump_len-1 downto 0);
	---  IF/ID -----------
	signal end_of_run, enable_pc : std_logic;
	signal jump_ad : std_logic_vector(total_len-1 downto 0);
	signal jr_opcode : std_logic_vector(1 downto 0);
	signal jrSelector_result_address, pc_out, pc_IF_ID_out, instruction_IF_ID_out : std_logic_vector(total_len-1 downto 0);
	---  ID/EX -----------
	signal R1AD_IDEX, R2AD_IDEX, writeAD_ID : std_logic_vector(regAD_len-1 downto 0);
		signal R1AD_ID_EX, R2AD_ID_EX : std_logic_vector(regAD_len-1 downto 0);
	signal Reg1Data, Reg2Data, IDEX_Immediate16 : std_logic_vector(total_len-1 downto 0);	--output of buffer
		signal Reg1Data_ID_EX, Reg2Data_ID_EX, Immediate16_ID_EX: std_logic_vector(total_len-1 downto 0); --output of buffer
	signal OUTRegFile : std_logic_vector(num_of_registers*total_len-1 downto 0);
	signal IDEX_aluOpcode, IDEX_opcode : std_logic_vector(opcode_len-1 downto 0);	
		signal aluOpcode_ID_EX : std_logic_vector(opcode_len-1 downto 0);	--output of buffer
	signal IDEX_function : std_logic_vector(function_len-1 downto 0);
	signal IDEX_immediate : std_logic_vector(immediate_len-1 downto 0);
	--inputs of buffer
	signal isMPFC_IDEX, isJumpD_IDEX, isReadDigit_IDEX, isPrintDigit_IDEX, isR_IDEX, isLW_IDEX, isSW_IDEX, isBranch_IDEX, isJR_IDEX, isEOR_IDEX, wasJumpOut, flush_controller, mustBranch_forwarder_in: std_logic;
	--outputs of buffer
	signal isBranch_ID_EX, isEOR_ID_EX, isMPFC_ID_EX, isR_ID_EX, isLW_ID_EX_GND, isPrintDigit_ID_EX_GND, isReadDigit_ID_EX_GND, isSW_ID_EX_GND, flush_VCC : std_logic;
	signal jump_short_IDEX : std_logic_vector(jump_len-1 downto 0);
		signal jump_short_ID_EX : std_logic_vector(jump_len-1 downto 0); --output of buffer
	--- EX/MEM -----------
	signal forwarder_R1AD, forwarder_R2AD : std_logic_vector(1 downto 0);
	signal selector1_output, selector2_output, alu_input1, alu_input2, aluOut : std_logic_vector(total_len-1 downto 0);
	signal aluOut_temp : signed(total_len-1 downto 0);
	signal carryOut , isLW_EXMEM, WriteEnable_EXMEM, ReadDigit_EXMEM, PrintDigit_EXMEM : std_logic;
	signal R2Reg_EXMEM, Result_EXMEM : std_logic_vector(total_len-1 downto 0);
	signal RegAD_EXMEM : std_logic_vector(regAD_len-1 downto 0);
	
	--- MEM/WB -----------
	signal writeData : std_logic_vector(total_len-1 downto 0);
	signal writeAD : std_logic_vector(regAD_len-1 downto 0);
	

-------------------- START FUNCTIONALITY --------------------
begin

	--calculate some init values
	opcode <= instruction(total_len-1 downto total_len-opcode_len);
	function_code <= instruction(function_len-1 downto 0);
	jump_field <= instruction(jump_len-1 downto 0);
	
	---------------- FETCH STAGE ----------------
	
	--get trap unit output to determine EOR
	trap_unit: trapUnit port map (opcode, end_of_run);
	--select address to send to PC (jump (we must calculate jumpAD first)/branch/pc+2)
	get_jump_address: jumpAD port map (jump_field, pc_out, jump_ad);
	determine_pc_input: JRSelector port map (jump_ad, x"1111", pc_IF_ID_out, jr_opcode, jrSelector_result_address);  -- "1234" is branch address, placeholder, must come from alu
	
	enable_pc <= not (end_of_run or isEOR_ID_EX);
	
	IF_ID_REG: IF_ID port map (pc_out, instruction, clock, end_of_run, '1', pc_IF_ID_out, instruction_IF_ID_out);
	program_counter: PC port map (jrSelector_result_address, clock, enable_pc, pc_out);

	pcOut <= pc_IF_ID_out;
	instrOut <= instruction_IF_ID_out;


	---------------- DECODE STAGE ----------------
	-- calculate some init values
	writeAD_ID <= instruction_IF_ID_out((regAD_len*4)-1 downto regAD_len*3);
	R2AD_IDEX <= instruction_IF_ID_out((regAD_len*3)-1 downto regAD_len*2);
	R1AD_IDEX <= instruction_IF_ID_out((regAD_len*2)-1 downto regAD_len);
	IDEX_immediate <= instruction_IF_ID_out(immediate_len-1 downto 0);
	IDEX_opcode <= instruction_IF_ID_out(total_len-1 downto total_len-opcode_len);
	IDEX_function <= instruction_IF_ID_out(function_len-1 downto 0);
	jump_short_IDEX <= instruction_IF_ID_out(jump_len-1 downto 0);
	isEOR_IDEX <= end_of_run;
	
	-- go to register file to get register data
	register_file: regFile port map (clock, R1AD_IDEX, R2AD_IDEX, writeAD, writeData, Reg1Data, Reg2Data, OUTRegFile);
	regOut <= OUTRegFile & instruction;

	--calculate alu opcode
	alu_control: aluControl port map (IDEX_opcode, IDEX_function, IDEX_aluOpcode);
	
	-- calculate sign extension of jump
	sign_extender: signExtender port map (IDEX_immediate, IDEX_Immediate16);
	
	-- run control to get signals
	flush_controller <= isEOR_IDEX or flush_VCC;
	control_unit: controller port map (IDEX_opcode, IDEX_function, flush_controller, isMPFC_IDEX, isJumpD_IDEX,
												  isReadDigit_IDEX, isPrintDigit_IDEX, isR_IDEX, isLW_IDEX, isSW_IDEX, isBranch_IDEX, isJR_IDEX);

	mustBranch_forwarder_in <= isBranch_ID_EX and carryOut;
	hazard_unit: hazardUnit port map (isJR_IDEX, isJumpD_IDEX, '0', mustBranch_forwarder_in, flush_VCC, wasJumpOut, jr_opcode);
	
	-- store in ID/EX
	ID_EX_REG: ID_EX port map (--input
		clock, isBranch_IDEX, isEOR_IDEX, isJR_IDEX, isJumpD_IDEX, isLW_IDEX, 
		isMPFC_IDEX, isPrintDigit_IDEX, isR_IDEX, isReadDigit_IDEX, isSW_IDEX,  wasJumpOut, IDEX_aluOpcode, Reg1Data, Reg2Data, IDEX_Immediate16,
		R1AD_IDEX, R2AD_IDEX, jump_short_IDEX,  
		--output
		isBranch_ID_EX, isEOR_ID_EX, isMPFC_ID_EX, isR_ID_EX, isLW_ID_EX_GND, isPrintDigit_ID_EX_GND, isReadDigit_ID_EX_GND, isSW_ID_EX_GND,
		aluOpcode_ID_EX, Reg1Data_ID_EX, Reg2Data_ID_EX, Immediate16_ID_EX, R1AD_ID_EX, R2AD_ID_EX, jump_short_ID_EX
		);		  

	---------- EXECUTE STAGE ----------

	-- calculate some init values
	
	
	-- run forwarder
	forward_unit: Forwarder port map (R1AD_ID_EX, R2AD_ID_EX, "000", "000", forwarder_R1AD, forwarder_R2AD);

	-- determine alu input values
	Selector1: Selector port map (Reg1Data_ID_EX, x"0000", writeData, forwarder_R1AD, selector1_output);
	Selector2: Selector port map (Reg2Data_ID_EX, x"0000", writeData, forwarder_R2AD, selector2_output);

	--select if is R or other for alu input
	-- ALUInput1: mux2to1 port map (x"0000", selector1_output, isMPFC_ID_EX, alu_input1);
	-- ALUInput2: mux2to1 port map (x"0000", selector2_output, isR_ID_EX, alu_input2);
	-- run alu
	ALU16: alu port map(signed(selector1_output), signed(selector2_output), aluOpcode_ID_EX, aluOut_temp, carryOut);
	aluOut <= std_logic_vector(aluOut_temp);
	
	-- store in EX/MEM
	EX_MEM_REG: EX_MEM port map(clock, isLW_ID_EX_GND, isSW_ID_EX_GND, isReadDigit_ID_EX_GND, isPrintDigit_ID_EX_GND, Reg2Data_ID_EX, aluOut,
										 R2AD_ID_EX, isLW_EXMEM, WriteEnable_EXMEM, ReadDigit_EXMEM, PrintDigit_EXMEM, R2Reg_EXMEM, Result_EXMEM, RegAD_EXMEM);
	printEnable <= printDigit_EXMEM;
	keyEnable <= ReadDigit_EXMEM;
	DataWriteFlag <= WriteEnable_EXMEM;
	dataAD <= R2Reg_EXMEM;
	toData <= Result_EXMEM;
	printCode <= Result_EXMEM;
	printData <= Result_EXMEM;
	
	---------- MEMORY/WRITEBACK STAGE ----------
	
	MEM_WB_REG: MEM_WB port map (Result_EXMEM, RegAD_EXMEM, clock, writeData, writeAD);


		
end architecture cpu_functionality;