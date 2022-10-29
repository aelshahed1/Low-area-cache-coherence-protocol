timeunit 1ns; timeprecision 100ps;

module L1_cache #(parameter n = 32, block_size = 4)
(input logic clk,reset,
input logic L2_busy, //clock enable from L2 cache
input logic [9:0] dmem_word_address, //10-bit address
input logic [n-1:0] dmem_wdata, //data coming from register file
input logic load,store,
input logic [n-1:0] L2_read_word, // 32-bit word coming from L2 

//additional input signals for coherence
input logic others_read_request, others_write_request, // R/W requests from other L1s to L2
input logic [3:0] others_block_tag, // tag bits for requests addresses from other cores
input logic [3:0] others_block_index, //index bits of operations in other L1s

output logic [n-1:0] dmem_rdata, //sending requested data to register file
output logic [9:0] L2_word_address,
output logic [n-1:0] L2_write_word, // 32-bit word to write to L2
output logic L2_read_request, L2_write_request,
output logic L1_busy,
output logic [31:0] L1_statistics
);

//counters to store transactions statistics
logic [7:0] read_hit_counter,read_miss_counter,write_hit_counter,write_miss_counter;

assign L1_statistics = {read_hit_counter,read_miss_counter,write_hit_counter,write_miss_counter};

logic valid [15:0]; //ANDed valid bit for every block in cache

logic shared [15:0]; //shared bit for every block in cache to know if it is present in other L1s

logic [3:0] local_tag [15:0]; //4 tag bits for every block in cache

//16 cache blocks, every block contains 4 data elements * 32-bits = 128 bits
logic [n-1:0] L1_cache_memory [15:0][block_size-1:0];  


//10-bit address sections
logic [3:0] input_tag;
logic [3:0] input_index;
logic [1:0] input_offset;


logic [4:0] refill_counter; //change to 4 bits 

logic [1:0] output_loaded;

always_comb begin
input_tag = dmem_word_address[9:6];
input_index = dmem_word_address[5:2] ;
input_offset = dmem_word_address[1:0];
end

enum logic [2:0]{idle = 3'b000,compare_tag = 3'b001,cache_rw = 3'b010,
cache_refill = 3'b011,write_through=3'b100,buffer = 3'b101,
done = 3'b110, update_coherence = 3'b111} state;

//enum logic [2:0] {valid_block = 0, shared_block =1, invalid_block = 2} coherence_state;

assign L1_busy = (state == compare_tag) | (state == cache_rw) | (state == cache_refill) |
(state == write_through) | ((state == idle) & (load | store )) | 
//(state == buffer); //dont stall riscv when other core is r/w to L2
(state == buffer) | (state == update_coherence); //stall riscv when other core is r/w to L2

assign L2_read_request = (state == cache_refill) & (refill_counter < 5);
assign L2_write_request = ((state == write_through) & (output_loaded == 2)) | (state == buffer);

// cache control fsm
always_ff @(posedge clk,posedge reset) begin

if(reset) begin
	output_loaded <= 0;
	state <= idle;
	read_hit_counter <= '0;
	read_miss_counter <= '0;
	write_hit_counter <= '0;
	write_miss_counter <= '0;
	refill_counter <= '0;
	for(int i=0;i<15;i=i+1) begin
		valid[i] <= 1'b0;
		shared[i] <= 1'b0;
	end
end 
else begin

if(~L2_busy) begin
	unique case(state)

	idle: begin
	            output_loaded <= 0;
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
								
								//checking states of valid and shared bits
								case({valid[others_block_index],shared[others_block_index]}) 
								
								//2'b00: state <= idle; //invalid block, nothing to do
								
								//2'b01: state <= idle; //invalid block, nothing to do
								
								2'b10: begin  //valid and not shared
										
										if(others_read_request)
											shared[others_block_index] <= 1'b1; //block is now shared
										else if(others_write_request)
											valid[others_block_index] <= 1'b0; //block is now invalid
									 
									 end	
								
								2'b11: begin  //valid and shared
										
										if(others_write_request)
											valid[others_block_index] <= 1'b0; //block is now invalid
										
									  end
									  
								//default: state <= idle;
								
								
								endcase
					
							end
							
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
						L2_word_address<= {input_tag,input_index,refill_counter[1:0]};
						refill_counter <= refill_counter + 1;
					end
					else if(refill_counter < 6) begin
							L2_word_address<= {input_tag,input_index,refill_counter[1:0]};
							L1_cache_memory[input_index][refill_counter-2] <= L2_read_word;
							refill_counter <= refill_counter + 1;
					end
					else begin	
						local_tag[input_index] <= input_tag;
						valid[input_index] <= 1'b1;
						shared[input_index] <= 1'b0; //when data just comes from L2 it is not shared
						
						state<= cache_rw;
					end
					
				  end	

	cache_rw: begin
			
				if(store) begin
					L1_cache_memory[input_index][input_offset] <= dmem_wdata;
					state<= write_through;
				end	
				else if(load) begin
					dmem_rdata <= L1_cache_memory[input_index][input_offset];
					state<= done;
				end
					
			
			
			  end	

	write_through: begin
					output_loaded <= 1;
					if(output_loaded == 1) begin //data written into L1 from prev stage
						L2_word_address<= dmem_word_address;
						L2_write_word <= L1_cache_memory[input_index][input_offset];
						output_loaded <= output_loaded + 1;
					end
					else if(output_loaded == 2) begin //now data written out to buses
						state <= buffer;
					end
					
				   end
	buffer: state <= done;			   
	done: state <= idle;		   
				   
	default : state <= idle;
	endcase
end

end


end

endmodule

