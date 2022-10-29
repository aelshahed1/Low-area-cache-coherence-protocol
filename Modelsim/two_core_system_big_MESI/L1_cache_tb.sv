timeunit 1ns; timeprecision 100ps;

module L1_cache_tb;
parameter n = 32, block_size = 16;
 
logic clk,reset;
logic L2_busy; //clock enable from L2 cache
logic [14:0] dmem_word_address; //15-bit address
logic [n-1:0] dmem_wdata; //data coming from register file
logic load,store;
logic [n-1:0] L2_read_word; // 32-bit word coming from L2 

//additional signals for coherence
logic others_read_request, others_write_request; // R/W requests from other L1s to L2
logic [4:0] others_block_tag; // tag bits for requests addresses from other cores
logic [5:0] others_block_index; //index bits of operations in other L1s

logic [n-1:0] dmem_rdata; //sending requested data to register file
logic [14:0] L2_word_address;
logic [n-1:0] L2_write_word; // 32-bit word to write to L2
logic L2_read_request, L2_write_request;
logic L1_busy;
logic [31:0] L1_statistics;
L1_cache #(.n(n),.block_size(block_size)) my_L1(.*);

initial begin
	clk = '0;
	#5ns reset = '0;
	#5ns reset = '1;
	#5ns reset = '0;
	forever #5ns clk = ~clk;
end	

initial begin

#27

L2_busy = 0;

@(negedge clk) store = 1; 
//word_address = $urandom_range(32767,0);
dmem_word_address = 1000; 
dmem_wdata = 32'd8;

@(my_L1.state == 3);

for(int i=0;i<16;i=i+1) begin
	  @(negedge clk);	
      L2_read_word = 5*i;
end

@(negedge clk) L2_busy = 1; store = 1; 
@(negedge clk);
@(negedge clk) L2_busy = 0;

@(my_L1.state == 0) store = 0; load = 0;
$display("valu at dest = %d",my_L1.L1_cache_memory[my_L1.input_index][my_L1.input_offset]);

@(negedge clk);
@(negedge clk) load = 1;
//@(my_L1.hit_counter == 1) $display("hit detected");

#1000 $stop;
end



initial begin	
	$monitor("At state %d,r_hit counter = %d, r_miss counter = %d,w_hit counter = %d, w_miss counter = %d",my_L1.state,my_L1.read_hit_counter,my_L1.read_miss_counter,my_L1.write_hit_counter,my_L1.write_miss_counter);	
end	

/*	
initial begin
forever begin
		#5
		if(my_L1.hit_counter == 1) begin
			$display("hit detected");
			#100 $stop;
		end		
	end
end	
*/


endmodule
