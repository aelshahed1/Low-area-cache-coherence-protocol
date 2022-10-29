timeunit 1ns; timeprecision 100ps;
module program_counter_tb();

parameter pc_size = 32;
logic clk,reset;
logic branch_instruction,L1_busy;
logic [1:0] pc_select;
logic [31:0] alu_result,jal_address, pc_next,pc_plus_four_next;

program_counter #(.pc_size(pc_size)) pc1(.*);

initial begin
	clk = '0;
	#5ns reset = '0;
	#5ns reset = '1;
	#5ns reset = '0;
	forever #5ns clk = ~clk;
end	


initial begin
	L1_busy = '1;
	#7
	pc_select = 0;
	#25
	L1_busy = '0;
	#25
	pc_select = 1;
	alu_result = 36;
	#10
	pc_select = 2;
	jal_address = 120;
	#10
	pc_select = 3;
	alu_result = 32'hFFFFFFF3;
	#10
	pc_select = 0;
	
	#50 $stop;

end

	
initial begin
$monitor("next instruction at %d", pc_next);
end

default clocking clock_trigger
@(posedge clk);
endclocking

property pc_inc;

(pc_select == 0) |-> ##1 (pc_next == $past(pc_next) + 4);

endproperty

assert property (pc_inc)
	$display("assertion correct");
else
	$display("failed assertion");	
;

property pc_branch;

(pc_select == 1) |=> (pc_next == $past(pc_next) + alu_result)

endproperty

assert property (pc_branch)
	$display("branch assertion correct");
else
	$display("failed branch assertion");		
;


endmodule
