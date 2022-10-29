timeunit 1ns; timeprecision 100ps;

module L1_cache_tb;
parameter n = 32, block_size = 16;
 
logic clk,reset;
logic L2_busy; //clock enable from L2 cache
//logic [n-3:0] full_address; //full 30-bit address
logic [14:0] dmem_word_address; //15-bit address
logic [n-1:0] dmem_wdata; //data coming from register file
logic load,store;
logic [n-1:0] L2_read_word; // 32-bit word coming from L2 
//logic [n-1:0] L2_read_block [block_size-1:0]; //block coming from L2  
logic [n-1:0] dmem_rdata; //sending requested data to register file
logic [14:0] L2_word_address; //rethink size
logic [n-1:0] L2_write_word; // 32-bit word to write to L2
//logic [n-1:0] L2_write_block[block_size-1:0]; //block to write to L2
logic L2_read_request, L2_write_request;
logic L1_busy;
logic flush; //control signal from L2 to flush all content

integer i;


L1_cache #(.n(n),.block_size(block_size)) my_L1
			(.clk(clk),.reset(reset),.L2_busy(L2_busy),.dmem_word_address(dmem_word_address),
			.dmem_wdata(dmem_wdata),.load(load),.store(store),.dmem_rdata(dmem_rdata),
			.L2_read_word(L2_read_word),.L2_word_address(L2_word_address),
			.L2_write_word(L2_write_word),.L2_read_request(L2_read_request),
			.L2_write_request(L2_write_request),.L1_busy(L1_busy),
			.flush(flush)
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

L2_busy = 0;
flush = 0;

@(negedge clk) store = 1; 
//word_address = $urandom_range(32767,0);
dmem_word_address = 1000; 
dmem_wdata = 32'd8;

@(my_L1.state == 3);

for(i=0;i<16;i=i+1) begin
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

//#100 $stop;
end



initial begin	
	$monitor("At state %d,hit counter = %d, miss counter = %d",my_L1.state,my_L1.hit_counter,my_L1.miss_counter);	
end	

	
initial begin
forever begin
		#5
		if(my_L1.hit_counter == 1) begin
			$display("hit detected");
			#100 $stop;
		end		
	end
end	

endmodule
