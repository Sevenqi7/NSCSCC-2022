//个人要求的指令数目34条，+NOP 35条  
`define InstrNum 35         
 //运算信号的集合
`define OperationSet ADD, ADDI, ADDU, ADDIU, SUB,\
                    SLT, MUL, AND, ANDI, LUI, OR, ORI, XOR, XORI, SLLV, SLL,\
                    SRAV, SRA, SRLV, SRL, BEQ,\
                    BNE, BGEZ, BGTZ, BLEZ, BLTZ,\
                    J, JAL, JR, JALR, LB, LW, SB,\
                    SW
                
            