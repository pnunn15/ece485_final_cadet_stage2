library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instr_mem is
    Port (
        addr    : in  STD_LOGIC_VECTOR(31 downto 0);
        instr   : out STD_LOGIC_VECTOR(31 downto 0)
    );
end instr_mem;

-- Note: the Real RISC-V uses the ADDI for the NOP instruction, but I'm pretending 0x0000000000000000 is a NOP
-- inserting NOPs to avoid hazards
architecture Behavioral of instr_mem is
    type memory_array is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
    signal memory : memory_array := (
        0 => x"00900293", -- addi x5, x0, 9 | 000000001001 00000 000 00101 0010011
--        1 => x"00429293", -- subi x5, x5, 4 | 000000000100 00101 001 00101 0010011
--        2 => x"FFC29293", -- subi x5, x5, -4 | 111111111100 00101 001 00101 0010011
        1 => x"00000317", -- load_addr x6, array (custom instruction), where array is 0x10000000 | 00000000000000000000 00110 0010111
        2 => x"00000000", -- 3 NOPs in a row because lw accesses x6
        3 => x"00000000",
        4 => x"00000000",
        5 => x"00032383", -- lw x7, 0(x6) | 000000000000 00110 010 00111 0000011
        6 => x"00430313", -- loop: addi x6, x6, 4 | 000000000100 00110 000 00110 0010011
        7 => x"00000000", -- 3 NOPs in a row because lw accesses x6
        8 => x"00000000",
        9 => x"00000000",
        10 => x"00032503", -- lw x10, 0(x6) | 000000000000 00110 010 01010 0000011
        11 => x"00000000", -- 3 NOPs in a row because lw writes x10
        12 => x"00000000",
        13 => x"00000000",
        14 => x"007503B3", -- add x7, x10, x7 | 0000000 00111 01010 000 00111 0110011
        15 => x"00129293", -- subi x5, x5, 1 | 000000000001 00101 001 00101 0010011  
        16 => x"00000000", -- 3 NOPs in a row because subi writes x5
        17 => x"00000000",
        18 => x"00000000",
        19 => x"F20290E3", -- bne x5, x0, loop [jump -112 because it will divide it by 2 and is going to 24; note: assumes PC is incremented by 4] | 1 111001 00000 00101 001 000 0 1 1100011
        20 => x"00000000", -- 3 NOPs in a row because branch delay
        21 => x"00000000",
        22 => x"00000000",
        23 => x"FF9FF06F", -- done: j done [jump -4; note: assumes PC is incremented by 4] | 1 1111111100 1 11111111 00000 1101111
        others => (others => '0')
    );
begin
    process(addr)
    begin
        instr <= memory(to_integer(unsigned(addr(7 downto 0))));
    end process;
end Behavioral;
