timeunit 1ns; timeprecision 100ps;

module main_memory_tb;

parameter n = 32;
//parameter block_size = 16;

logic clk,reset;
logic L2_read_request,L2_write_request;
logic [14:0] L2_word_address; //15-bit address of data from L2 cache
logic [n-1:0] L2_wdata; //data coming from L2 cache 

logic [n-1:0] L2_rdata; //sending requested data to L2 cache
logic MM_busy;
 
 
main_memory #(.n(n)) my_main_memory
	(.clk(clk),.reset(reset),.MM_busy(MM_busy),.L2_word_address(L2_word_address),
	 .L2_read_request(L2_read_request),.L2_write_request(L2_write_request),
	 .L2_wdata(L2_wdata),.L2_rdata(L2_rdata)	
);	
 
initial begin
	clk = '0;
	#5ns reset = '0;
	#5ns reset = '1;
	#5ns reset = '0;
	forever #5ns clk = ~clk;
end	


initial begin

#27

@(negedge clk) L2_write_request = 1; 

L2_word_address = 32'hffffffff; 
L2_wdata = $urandom_range(999999,0);

@(my_main_memory.state == 1) $display("now reading/writing"); 

@(my_main_memory.state == 0)L2_write_request = 0;
$display("valu at dest = %d",my_main_memory.ram[L2_word_address]);

@(negedge clk);
@(negedge clk) L2_read_request = 1;

#200
$stop;

end




initial begin	
	$monitor("In state %d, address = %d, L2_wdata = %d , L2_rdata = %d ",my_main_memory.state,my_main_memory.L2_word_address,my_main_memory.L2_wdata,my_main_memory.L2_rdata);	
end	


endmodule