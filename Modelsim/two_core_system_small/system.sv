timeunit 1ns; timeprecision 100ps;
module system #( parameter n = 32)  

(input logic clk, reset,
output logic [31:0] L1A_statistics,L1B_statistics,L2_statistics, // hit/miss statistics from caches
output logic program_done //program done led
); 

//riscv cores signals
logic L1_busy_A, L1_busy_B ; //clock_enable from L1_cahce
logic [n-1:0] dmem_rdata_A,dmem_rdata_B;
logic load_control_A,store_control_A,load_control_B,store_control_B;
logic [n-1:0] dmem_wdata_A,dmem_wdata_B;
logic [9:0] dmem_word_address_A,dmem_word_address_B;
logic program_done_A,program_done_B;

//L1 caches signals
logic L2_busy_A,L2_busy_B;
logic [n-1:0] L2_read_word_A,L2_read_word_B; // 32-bit word coming from L2 
logic [9:0] L2_word_address_A,L2_word_address_B;
logic [n-1:0] L2_write_word_A,L2_write_word_B; // 32-bit word to write to L2
logic L2_read_request_A, L2_write_request_A,L2_read_request_B, L2_write_request_B;

//aditional coherence signals for L1s
logic others_read_request_A, others_write_request_A,others_read_request_B, others_write_request_B; // R/W requests from other L1s to L2
logic [3:0] others_block_tag_A,others_block_tag_B; // tag bits for requests addresses from other cores
logic [3:0] others_block_index_A,others_block_index_B; //index bits of operations in other L1s

localparam block_size = 4;


//coherence signals
logic L2_write_request, L2_read_request; //requests passed on to L2
logic [9:0] L2_word_address; //address L2 recieves from L1
logic [n-1:0] L2_rdata;// data from L1 to write to L2


//L2 cache signals
logic L2_busy ; //clock_enable for L1_cahce
logic [n-1:0] MM_read_word; // 32-bit word coming from Main memory 
logic [9:0] MM_word_address;
logic [n-1:0] MM_write_word; // 32-bit word to write to Main memory
logic MM_read_request, MM_write_request; // read and write requets to Main memory
logic [n-1:0] L2_read_word; // 32-bit word coming from L2 


L2_cache #(.n(n),.block_size(block_size))  L2_cache_memory // L2 cache instantiation
(.clk(clk),.reset(reset),.L2_busy(L2_busy),
.L1_word_address(L2_word_address),.L1_wdata(L2_rdata),
.L1_write_request(L2_write_request),.L1_read_request(L2_read_request),
.MM_read_word(MM_read_word),.L1_rdata(L2_read_word),.MM_word_address(MM_word_address),
.MM_write_word(MM_write_word),.MM_read_request(MM_read_request),
.MM_write_request(MM_write_request),.L2_statistics(L2_statistics)
);


main_memory #(.n(n)) my_main_memory // Main memory instantiation
(.clk(clk),.reset(reset),.L2_write_request(MM_write_request),
.L2_read_request(MM_read_request),.L2_word_address(MM_word_address),
.L2_wdata(MM_write_word),.L2_rdata(MM_read_word)
);


coherence #(.n(n)) my_coherence_bus //coherence shared bus instantiation
(.L1A_READ_REQUEST(L2_read_request_A),.L1B_READ_REQUEST(L2_read_request_B),.L1A_WRITE_REQUEST(L2_write_request_A),
.L1B_WRITE_REQUEST(L2_write_request_B),.L1A_write_word(L2_write_word_A),.L1B_write_word(L2_write_word_B),
.L1A_word_address(L2_word_address_A),.L1B_word_address(L2_word_address_B),.L2_busy_in(L2_busy),.L2_wdata(L2_read_word),
//.L1A_word_address(dmem_word_address_A),.L1B_word_address(dmem_word_address_B),.L2_busy_in(L2_busy),.L2_wdata(L2_read_word),
.L2_rdata(L2_rdata),.L2_word_address(L2_word_address),.L1A_read_word(L2_read_word_A),.L1B_read_word(L2_read_word_B),
.L2_write_request(L2_write_request),.L2_read_request(L2_read_request),
.L2_busy_out_A(L2_busy_A),.L2_busy_out_B(L2_busy_B),.others_read_requests_A(others_read_request_A),
.others_read_requests_B(others_read_request_B),.others_write_requests_A(others_write_request_A),
.others_write_requests_B(others_write_request_B),

//.others_block_tag_A(others_block_tag_A),.others_block_tag_B(others_block_tag_B),
//.others_block_index_A(others_block_index_A),.others_block_index_B(others_block_index_B),

.load_A(load_control_A),.load_B(load_control_B),.store_A(store_control_A),.store_B(store_control_B)

);


top #(.n(n)) riscv_core_A  //Core A instantiation
(.clk(clk),.reset(reset),.L1_busy(L1_busy_A),.dmem_rdata(dmem_rdata_A),.load_control(load_control_A),
.store_control(store_control_A),.dmem_wdata(dmem_wdata_A),.address(dmem_word_address_A),
.program_done(program_done_A));

L1_cache #(.n(n),.block_size(block_size))  L1A_cache_memory //L1A cache instantiation
(.clk(clk),.reset(reset),.L2_busy(L2_busy_A),.dmem_rdata(dmem_rdata_A),.load(load_control_A),
.store(store_control_A),.dmem_word_address(dmem_word_address_A),.dmem_wdata(dmem_wdata_A),
.L1_busy(L1_busy_A),.L2_read_word(L2_read_word_A),.L2_word_address(L2_word_address_A),
.L2_write_word(L2_write_word_A),.L2_read_request(L2_read_request_A),
.L2_write_request(L2_write_request_A), .L1_statistics(L1A_statistics),
.others_read_request(others_read_request_A),.others_write_request(others_write_request_A),
.others_block_tag(dmem_word_address_B[9:6]),.others_block_index(dmem_word_address_B[5:2]) );

top2 #(.n(n)) riscv_core_B  //Core B instantiation
(.clk(clk),.reset(reset),.L1_busy(L1_busy_B),.dmem_rdata(dmem_rdata_B),.load_control(load_control_B),
.store_control(store_control_B),.dmem_wdata(dmem_wdata_B),.address(dmem_word_address_B),
.program_done(program_done_B));

L1_cache2 #(.n(n),.block_size(block_size))  L1B_cache_memory //L1B cache instantiation
(.clk(clk),.reset(reset),.L2_busy(L2_busy_B),.dmem_rdata(dmem_rdata_B),.load(load_control_B),
.store(store_control_B),.dmem_word_address(dmem_word_address_B),.dmem_wdata(dmem_wdata_B),
.L1_busy(L1_busy_B),.L2_read_word(L2_read_word_B),.L2_word_address(L2_word_address_B),
.L2_write_word(L2_write_word_B),.L2_read_request(L2_read_request_B),
.L2_write_request(L2_write_request_B), .L1_statistics(L1B_statistics),
.others_read_request(others_read_request_B),.others_write_request(others_write_request_B),
.others_block_tag(dmem_word_address_A[9:6]),.others_block_index(dmem_word_address_A[5:2]) );



assign program_done = program_done_A & program_done_B;

endmodule

