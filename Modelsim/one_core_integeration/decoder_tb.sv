timeunit 1ns; timeprecision 100ps;
`include "alu_codes.sv"
`include "opcodes.sv"

module decoder_tb;

logic [6:0] opcode;
logic [9:0] functs;
logic eq,lt,ltu; //input flags from ALU and comparator
logic [1:0] pc_sel; //signal to select program counter input
logic [3:0] alu_func; // function signal for ALU
logic [2:0] wdata_sel; //select signal for register file
logic [2:0] op2_immediate;
logic op1_pc, op1_ZERO; //alu op1 to be program_counter value or 0, op2 immediate
logic load_control; //control signal for external data memory load instructions
logic store_control; //control signal for external data memory store instructions
logic program_done;


decoder d1(.*);

initial begin

eq = 0;
lt = 0;
ltu = 0;
opcode = `ADD;
functs = `funct_ADD;

#20
$display("pc_sel = %b, alu_func = %b, wdata_sel = %b, mem_store=%b",pc_sel,alu_func,wdata_sel,mem_store);
$display("op1_pc = %b, op1_ZERO = %b, op2_immediate = %b",op1_pc,op1_ZERO,op2_immediate);


eq = 1;

opcode = `BEQ;
functs = `funct_BEQ;

#20
$display("pc_sel = %b, alu_func = %b, wdata_sel = %b, mem_store=%b",pc_sel,alu_func,wdata_sel,mem_store);
$display("op1_pc = %b, op1_ZERO = %b, op2_immediate = %b",op1_pc,op1_ZERO,op2_immediate);


#10 $stop;
end

initial begin
$monitor("\ncurrent value of opcode = %b, functs = %b, eq = %b, lt = %b, ltu = %b", opcode,functs,eq,lt,ltu);
end

endmodule


