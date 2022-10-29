timeunit 1ns; timeprecision 100ps;

module coherence #(parameter n = 32)
(

input logic L1A_READ_REQUEST,L1B_READ_REQUEST, //input read requests from L1s
input logic L1A_WRITE_REQUEST,L1B_WRITE_REQUEST, //input write requests from L1s

input logic load_A,load_B, //load signals coming from dmem
input logic store_A,store_B, //store signals coming from dmem

input logic [n-1:0] L1A_write_word, L1B_write_word, //words to write from L1s to L2
input logic [14:0] L1A_word_address,L1B_word_address, //addresses from L1s to L2


input logic L2_busy_in, //L2_busy signal from L2

input logic [n-1:0] L2_wdata, // data to write from L2 to specific L1

output logic [n-1:0] L2_rdata, // data from L1 to write to L2

output logic [14:0] L2_word_address, //address L2 recieves from L1

output logic [n-1:0] L1A_read_word, L1B_read_word, //words to write from L2 to L1s

output logic L2_write_request, L2_read_request, //requests passed on to L2

output logic L2_busy_out_A,L2_busy_out_B, //L2_busy signal to L1s

//signals to inform L1s of operations happening in other cores
output logic others_read_requests_A, others_read_requests_B, //signal to inform L1s that other cores are reading
output logic others_write_requests_A, others_write_requests_B //signal to inform L1s that other cores are writing

//output logic [4:0] others_block_tag_A, others_block_tag_B, //tag bits of operations in other L1s
//output logic [5:0] others_block_index_A, others_block_index_B //index bits of operations in other L1s
);

always_comb begin

//default values
L2_write_request = 0;
L2_read_request = 0;
L2_word_address = L1A_word_address;
L1A_read_word = L2_wdata;
L1B_read_word = L2_wdata;
L2_busy_out_A = 0;
L2_busy_out_B = 0;
others_read_requests_A = load_B;
others_read_requests_B = load_A;
others_write_requests_A = store_B;
others_write_requests_B = store_A;
L2_rdata = L1A_write_word;

//others_block_tag_A = L1B_word_address[14:10];
//others_block_index_A = L1B_word_address[9:4];
//others_block_tag_B = L1A_word_address[14:10];
//others_block_index_B = L1A_word_address[9:4];

//priority given in this order in case of conflicting requests

//if(L1A_READ_REQUEST) begin // L1A read operation
if(load_A || store_A) begin // L1A read operation

L2_read_request = L1A_READ_REQUEST;
L2_write_request = L1A_WRITE_REQUEST;
L2_word_address = L1A_word_address;
L1A_read_word = L2_wdata;
L2_busy_out_A = L2_busy_in;
L2_rdata = L1A_write_word;
//L2_busy_out_B = 1;
//others_read_requests_B = 1;

	if(L1A_READ_REQUEST || L1A_WRITE_REQUEST)
		L2_busy_out_B = 1;

end
//else if(L1B_READ_REQUEST) begin // L1B read operation
else if(load_B || store_B) begin // L1B read operation

L2_read_request = L1B_READ_REQUEST;
L2_write_request = L1B_WRITE_REQUEST;
L2_word_address = L1B_word_address;
L1B_read_word = L2_wdata;
L2_busy_out_B = L2_busy_in;
L2_rdata = L1B_write_word;
//L2_busy_out_A = 1;
//others_read_requests_A = 1;

	if(L1B_READ_REQUEST || L1B_WRITE_REQUEST)
		L2_busy_out_A = 1;


end
/*
//else if(L1A_WRITE_REQUEST) begin // L1A write operation
else if(store_A) begin // L1A write operation

L2_write_request = L1A_WRITE_REQUEST;
L2_word_address = L1A_word_address;
L2_busy_out_A = L2_busy_in;
//L2_busy_out_B = 1;
//others_write_requests_B = 1;
L2_rdata = L1A_write_word;

if(L1A_WRITE_REQUEST)
		L2_busy_out_B = 1;

end
*/
/*
//else if(L1B_WRITE_REQUEST) begin // L1B write operation
else if(store_B) begin // L1B write operation

L2_write_request = L1B_WRITE_REQUEST;
L2_word_address = L1B_word_address;
L2_busy_out_B = L2_busy_in;
//L2_busy_out_A = 1;
//others_write_requests_A = 1;
//L2_rdata = L1B_write_word;

if(L1B_WRITE_REQUEST)
		L2_busy_out_A = 1;

end
*/

end


endmodule