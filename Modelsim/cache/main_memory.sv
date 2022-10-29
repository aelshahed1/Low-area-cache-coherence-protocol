//module main_memory #(parameter n = 32, block_size = 16)
module main_memory #(parameter n = 32)
//Design of a 128K Main Memory
(input logic clk,reset,
input logic L2_read_request,L2_write_request,
input logic [14:0] L2_word_address, //15-bit address of data from L2 cache
input logic [n-1:0] L2_wdata, //data coming from L2 cache 

output logic [n-1:0] L2_rdata, //sending requested data to L2 cache
output logic MM_busy
);

//2048 cache blocks, every block contains 16 data elements * 32-bits = 512 bits
//logic [n-1:0] ram [2047:0][block_size-1:0];  

//other implementation without cache blocks
//32k spaces of 32-bit words
logic [n-1:0] ram [32767:0]; 

/*
//only 15-bits to use from the 32-bit address
logic [2:0] input_tag;
logic [7:0] input_index;
logic [3:0] input_offset;

always_comb begin
input_index = L2_word_address[14:4] ;
input_offset = L2_word_address[3:0];
end
*/


enum logic [1:0]{idle = 0, L2_rw = 1} state;

assign MM_busy = (state != idle);

always_ff @(posedge clk,posedge reset) begin

if(reset) begin
state <= idle;
end
else begin

	unique case(state)

	idle: begin

		  if(L2_read_request || L2_write_request) begin
					state <= L2_rw;
		  end
				
		  end
		  
	L2_rw: begin
			if(L2_write_request) begin
				//ram[input_index][input_offset] <= L2_wdata;
				ram[L2_word_address] <= L2_wdata;
				state <= idle;
			end
			else if(L2_read_request) begin
				//L2_rdata <= ram[input_index][input_offset];
				L2_rdata <= ram[L2_word_address];
				state <= idle;
			end
			
		   end
	default : state <= idle;
	endcase
end

end


endmodule
