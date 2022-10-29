//opcodes and functs definition

//R-type opcodes
`define ADD 7'b0110011 //y
`define SUB 7'b0110011 //y
`define SLL 7'b0110011 //y
`define SLT 7'b0110011 //y
`define SLTU 7'b0110011 //y
`define XOR 7'b0110011 //y
`define SRL 7'b0110011 //y
`define SRA 7'b0110011 //y
`define OR 7'b0110011 //y
`define AND 7'b0110011 //y

//R-type {funct7,funct3}
`define funct_ADD 10'b0000000000
`define funct_SUB 10'b0100000000
`define funct_SLL 10'b0000000001
`define funct_SLT 10'b0000000010
`define funct_SLTU 10'b0000000011
`define funct_XOR 10'b0000000100
`define funct_SRL 10'b0000000101
`define funct_SRA 10'b0100000101
`define funct_OR 10'b0000000110
`define funct_AND 10'b0000000111


//------------------------------------------------
//I-type opcodes
`define LB 7'b0000011 //y
`define LH 7'b0000011 //y
`define LW 7'b0000011 //y
`define LBU 7'b0000011 //y
`define LHU 7'b0000011 //y
//---------------------
`define ADDI 7'b0010011 //y
`define SLTI 7'b0010011 //y
`define SLTIU 7'b0010011 //y
`define XORI 7'b0010011 //y
`define ORI 7'b0010011 //y
`define ANDI 7'b0010011 //y
`define SLLI 7'b0010011 //y
`define SRLI 7'b0010011 //y
`define SRAI 7'b0010011 //y
//----------------------
`define JALR 7'b1100111 //y

//I-type {funct7,funct3}
`define funct_LB 10'b???????000
`define funct_LH 10'b???????001
`define funct_LW 10'b???????010
`define funct_LBU 10'b???????100
`define funct_LHU 10'b???????101
//---------------------
`define funct_ADDI 10'b???????000
`define funct_SLTI 10'b???????010
`define funct_SLTIU 10'b???????011
`define funct_XORI 10'b???????100
`define funct_ORI 10'b???????110
`define funct_ANDI 10'b???????111
`define funct_SLLI 10'b0000000001
`define funct_SRLI 10'b0000000101
`define funct_SRAI 10'b0100000101
//----------------------
`define funct_JALR 10'b???????000


//------------------------------------------------
//S-type opcodes
`define SB 7'b0100011 //y
`define SH 7'b0100011 //y
`define SW 7'b0100011 //y

//S-type {funct7,funct3}
`define funct_SB 10'b???????000
`define funct_SH 10'b???????001
`define funct_SW 10'b???????010

//------------------------------------------------
//B-type opcodes
`define BEQ 7'b1100011 //y
`define BNE 7'b1100011 //y
`define BLT 7'b1100011 //y
`define BGE 7'b1100011 //y
`define BLTU 7'b1100011 //y
`define BGEU 7'b1100011 //y

//B-type {funct7,funct3}
`define funct_BEQ 10'b???????000
`define funct_BNE 10'b???????001
`define funct_BLT 10'b???????100
`define funct_BGE 10'b???????101
`define funct_BLTU 10'b???????110
`define funct_BGEU 10'b???????111



//------------------------------------------------
//U-type opcodes
`define LUI 7'b0110111 //y
//---------------------
`define AUIPC 7'b0010111 //y


//------------------------------------------------
//J-type opcodes
`define JAL 7'b1101111 //y


//------------------------------------------------
//M extension instructions opcodes
`define MUL 7'b0110011 //y
`define MULH 7'b0110011 //y
`define MULHSU 7'b0110011 //y
`define MULHU 7'b0110011 //y

//M extension instructions {funct7,funct3}
`define funct_MUL 10'b0000001000
`define funct_MULH 10'b0000001001
`define funct_MULHSU 10'b0000001010
`define funct_MULHU 10'b0000001011
