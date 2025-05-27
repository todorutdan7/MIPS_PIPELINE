library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity instruction_decode is

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
         
end instruction_decode;

architecture Behavioral of instruction_decode is

    component REG_FILE is
        Port ( RA1 : in STD_LOGIC_VECTOR (2 downto 0);
               RA2 : in STD_LOGIC_VECTOR (2 downto 0);
               WA : in STD_LOGIC_VECTOR (2 downto 0);
               WD : in STD_LOGIC_VECTOR (15 downto 0);
               EN : in STD_LOGIC; 
               clk : in STD_LOGIC;
               RegWr : in STD_LOGIC;
               RD1 : out STD_LOGIC_VECTOR (15 downto 0);
               RD2 : out STD_LOGIC_VECTOR (15 downto 0));
    end component;

begin

    process(RegDst_Ctrl, Instr_IFID)
    begin
        if RegDst_Ctrl = '0' then
            DestRegAddr_to_Pipeline <= Instr_IFID(9 downto 7);
        else
            DestRegAddr_to_Pipeline <= Instr_IFID(6 downto 4); 
        end if;
    end process;

    reg_file0: REG_FILE port map (
        RA1   => Instr_IFID(12 downto 10), 
        RA2   => Instr_IFID(9 downto 7),   
        WA    => WA_from_WB,               
        WD    => WD_from_WB,               
        EN    => EN_RegFile_clkSim,        
        clk   => CLK,                      
        RegWr => RegWrite_from_WB,         
        RD1   => RD1_Out,
        RD2   => RD2_Out
    );

    process(ExtOp_Ctrl, Instr_IFID)
    begin
        if ExtOp_Ctrl = '0' then
            Ext_Imm_Out <= "000000000" & Instr_IFID(6 downto 0);
        elsif ExtOp_Ctrl = '1' then
            Ext_Imm_Out <= (15 downto 7 => Instr_IFID(6)) & Instr_IFID(6 downto 0);
        else 
            Ext_Imm_Out <= (others => 'X');
        end if;
    end process;

    func_Out <= Instr_IFID(2 downto 0);
    sa_Out   <= Instr_IFID(3);

end Behavioral;