timeunit 1ns; timeprecision 100ps;
//Design of a 16K directly Mapped L2 cache, write_allocate, write-through
module L2_cache #(parameter n = 32, block_size = 4)
(input logic clk,reset,
input logic [9:0] L1_word_address, //10-bit address of data from L1 cache
input logic [n-1:0] L1_wdata, //data coming from L1 cache 
input logic L1_write_request,L1_read_request, // read and write requets from L1
input logic [n-1:0] MM_read_word, // 32-bit word coming from Main memory 
output logic [n-1:0] L1_rdata, //sending requested data to L1 cache
output logic [9:0] MM_word_address,
output logic [n-1:0] MM_write_word, // 32-bit word to write to Main memory
output logic MM_read_request, MM_write_request, // read and write requets to Main memory
output logic L2_busy,
output logic [31:0] L2_statistics
);

//logic [11:0] hit_counter,miss_counter;

//counters to store transactions statistics
logic [7:0] read_hit_counter,read_miss_counter,write_hit_counter,write_miss_counter;

assign L2_statistics = {read_hit_counter,read_miss_counter,write_hit_counter,write_miss_counter};

logic valid [63:0]; //valid bit for every block in cache

logic [1:0] local_tag [63:0]; //2 tag bits for every block in cache

//64 cache blocks, every block contains 4 data elements * 32-bits = 128 bits
logic [n-1:0] L2_cache_memory [63:0][block_size-1:0];  


//10-bit address sections
logic [1:0] input_tag;
logic [5:0] input_index;
logic [1:0] input_offset;


logic [7:0] mm_penalty_counter;

logic [4:0] refill_counter; // counter to count items loaded in block change to 4 bits 

logic [1:0] output_loaded;

always_comb begin
input_tag = L1_word_address[9:8];
input_index = L1_word_address[7:2] ;
input_offset = L1_word_address[1:0];
end

enum logic [2:0]{idle = 3'b000,compare_tag = 3'b001,cache_rw = 3'b010,
cache_refill = 3'b011, write_through=3'b100, done = 3'b101,
 mm_access_penalty = 3'b110} state;

assign L2_busy = (state == compare_tag) | ((state == cache_refill) ) | (state == mm_access_penalty) |
(state == write_through) | ((state == idle) & (L1_write_request | L1_read_request)); 

assign MM_read_request = (state == cache_refill) & (refill_counter < 5);
assign MM_write_request = ((state == write_through) & (output_loaded == 2));

always_ff @(posedge clk,posedge reset) begin

if(reset) begin
	output_loaded <= 0;
	state <= done;
	read_hit_counter <= '0;
	read_miss_counter <= '0;
	write_hit_counter <= '0;
	write_miss_counter <= '0;
	refill_counter <= '0;
	mm_penalty_counter <= '0;
	for(int i=0;i<63;i=i+1) begin
		valid[i] = 1'b0;
	end
end 
else begin

	unique case(state)

	idle: begin
	            output_loaded <= 0;
				refill_counter <= '0;
				mm_penalty_counter <= '0;
				if(L1_read_request || L1_write_request) begin
					state <= compare_tag;
				end
		   end

	compare_tag: begin
					if(~L1_read_request && ~L1_write_request)
						state <= idle;
					else if((input_tag == local_tag[input_index]) && (valid[input_index]) ) begin	
						state <= cache_rw;
						if(L1_read_request)
							read_hit_counter <= read_hit_counter + 1;
						else if(L1_write_request)	
							write_hit_counter <= write_hit_counter + 1;	
					end
					else begin
						state <= mm_access_penalty;
						if(L1_read_request)
							read_miss_counter <= read_miss_counter + 1;
						else if(L1_write_request)
							write_miss_counter <= write_miss_counter + 1;
					end				
				 end
				 
	mm_access_penalty: begin  //artificial delay introduces for MM access, 10 clock cycle per access
						
						if(mm_penalty_counter < 160)
							mm_penalty_counter <= mm_penalty_counter + 1;
						else	
							state <= cache_refill;
					  end
				 
	cache_refill: begin
					if(refill_counter < 2) begin
						MM_word_address<= {input_tag,input_index,refill_counter[1:0]};
						refill_counter <= refill_counter + 1;
					end
					else if(refill_counter < 6) begin
							MM_word_address<= {input_tag,input_index,refill_counter[1:0]};
							L2_cache_memory[input_index][refill_counter-2] <= MM_read_word;
							refill_counter <= refill_counter + 1;
					end
					else begin	
						local_tag[input_index] <= input_tag;
						valid[input_index] <= 1'b1;
						state<= cache_rw;
					end

				  end	

	cache_rw: begin
			
				if(L1_write_request) begin //reading data from L1
					L2_cache_memory[input_index][input_offset] <= L1_wdata;
					state<= write_through;
				end	
				else if(L1_read_request) begin //writing out to L1
					L1_rdata <= L2_cache_memory[input_index][input_offset];
				end
				else 
					state <= done;
					
			
			
			  end	

	write_through: begin
					output_loaded <= 1;
					if(output_loaded == 1) begin	
						MM_word_address<= L1_word_address;
						MM_write_word <= L2_cache_memory[input_index][input_offset];
						output_loaded <= output_loaded + 1;
					end
					else if(output_loaded == 2) begin //now data written out to buses
						state <= done;
					end
					
				   end
				   
	done: 	state <= idle;			   

	default : state <= idle;
	endcase

end


end

endmodule


