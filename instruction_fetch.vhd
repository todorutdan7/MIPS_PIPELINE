library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity instruction_fetch is
    Port ( Jump : in STD_LOGIC;
           JumpAddress : in STD_LOGIC_VECTOR (15 downto 0);
           PCSrc : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR (15 downto 0);
           JmpR : in STD_LOGIC;
           JRAddress : in STD_LOGIC_VECTOR(15 downto 0);
           CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           EN : in STD_LOGIC;
           Instruction : out STD_LOGIC_VECTOR(15 downto 0);
           PCPlus1 : out STD_LOGIC_VECTOR(15 downto 0)
    );
end instruction_fetch;

architecture Behavioral of instruction_fetch is
type t_mem is array(0 to 31) of std_logic_vector(15 downto 0);

signal ROM: t_mem := (

    0 => B"0010_0000_1000_0000",  -- x2010  ADDI $1, $zero, 0     | $1 = 0
    1 => B"0010_0001_0000_0001",  -- x2101  ADDI $2, $zero, 1     | $2 = 1
    2 => B"0010_0001_1000_0110",  -- x2186  ADDI $3, $zero, 6     | $3 = 6 (limit)

    3 => B"0010_0000_0000_0000",  -- NOOP
    4 => B"0010_0000_0000_0000",  -- NOOP

    5 => B"0000_0101_0001_0000",  -- x0510  ADD $1, $1, $2        | $1 += $2

    6 => B"0010_1001_0000_0001",  -- x2901  ADDI $2, $2, 1        | count++

    7 => B"0010_0000_0000_0000",  -- NOOP
    8 => B"0010_0000_0000_0000",  -- NOOP
    9 => B"0010_0000_0000_0000",  -- NOOP
    
    10 => B"0100_1001_1000_0100",  -- x4981  BEQ $2, $3, 4       | if(count==limit) branch
    11 => B"0010_0000_0000_0000",  -- NOOP  
    12 => B"0010_0000_0000_0000",  -- NOOP  
    13 => B"1100_0000_0000_0101", -- xC003  J 5                   | loop back
    14 => B"0010_0000_0000_0000", -- NOOP  
    others => B"0010_0000_1000_0000"  -- x2010  ADDI $1, $zero, 0
);



signal IP: std_logic_vector(15 downto 0):= x"0000";

begin
Instruction <= ROM(conv_integer(IP));

PCPlus1 <= IP + 1;

PC: process(CLK)
begin
    if CLK'event and CLK = '1' then
        if RST = '1' then
            IP<=x"0000";
        elsif EN = '1' then
            if JmpR = '1' then
                IP <= JRAddress;
            elsif jump = '1' then
                IP <= JumpAddress;
            elsif PCSrc = '1' then
                IP <= BranchAddress;
            else
                IP <= IP+1;
            end if;
        end if;
    end if;
end process;

end Behavioral;