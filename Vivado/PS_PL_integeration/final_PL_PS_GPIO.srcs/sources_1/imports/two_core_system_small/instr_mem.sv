timeunit 1ns; timeprecision 100ps;
module instr_mem #(parameter Isize = 32, mem_size = 8) //could hold 2^(mem_size-2) instructions 
(input logic [Isize-1:0] address,
output logic [Isize-1:0] instruction);


logic [Isize-1:0] instrMEM [ (1<<mem_size-2)-1:0]; 

initial //load program to memory
	$readmemh("prog_A.hex", instrMEM);
	
	
assign instruction = instrMEM[address[Isize-1:2]]; //current instruction



endmodule