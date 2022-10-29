timeunit 1ns; timeprecision 100ps;

module coherence_tb; 


parameter n = 32;

logic L1A_READ_REQUEST,L1B_READ_REQUEST; //read requests from L1s
logic L1A_WRITE_REQUEST,L1B_WRITE_REQUEST; //write requests from L1s

logic load_A,load_B; //load signals coming from dmem
logic store_A,store_B; //store signals coming from dmem

logic [n-1:0] L1A_write_word, L1B_write_word; //words to write from L1s to L2
logic [14:0] L1A_word_address,L1B_word_address; //addresses from L1s to L2

logic L2_busy_in; //L2_busy signal from L2

logic [n-1:0] L2_wdata; // data to write from L2 to specific L1

logic [n-1:0] L2_rdata; // data from L1 to write to L2

logic [14:0] L2_word_address; //address L2 recieves from L1

logic [n-1:0] L1A_read_word, L1B_read_word; //words to write from L2 to L1s

logic L2_write_request, L2_read_request; //requests passed on to L2

logic L2_busy_out_A,L2_busy_out_B; //L2_busy signal to L1s

//signals to inform L1s of operations happening in other cores
logic others_read_requests_A, others_read_requests_B; //signal to inform L1s that other cores are reading
logic others_write_requests_A, others_write_requests_B; //signal to inform L1s that other cores are writing

logic [4:0] others_block_tag_A, others_block_tag_B; //tag bits of operations in other L1s
logic [5:0] others_block_index_A, others_block_index_B; //index bits of operations in other L1s


coherence #(.n(n)) my_coherence (.*);


initial begin
L1B_WRITE_REQUEST = 0;
L1A_WRITE_REQUEST = 0;
L1B_READ_REQUEST = 0;


L1A_READ_REQUEST = 1;
L1A_word_address = 70;

L2_busy_in = 1;

#10

L1A_WRITE_REQUEST = 1;
L2_busy_in = 0;
L2_wdata = 5;

#10

L2_busy_in = 1;

#5
L2_busy_in = 0;
L1A_READ_REQUEST  =0;

L1A_WRITE_REQUEST = 0;



#10 $stop;
end


endmodule