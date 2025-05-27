library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;


architecture testenv of test_env is
component SSD1 is
    Port ( d1 : in STD_LOGIC_VECTOR (3 downto 0);
           d2 : in STD_LOGIC_VECTOR (3 downto 0);
           d3 : in STD_LOGIC_VECTOR (3 downto 0);
           d4 : in STD_LOGIC_VECTOR (3 downto 0);
           clk: in STD_LOGIC;
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0)
           );
end component;

component monopulse is
    Port ( clk : in STD_LOGIC;
           input : in STD_LOGIC;
           output : out STD_LOGIC);
end component;

component instruction_fetch is
    Port ( Jump : in STD_LOGIC;
           JumpAddress : in STD_LOGIC_VECTOR (15 downto 0);
           PCSrc : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR (15 downto 0);
           JmpR : in STD_LOGIC;
           JRAddress : in STD_LOGIC_VECTOR(15 downto 0);
           CLK : in STD_LOGIC;
           RST: in STD_LOGIC;
           EN : in STD_LOGIC;
           Instruction : out STD_LOGIC_VECTOR(15 downto 0);
           PCPlus1 : out STD_LOGIC_VECTOR(15 downto 0)
    );
end component;

component instruction_decode is
    Port ( Instr_IFID        : in  STD_LOGIC_VECTOR (15 downto 0); 
           RegDst_Ctrl         : in  STD_LOGIC;                     
           ExtOp_Ctrl          : in  STD_LOGIC;                     
           CLK                 : in  STD_LOGIC;                    
           EN_RegFile_clkSim   : in  STD_LOGIC;                    
           RegWrite_from_WB    : in  STD_LOGIC;
           WD_from_WB          : in  STD_LOGIC_VECTOR (15 downto 0);
           WA_from_WB          : in  STD_LOGIC_VECTOR (2 downto 0);
           RD1_Out             : out STD_LOGIC_VECTOR (15 downto 0);
           RD2_Out             : out STD_LOGIC_VECTOR (15 downto 0);
           Ext_Imm_Out         : out STD_LOGIC_VECTOR (15 downto 0);
           func_Out            : out STD_LOGIC_VECTOR (2 downto 0);
           sa_Out              : out STD_LOGIC;
           DestRegAddr_to_Pipeline : out STD_LOGIC_VECTOR(2 downto 0) 
         );
end component;


