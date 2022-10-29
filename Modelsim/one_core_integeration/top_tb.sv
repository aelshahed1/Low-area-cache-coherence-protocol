timeunit 1ns; timeprecision 100ps;
module top_tb;

parameter n = 32;
logic clk, reset;
logic L1_busy;
logic program_done;

logic [n-1:0] dmem_rdata;
logic load_control,store_control;
logic [n-1:0] dmem_wdata;
logic [14:0] address;

top #(.n(n)) riscv(.*);
	
initial begin
	clk = '0;
	#5ns reset = '0;
	#5ns reset = '1;
	#5ns reset = '0;
	forever #5ns clk = ~clk;
end	

initial begin
L1_busy = '1;
#27
L1_busy = '0;

forever begin
			#5
		    if(riscv.instruction === 32'h0000006f) begin
				#20 $display("END OF PROGRAM"); 
				//for(int i=0;i<32;i=i+1) 
					//$display("value at reg %d = %d",i,riscv.regs.gpr[i]);
				$display("program_done signal = %b",program_done);
				$display("program elapsed time = %d ns", $time);
				$stop;
			end	
		end
		
end

/*
always_comb
begin
	if(riscv.instruction == 32'h00e7a023) begin	
		$display("store happening: alu_result = %b, address to dmem = %b, local address inside = %b", riscv.ALU_result, riscv.data_memory.address, riscv.data_memory.local_address);
		$display("store happening: alu_result = %d, address to dmem = %d, local address inside = %d", riscv.ALU_result, riscv.data_memory.address, riscv.data_memory.local_address);

	end
end
*/

initial begin 
$monitor("current instruction being excuted is %h, stack pointer = %d",riscv.instruction,riscv.regs.gpr[2]);
//$display(" ");
//$monitor("instruction memory select address is %d, \n%b", riscv.instrMEMORY.address,riscv.instrMEMORY.address);
end	

endmodule	