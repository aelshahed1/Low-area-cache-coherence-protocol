timeunit 1ns; timeprecision 100ps;
module instr_reg_tb;

parameter n = 32;

logic clk,reset;
logic [n-1:0] instruction_next, pc_next, pc_plus_four_next;
logic [n-1:0] instruction,pc, pc_plus_four;

instr_reg #(.n(n)) ir1(.*);

initial begin
	clk = '0;
	#5ns reset = '0;
	#5ns reset = '1;
	#5ns reset = '0;
	forever #5ns clk = ~clk;
end	

initial
begin
#12
instruction_next = 55;
pc_next = 250;
pc_plus_four_next = 1444;


#10 $stop;
end


endmodule