component main_control is
    Port ( instr : in STD_LOGIC_VECTOR (2 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           BranchEQ : out STD_LOGIC;
           BranchGTZ : out STD_LOGIC;
           Jump : out STD_LOGIC;
           JumpR : out STD_LOGIC;
           MemWrite : out STD_LOGIC;
           MemToReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR(1 downto 0));
end component;

component instruction_execute is
    Port ( RD1 : in STD_LOGIC_VECTOR (15 downto 0);
           ALUSrc : in STD_LOGIC;
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR (15 downto 0);
           sa : in STD_LOGIC;
           func : in STD_LOGIC_VECTOR (2 downto 0);
           AluOP : in STD_LOGIC_VECTOR(1 downto 0);
           PCplus1 : in STD_LOGIC_VECTOR (15 downto 0);
           GT : out STD_LOGIC;
           Zero: out STD_LOGIC;
           ALURes: out STD_LOGIC_VECTOR(15 downto 0);
           BranchAdress: out STD_LOGIC_VECTOR(15 downto 0)
           );
end component;

component MEM is
    Port ( MemWrite : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           CLK : in STD_LOGIC;
           EN : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR (15 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR (15 downto 0));
end component;

signal clkSimulation, clkSimulation1: STD_LOGIC;

signal Instruction_IF_Out  : STD_LOGIC_VECTOR(15 downto 0);
signal PCPlus1_IF_Out      : STD_LOGIC_VECTOR(15 downto 0);

signal Instruction_IFID    : STD_LOGIC_VECTOR(15 downto 0);
signal PCPlus1_IFID        : STD_LOGIC_VECTOR(15 downto 0);

signal RegDst_C, ExtOp_C, ALUSrc_C, BranchEQ_C, BranchGTZ_C, Jump_C, JumpR_C, MemWrite_C, MemToReg_C, RegWrite_C : STD_LOGIC;
signal ALUOp_C             : STD_LOGIC_VECTOR(1 downto 0);

signal RD1_ID_Out, RD2_ID_Out : STD_LOGIC_VECTOR(15 downto 0);
signal Ext_Imm_ID_Out         : STD_LOGIC_VECTOR(15 downto 0);
signal func_ID_Out            : STD_LOGIC_VECTOR(2 downto 0);
signal sa_ID_Out              : STD_LOGIC;
signal DestRegAddr_ID_Out     : STD_LOGIC_VECTOR(2 downto 0);

signal RegWrite_IDEX       : STD_LOGIC;
signal MemToReg_IDEX       : STD_LOGIC;
signal MemWrite_IDEX       : STD_LOGIC;
signal BranchEQ_IDEX       : STD_LOGIC;
signal BranchGTZ_IDEX      : STD_LOGIC;
signal ALUSrc_IDEX         : STD_LOGIC;
signal ALUOp_IDEX          : STD_LOGIC_VECTOR(1 downto 0);

signal RegDst_IDEX_disp    : STD_LOGIC;
signal ExtOp_IDEX_disp     : STD_LOGIC;
signal Jump_IDEX_disp      : STD_LOGIC;
signal JmpR_IDEX_disp      : STD_LOGIC;

signal RD1_IDEX            : STD_LOGIC_VECTOR(15 downto 0);
signal RD2_IDEX            : STD_LOGIC_VECTOR(15 downto 0);
signal Ext_Imm_IDEX        : STD_LOGIC_VECTOR(15 downto 0);
signal func_IDEX           : STD_LOGIC_VECTOR(2 downto 0);
signal sa_IDEX             : STD_LOGIC;
signal PCPlus1_IDEX        : STD_LOGIC_VECTOR(15 downto 0);
signal DestRegAddr_IDEX    : STD_LOGIC_VECTOR(2 downto 0);

signal ALURes_EX_Out       : STD_LOGIC_VECTOR(15 downto 0);
signal Zero_EX_Out         : STD_LOGIC;
signal GT_EX_Out           : STD_LOGIC;
signal BranchAddress_EX_Out: STD_LOGIC_VECTOR(15 downto 0);
signal PCSrc               : STD_LOGIC; 

signal RegWrite_EXMEM      : STD_LOGIC;
signal MemToReg_EXMEM      : STD_LOGIC;
signal MemWrite_EXMEM      : STD_LOGIC;
signal ALURes_EXMEM        : STD_LOGIC_VECTOR(15 downto 0);
signal RD2_EXMEM           : STD_LOGIC_VECTOR(15 downto 0);
signal DestRegAddr_EXMEM   : STD_LOGIC_VECTOR(2 downto 0);

signal MemData_MEM_Out     : STD_LOGIC_VECTOR(15 downto 0);
signal ALUResOut_MEM_Out   : STD_LOGIC_VECTOR(15 downto 0);

signal RegWrite_MEMWB      : STD_LOGIC;
signal MemToReg_MEMWB      : STD_LOGIC;
signal MemData_MEMWB       : STD_LOGIC_VECTOR(15 downto 0);
signal ALUResOut_MEMWB     : STD_LOGIC_VECTOR(15 downto 0);
signal DestRegAddr_MEMWB   : STD_LOGIC_VECTOR(2 downto 0);

signal WriteBackData_WB    : STD_LOGIC_VECTOR(15 downto 0);

signal val                 : STD_LOGIC_VECTOR(15 downto 0);
signal JumpAddress         : STD_LOGIC_VECTOR(15 downto 0); 

begin

mpg0: monopulse port map (clk=>clk, input=>btn(0), output=> clkSimulation);
mpg1: monopulse port map (clk=>clk, input=>btn(1), output=> clkSimulation1); 

if0: instruction_fetch port map(
    Jump          => Jump_C,                 
    JumpAddress   => JumpAddress,            
    PCSrc         => PCSrc,                  
    BranchAddress => BranchAddress_EX_Out,   
    JmpR          => JumpR_C,                
    JRAddress     => RD1_ID_Out,             
    CLK           => clk,                    
    RST           => clkSimulation1,         
    EN            => clkSimulation,          
    Instruction   => Instruction_IF_Out,
    PCPlus1       => PCPlus1_IF_Out);

process(clk)
begin
    if rising_edge(clk) then
        if clkSimulation = '1' then
            Instruction_IFID <= Instruction_IF_Out;
            PCPlus1_IFID     <= PCPlus1_IF_Out;
        end if;
    end if;
end process;

JumpAddress <= PCPlus1_IFID(15 downto 13) & Instruction_IFID(12 downto 0);

mainControl0: main_control port map(
    instr         => Instruction_IFID(15 downto 13),
    RegDst        => RegDst_C,
    ExtOp         => ExtOp_C,
    ALUSrc        => ALUSrc_C,
    BranchEQ      => BranchEQ_C,
    BranchGTZ     => BranchGTZ_C,
    Jump          => Jump_C,
    JumpR         => JumpR_C,
    MemWrite      => MemWrite_C,
    MemToReg      => MemToReg_C,
    RegWrite      => RegWrite_C,
    ALUOp         => ALUOp_C);

id0: instruction_decode port map(
    Instr_IFID        => Instruction_IFID,
    RegDst_Ctrl       => RegDst_C,
    ExtOp_Ctrl        => ExtOp_C,
    CLK               => clk,
    EN_RegFile_clkSim => clkSimulation,
    RegWrite_from_WB  => RegWrite_MEMWB,
    WD_from_WB        => WriteBackData_WB,
    WA_from_WB        => DestRegAddr_MEMWB,
    RD1_Out           => RD1_ID_Out,
    RD2_Out           => RD2_ID_Out,
    Ext_Imm_Out       => Ext_Imm_ID_Out,
    func_Out          => func_ID_Out,
    sa_Out            => sa_ID_Out,
    DestRegAddr_to_Pipeline => DestRegAddr_ID_Out
);

process(clk)
begin
    if rising_edge(clk) then
        if clkSimulation = '1' then
        
            RegWrite_IDEX    <= RegWrite_C;
            MemToReg_IDEX    <= MemToReg_C;
            MemWrite_IDEX    <= MemWrite_C;
            BranchEQ_IDEX    <= BranchEQ_C;
            BranchGTZ_IDEX   <= BranchGTZ_C;
            ALUSrc_IDEX      <= ALUSrc_C;
            ALUOp_IDEX       <= ALUOp_C;
            
            RegDst_IDEX_disp <= RegDst_C;
            ExtOp_IDEX_disp  <= ExtOp_C;
            Jump_IDEX_disp   <= Jump_C;
            JmpR_IDEX_disp   <= JumpR_C;
            
            RD1_IDEX         <= RD1_ID_Out;
            RD2_IDEX         <= RD2_ID_Out;
            Ext_Imm_IDEX     <= Ext_Imm_ID_Out;
            func_IDEX        <= func_ID_Out;
            sa_IDEX          <= sa_ID_Out;
            PCPlus1_IDEX     <= PCPlus1_IFID;
            DestRegAddr_IDEX <= DestRegAddr_ID_Out;
        end if;
    end if;
end process;

ie0: instruction_execute port map(
    RD1           => RD1_IDEX,
    ALUSrc        => ALUSrc_IDEX,
    RD2           => RD2_IDEX,
    Ext_Imm       => Ext_Imm_IDEX,
    sa            => sa_IDEX,
    func          => func_IDEX,
    AluOP         => ALUOp_IDEX,
    PCplus1       => PCPlus1_IDEX,
    GT            => GT_EX_Out,
    Zero          => Zero_EX_Out,
    ALURes        => ALURes_EX_Out,
    BranchAdress  => BranchAddress_EX_Out);

PCSrc <= (BranchEQ_IDEX and Zero_EX_Out) or (BranchGTZ_IDEX and GT_EX_Out);

process(clk)
begin
    if rising_edge(clk) then
        if clkSimulation = '1' then
        
            RegWrite_EXMEM   <= RegWrite_IDEX;
            MemToReg_EXMEM   <= MemToReg_IDEX;
            MemWrite_EXMEM   <= MemWrite_IDEX;
            
            ALURes_EXMEM     <= ALURes_EX_Out;
            RD2_EXMEM        <= RD2_IDEX;    
            DestRegAddr_EXMEM<= DestRegAddr_IDEX;
            
        end if;
    end if;
end process;

MEM0: MEM port map(
    MemWrite      => MemWrite_EXMEM,
    ALUResIn      => ALURes_EXMEM,
    RD2           => RD2_EXMEM,
    CLK           => clk,
    EN            => clkSimulation,
    MemData       => MemData_MEM_Out,
    ALUResOut     => ALUResOut_MEM_Out);

process(clk)
begin
    if rising_edge(clk) then
        if clkSimulation = '1' then
        
            RegWrite_MEMWB   <= RegWrite_EXMEM;
            MemToReg_MEMWB   <= MemToReg_EXMEM;
            
            MemData_MEMWB    <= MemData_MEM_Out;
            ALUResOut_MEMWB  <= ALUResOut_MEM_Out;
            DestRegAddr_MEMWB<= DestRegAddr_EXMEM;
        end if;
    end if;
end process;

process(MemToReg_MEMWB, ALUResOut_MEMWB, MemData_MEMWB)
begin
    case MemToReg_MEMWB is
        when '0' =>
            WriteBackData_WB <= ALUResOut_MEMWB;
        when '1' =>
            WriteBackData_WB <= MemData_MEMWB;
        when others =>
            WriteBackData_WB <= (others => 'X'); 
    end case;
end process;

process(sw, Instruction_IFID, PCPlus1_IFID, RD1_IDEX, RD2_IDEX, Ext_Imm_IDEX, ALURes_EXMEM, MemData_MEMWB, WriteBackData_WB)
begin
    case sw(7 downto 5) is
        when "000" => val <= Instruction_IFID;   
        when "001" => val <= PCPlus1_IFID;       
        when "010" => val <= RD1_IDEX;           
        when "011" => val <= RD2_IDEX;           
        when "100" => val <= Ext_Imm_IDEX;       
        when "101" => val <= ALURes_EXMEM;       
        when "110" => val <= MemData_MEMWB;      
        when "111" => val <= WriteBackData_WB;   
        when others => val <= x"FFFF";
    end case;
end process;

SSD0: SSD1 port map(
    d1 => val(15 downto 12),
    d2 => val(11 downto 8),
    d3 => val(7 downto 4),
    d4 => val(3 downto 0),
    clk => clk,
    cat => cat,
    an => an
);

Led(0) <= RegWrite_IDEX;      
Led(1) <= MemToReg_IDEX;      
Led(2) <= MemWrite_IDEX;      
Led(3) <= Jump_IDEX_disp;     
Led(4) <= JmpR_IDEX_disp;     
Led(5) <= BranchEQ_IDEX;      
Led(6) <= BranchGTZ_IDEX;     
Led(7) <= ALUSrc_IDEX;        
Led(8) <= ExtOp_IDEX_disp;    
Led(9) <= RegDst_IDEX_disp;   
Led(11 downto 10) <= ALUOp_IDEX; 
Led(15 downto 12) <= "0000"; 

end testenv;
