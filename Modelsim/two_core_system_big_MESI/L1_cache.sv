timeunit 1ns; timeprecision 100ps;

module L1_cache #(parameter n = 32, block_size = 16)
(input logic clk,reset,
input logic L2_busy, //clock enable from L2 cache
input logic [14:0] dmem_word_address, //15-bit address
input logic [n-1:0] dmem_wdata, //data coming from register file
input logic load,store,
input logic [n-1:0] L2_read_word, // 32-bit word coming from L2 

//additional input signals for coherence
input logic others_read_request, others_write_request, // R/W requests from other L1s to L2
input logic [4:0] others_block_tag, // tag bits for requests addresses from other cores
input logic [5:0] others_block_index, //index bits of operations in other L1s

output logic [n-1:0] dmem_rdata, //sending requested data to register file
output logic [14:0] L2_word_address,
output logic [n-1:0] L2_write_word, // 32-bit word to write to L2
output logic L2_read_request, L2_write_request,
output logic L1_busy,
output logic [31:0] L1_statistics
);

//counters to store transactions statistics
logic [7:0] read_hit_counter,read_miss_counter,write_hit_counter,write_miss_counter;

assign L1_statistics = {read_hit_counter,read_miss_counter,write_hit_counter,write_miss_counter};

logic valid [63:0]; //valid bit for every block in cache

logic shared [63:0]; //shared bit for every block in cache to know if it is present in other L1s

logic dirty [63:0]; //dirty bit for every block in cache to know if it is modified or not

logic [4:0] local_tag [63:0]; //5 tag bits for every block in cache

//64 cache blocks, every block contains 16 data elements * 32-bits = 512 bits
logic [n-1:0] L1_cache_memory [63:0][block_size-1:0];  


//only 18-bits to use from the 32-bit address
logic [4:0] input_tag;
logic [5:0] input_index;
logic [3:0] input_offset;


logic [4:0] refill_counter; 

logic [4:0] write_back_counter;

always_comb begin
input_tag = dmem_word_address[14:10];
input_index = dmem_word_address[9:4] ;
input_offset = dmem_word_address[3:0];
end

enum logic [2:0]{idle = 3'b000,compare_tag = 3'b001,cache_rw = 3'b010,
cache_refill = 3'b011,write_back=3'b100,buffer = 3'b101,
done = 3'b110, update_coherence = 3'b111} state;


assign L1_busy = (state == compare_tag) | (state == cache_rw) | (state == cache_refill) |
(state == write_back) | ((state == idle) & (load | store )) | 
(state == buffer) | (state == update_coherence); //stall riscv when other core is r/w to L2

assign L2_read_request = (state == cache_refill) & (refill_counter < 17);
assign L2_write_request = ((state == write_back) & (write_back_counter < 16)) | (state == buffer);

// cache control fsm
always_ff @(posedge clk,posedge reset) begin

if(reset) begin
	write_back_counter <= 0;
	state <= idle;
	read_hit_counter <= '0;
	read_miss_counter <= '0;
	write_hit_counter <= '0;
	write_miss_counter <= '0;
	refill_counter <= '0;
	for(int i=0;i<64;i=i+1) begin
		valid[i] <= 1'b0;
		shared[i] <= 1'b0;
		dirty[i] <= 1'b0;
	end
end 
else begin

if(~L2_busy) begin
	unique case(state)

	idle: begin
	            write_back_counter <= 0;
				refill_counter <= '0;
				if(load || store) begin //priority to own loads/stores
					state <= compare_tag;
				end
				else if(others_read_request || others_write_request) begin
					state <= update_coherence;
				end 
		   end

	update_coherence: begin
	
							if(others_block_tag == local_tag[others_block_index]) begin
								
								//checking states of valid, shared and dirty bits
								case({valid[others_block_index],shared[others_block_index],dirty[input_index]}) 
								
								3'b000: state <= idle; //if valid = 0, block is in invalid state, do nothing
								3'b001: state <= idle; //if valid = 0, block is in invalid state, do nothing
								3'b010: state <= idle; //if valid = 0, block is in invalid state, do nothing
								3'b011: state <= idle; //if valid = 0, block is in invalid state, do nothing
								
								3'b100: begin    //Exclusive state
										
										if(others_read_request)
											shared[others_block_index] <= 1'b1; //block is now shared
										else if(others_write_request)
											valid[others_block_index] <= 1'b0; //block is now invalid
										
										state <= idle;
										end
										
								3'b110: begin    //shared state
										
										if(others_write_request)
											valid[others_block_index] <= 1'b0; //block is now invalid
										
										state <= idle;
										end


								3'b101: begin    //Modified state
										
										if(others_write_request || others_read_request) begin
											valid[others_block_index] <= 1'b0; //block is now invalid
											state <= write_back; //need to write back because block is dirty
										end
										else 
											state <= idle;
											
										end				
										
								
							
								default: state <= idle;
								
								
								endcase
					
							end
							
							else
								state <= idle;	
	
						end

	compare_tag: begin
					if((input_tag == local_tag[input_index]) && (valid[input_index]) ) begin
						state <= cache_rw;
						if(load)
							read_hit_counter <= read_hit_counter + 1;
						else if(store)
							write_hit_counter <= write_hit_counter + 1;	
					end
					else if(dirty[input_index]) begin  //if block getting replaced is dirty, write back to L2
							state <= write_back;
						 end 
					else begin
						state <= cache_refill;
						L2_word_address<= dmem_word_address;
						if(load)
							read_miss_counter <= read_miss_counter + 1;
						else if(store)
							write_miss_counter <= write_miss_counter + 1;
						
					end				
				 end
				 
	cache_refill: begin
					
					if(refill_counter < 2) begin
						L2_word_address<= {input_tag,input_index,refill_counter[3:0]};
						refill_counter <= refill_counter + 1;
					end
					else if(refill_counter < 18) begin
							L2_word_address<= {input_tag,input_index,refill_counter[3:0]};
							L1_cache_memory[input_index][refill_counter-2] <= L2_read_word;
							refill_counter <= refill_counter + 1;
					end
					else begin	
						local_tag[input_index] <= input_tag;
						valid[input_index] <= 1'b1;
						shared[input_index] <= 1'b1; //when data just comes from L2 it is assumed shared
						dirty[input_index] <= 1'b0; //when data just comes from L2 it is not modified
						
						state<= cache_rw;
					end
					
				  end	

	cache_rw: begin
			
				if(store) begin
					L1_cache_memory[input_index][input_offset] <= dmem_wdata;
					dirty[input_index] <= 1'b1;
					state<= done;
				end	
				else if(load) begin
					dmem_rdata <= L1_cache_memory[input_index][input_offset];
					state<= done;
				end
					
			
			
			  end	

	write_back: begin
					if(write_back_counter <16) begin
						L2_word_address<= {input_tag,input_index,write_back_counter[3:0]};
						L2_write_word <= L1_cache_memory[input_index][write_back_counter[3:0]];
						write_back_counter <= write_back_counter + 1;
					end
					else
						state <= buffer;
						
				   end
	
	buffer: begin
			
			if(others_write_request || others_read_request) begin
				state <= idle; //wrote back succesfully before moving to invalid state
				dirty[input_index] = 1'b0; //block is now not dirty
			end
			else
				state <= cache_refill; //wrote back succesfully before replacing block 
	
			end
			
	done: state <= idle;		   
				   
	default : state <= idle;
	endcase
end

end


end


endmodule

