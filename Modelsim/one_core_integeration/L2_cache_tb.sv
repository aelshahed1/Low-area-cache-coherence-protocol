timeunit 1ns; timeprecision 100ps;

module L2_cache_tb;
parameter n = 32, block_size = 16;
 
logic clk,reset;
logic MM_busy; //clock enable from Main memory
//logic [n-3:0] full_address, //full 30-bit address
logic [14:0] L1_word_address; //15-bit address
logic [n-1:0] L1_wdata; //data coming from L1 cache 
logic L1_write_request,L1_read_request; // read and write requets from L1
//logic [n-1:0] L2_read_block [block_size-1:0], //block coming from L2
logic [n-1:0] MM_read_word; // 32-bit word coming from Main memory 
//logic [n-1:0] L2_read_block[block_size-1:0], //block coming from L2   
logic [n-1:0] L1_rdata; //sending requested data to L1 cache
//logic [14:0] block_address, //rethink size
logic [14:0] MM_word_address;
//logic [n-1:0] L2_write_block [block_size-1:0], //block to write to L2
logic [n-1:0] MM_write_word; // 32-bit word to write to Main memory
//logic [n-1:0] L2_write_block[block_size-1:0], //block to write to L2
logic MM_read_request, MM_write_request; // read and write requets to Main memory
logic L2_busy; 
logic flush; //signal to flush L1 caches

integer i;


L2_cache #(.n(n),.block_size(block_size)) my_L2
			(.clk(clk),.reset(reset),.MM_busy(MM_busy),.L1_word_address(L1_word_address),
			.L1_wdata(L1_wdata),.L1_write_request(L1_write_request),
			.L1_read_request(L1_read_request),.MM_read_word(MM_read_word),
			.L1_rdata(L1_rdata),.MM_word_address(MM_word_address),
			.MM_write_word(MM_write_word),.MM_read_request(MM_read_request),
			.MM_write_request(MM_write_request),.L2_busy(L2_busy),
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

MM_busy = 0;

@(negedge clk) L1_write_request = 1; 
//word_address = $urandom_range(32767,0);
L1_word_address = 1000; 
L1_wdata = 32'd8;

@(my_L2.state == 3);

for(i=0;i<16;i=i+1) begin
	  @(negedge clk);	
      MM_read_word = 5*i;
end

@(negedge clk) MM_busy = 1; L1_write_request = 1; 
@(negedge clk);
@(negedge clk) MM_busy = 0;

@(my_L2.state == 0) L1_write_request = 0; L1_read_request = 0;
$display("valu at dest = %d",my_L2.L2_cache_memory[my_L2.input_index][my_L2.input_offset]);

@(negedge clk);
@(negedge clk) L1_read_request = 1;
//@(my_L2.hit_counter == 1) $display("hit detected");

//#100 $stop;
end



initial begin	
	$monitor("At state %d,hit counter = %d, miss counter = %d",my_L2.state,my_L2.hit_counter,my_L2.miss_counter);	
end	

	
initial begin
forever begin
		#5
		if(my_L2.hit_counter == 1) begin
			$display("hit detected");
			#100 $stop;
		end		
	end
end	

endmodule

