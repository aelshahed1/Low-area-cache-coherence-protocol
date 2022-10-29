timeunit 1ns; timeprecision 100ps;
//Design of a 16K directly Mapped L2 cache, write_allocate, write-through
module L2_cache #(parameter n = 32, block_size = 16)
(input logic clk,reset,
input logic MM_busy, //clock enable from Main memory
//input logic [n-3:0] full_address, //full 30-bit address
input logic [14:0] L1_word_address, //15-bit address of data from L1 cache
input logic [n-1:0] L1_wdata, //data coming from L1 cache 
input logic L1_write_request,L1_read_request, // read and write requets from L1
//input logic [n-1:0] L2_read_block [block_size-1:0], //block coming from L2
input logic [n-1:0] MM_read_word, // 32-bit word coming from Main memory 
//input logic [n-1:0] L2_read_block[block_size-1:0], //block coming from L2   
output logic [n-1:0] L1_rdata, //sending requested data to L1 cache
//output logic [14:0] block_address, //rethink size
output logic [14:0] MM_word_address,
//output logic [n-1:0] L2_write_block [block_size-1:0], //block to write to L2
output logic [n-1:0] MM_write_word, // 32-bit word to write to Main memory
//output logic [n-1:0] L2_write_block[block_size-1:0], //block to write to L2
output logic MM_read_request, MM_write_request, // read and write requets to Main memory
output logic L2_busy, 
output logic flush //signal to flush L1 caches
);

//counters to store transactions statistics
//logic [12:0] transaction_counter;
//logic [11:0] read_hit_counter,read_miss_counter,write_hit_counter,write_miss_coutner;
logic [11:0] hit_counter,miss_counter;

logic valid [255:0]; //valid bit for every block in cache
//logic acquired [255:0]; //acquired bit for every block in cache

logic [2:0] local_tag [255:0]; //3 tag bits for every block in cache

//256 cache blocks, every block contains 16 data elements * 32-bits = 512 bits
logic [n-1:0] L2_cache_memory [255:0][block_size-1:0];  

//logic tag_found, memory_done,transaction_done; //signals to control the flow of the fsm

//only 15-bits to use from the 32-bit address
logic [2:0] input_tag;
logic [7:0] input_index;
logic [3:0] input_offset;

integer i; //32-bit integer to loop over arrays

logic [4:0] refill_counter; // counter to count items loaded in block change to 4 bits 

always_comb begin
input_tag = L1_word_address[14:12];
input_index = L1_word_address[11:4] ;
input_offset = L1_word_address[3:0];
end

enum logic [2:0]{idle = 0,compare_tag = 1,cache_rw = 2,cache_refill = 3,
 write_through=4} state;


assign L2_busy = (state != idle);
assign MM_read_request = (state == cache_refill);
assign MM_write_request = (state == write_through);

always_ff @(posedge clk,posedge reset) begin

if(reset) begin
	//L1_busy <= 1'b0;
	//L2_read_request <= 1'b0;
	//L2_write_request <= 1'b0;
	//transaction_counter <= '0;
	//read_hit_counter <= '0;
	//read_miss_counter <= '0;
	//write_hit_counter <= '0;
	//write_miss_coutner <= '0;
	hit_counter <= '0;
	miss_counter <= '0;
	refill_counter <= '0;
	for(i=0;i<255;i=i+1) begin
		valid[i] = 1'b0;
	end
end 
else begin

if(~MM_busy) begin
	unique case(state)

	idle: begin
				flush = 1'b0;
				refill_counter <= '0;
				if(L1_read_request || L1_write_request) begin
					state <= compare_tag;
				end
				/*
				if(flush == 1'b1) begin
					state <= flush_state;
				end
				*/
		   end

	compare_tag: begin
					if((input_tag == local_tag[input_index]) && (valid[input_index]) ) begin	
						state <= cache_rw;
						hit_counter <= hit_counter + 1;
						flush = 1'b1;
					end
					else begin
						state <= cache_refill;
						miss_counter <= miss_counter + 1;
					end				
				 end
				 
	cache_refill: begin
					
					
					//if(~L2_busy) begin
						
					//for(i=0;i<16;i=i+1)
					if(refill_counter < 16) begin
							L2_cache_memory[input_index][refill_counter] <= MM_read_word;
							refill_counter <= refill_counter + 1;
					end
					else begin	
						//L1_cache_memory[input_index] <= L2_read_block;
						local_tag[input_index] <= input_tag;
						valid[input_index] <= 1'b1;
						state<= cache_rw;
					end

				  end	

	cache_rw: begin
			
				if(L1_write_request) begin
					L2_cache_memory[input_index][input_offset] <= L1_wdata;
					state<= write_through;
				end	
				else if(L1_read_request) begin
					L1_rdata <= L2_cache_memory[input_index][input_offset];
					state<= idle;
				end
					
			
			
			  end	

	write_through: begin
					
					MM_word_address<= L1_word_address;
					MM_write_word <= L2_cache_memory[input_index][input_index];
					
					//for(i=0;i<16;i=i+1)
					//	L2_write_block[i] <= L1_cache_memory[input_index][i];
						
					//L2_write_block<= L1_cache_memory[input_index];
					
					state <= idle;
				   end
				   
/*	flush_state: begin
				 
				 for(i=0;i<64;i=i+1) begin
					valid[i] = 1'b0;
				 end	
		
				 end
*/
	default : state <= idle;
	endcase
end

end


end

endmodule


