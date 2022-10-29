timeunit 1ns; timeprecision 100ps;

module L1_cache #(parameter n = 32, block_size = 16)
(input logic clk,reset,
input logic L2_busy, //clock enable from L2 cache
//input logic [n-3:0] full_address, //full 30-bit address
input logic [14:0] dmem_word_address, //15-bit address
input logic [n-1:0] dmem_wdata, //data coming from register file
//input logic [1:0] cpu_request, 
//input logic [2:0] load_control, //load control signals from decoder
//input logic [1:0] store_control, //store control signals from decoder
input logic load,store,
input logic flush, //control signal from L2 to flush all content
//input logic [n-1:0] L2_read_block [block_size-1:0], //block coming from L2
input logic [n-1:0] L2_read_word, // 32-bit word coming from L2 
//input logic [n-1:0] L2_read_block[block_size-1:0], //block coming from L2   
output logic [n-1:0] dmem_rdata, //sending requested data to register file
//output logic [14:0] block_address, //rethink size
output logic [14:0] L2_word_address,
//output logic [n-1:0] L2_write_block [block_size-1:0], //block to write to L2
output logic [n-1:0] L2_write_word, // 32-bit word to write to L2
//output logic [n-1:0] L2_write_block[block_size-1:0], //block to write to L2
output logic L2_read_request, L2_write_request,
output logic L1_busy
);

//counters to store transactions statistics
//logic [12:0] transaction_counter;
//logic [11:0] read_hit_counter,read_miss_counter,write_hit_counter,write_miss_coutner;
logic [11:0] hit_counter,miss_counter;

logic valid [63:0]; //valid bit for every block in cache

logic [4:0] local_tag [63:0]; //5 tag bits for every block in cache

//64 cache blocks, every block contains 16 data elements * 32-bits = 512 bits
logic [n-1:0] L1_cache_memory [63:0][block_size-1:0];  

//logic tag_found, memory_done,transaction_done; //signals to control the flow of the fsm

//only 18-bits to use from the 32-bit address
logic [4:0] input_tag;
logic [5:0] input_index;
logic [3:0] input_offset;

integer i; //32-bit integer to loop over arrays

logic [4:0] refill_counter; //change to 4 bits 

logic [1:0] output_loaded;

always_comb begin
input_tag = dmem_word_address[14:10];
input_index = dmem_word_address[9:4] ;
input_offset = dmem_word_address[3:0];
end

enum logic [2:0]{idle = 0,compare_tag = 1,cache_rw = 2,cache_refill = 3,
 write_through=4,buffer = 5,done = 6} state;


assign L1_busy = (state == compare_tag) | (state == cache_rw) | (state == cache_refill) |
(state == write_through) | ((state == idle) & (load | store)) | (state == buffer);
//assign L1_busy = (state != idle);
//assign L2_read_request = (state == cache_refill) & (refill_counter < 16);
assign L2_read_request = (state == cache_refill) & (refill_counter < 17);
assign L2_write_request = ((state == write_through) & (output_loaded == 2)) | (state == buffer);

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
	output_loaded <= 0;
	state <= idle;
	hit_counter <= '0;
	miss_counter <= '0;
	refill_counter <= '0;
	for(i=0;i<64;i=i+1) begin
		valid[i] <= 1'b0;
	end
end 
else begin

if(flush == 1'b1) begin //this assumes L2 will be busy while sending the flush signal
	for(i=0;i<64;i=i+1) begin
		valid[i] = 1'b0;
	end
	state <= idle;
end

if(~L2_busy) begin
	unique case(state)

	idle: begin
	            output_loaded <= 0;
				refill_counter <= '0;
				if(load || store) begin
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
					end
					else begin
						state <= cache_refill;
						miss_counter <= miss_counter + 1;
						L2_word_address<= dmem_word_address;
					end				
				 end
				 
	cache_refill: begin
					///*
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
						//L1_cache_memory[input_index] <= L2_read_block;
						local_tag[input_index] <= input_tag;
						valid[input_index] <= 1'b1;
						state<= cache_rw;
					end
					//*/
				/*
				  if(refill_counter < 16) begin
							L2_word_address<= {input_tag,input_index,refill_counter[3:0]};
							L1_cache_memory[input_index][refill_counter-1] <= L2_read_word;
							
							
							//L1_cache_memory[input_index][refill_counter] <= L2_read_word;
							refill_counter <= refill_counter + 1;
					end
					else begin	
						//L1_cache_memory[input_index] <= L2_read_block;
						local_tag[input_index] <= input_tag;
						valid[input_index] <= 1'b1;
						state<= cache_rw;
					end
				*/
						
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
					//for(i=0;i<16;i=i+1)
					//	L2_write_block[i] <= L1_cache_memory[input_index][i];
						
					//L2_write_block<= L1_cache_memory[input_index];
					
					
				   end
	buffer: state <= done;			   
	done: state <= idle;		   
				   
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

