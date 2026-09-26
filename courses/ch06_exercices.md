# Chapter 06 exercices

## 6.23

- `add s7, s8, s9`
    - *R-type* instruction encoding. 
    - funct7=0, funct3=0, op=51, rs2=s7=25, rs1=s8=24, rd=s9=23
    - 0000_000 1_1001 _1100_0 000_ 1011_1 011_0011
    - | f1    |  rs2 |  rs1  | f3 |  rd  |  op    |
    - 00000001100111000000101110110011 = 019C0BB3

- `srai t0, t1, 0xC`
    - *I-type* instruction encoding. 
    - imm=12, funct3=5, op=19, rs1=t0=6, rd=t1=5
    - 0100_0000_1100_0011_0101_0010_1001_0011
    - 40C35293
    
- `lw s4, 0x5c(t3)`
    - *S-type* instruction encoding. 
    - imm=5C, rs2=s4=22, rs1=t3=28, func3=2, op=3
    - 0000_0101_0110_1110_0010_1110_0000_0011
    - 00000101011011100010111000000011
    - 056E2E03

## 6.35

Branch instruction use PC-relative addressing, which use PC summed with the 
*signed* immediate value. The immediate value is 13-bit wide, so 2^12 - 1 = 
4095. But as instruction are 4 bytes wide we can jump 4096/4 = 1024 
instructions.
