timeunit 1ns; timeprecision 100ps;
module system #( parameter n = 32)  

(input logic clk, reset,
output logic program_done //program done led
); 

//riscv core signals
logic L1_busy; //clock_enable for L1_cahce
logic [n-1:0] dmem_rdata;
logic load_control,store_control;
logic [n-1:0] dmem_wdata;
logic [14:0] dmem_word_address;

//L1 cache signals
logic L2_busy;
logic flush; //control signal from L2 to flush all content
logic [n-1:0] L2_read_word; // 32-bit word coming from L2 
logic [14:0] L2_word_address;
logic [n-1:0] L2_write_word; // 32-bit word to write to L2
logic L2_read_request, L2_write_request;
localparam block_size = 16;

//L2 cache signals
logic MM_busy; //clock enable from Main memory
logic [n-1:0] MM_read_word; // 32-bit word coming from Main memory 
logic [14:0] MM_word_address;
logic [n-1:0] MM_write_word; // 32-bit word to write to Main memory
logic MM_read_request, MM_write_request; // read and write requets to Main memory


top #(.n(n)) riscv_core
(.clk(clk),.reset(reset),.L1_busy(L1_busy),.dmem_rdata(dmem_rdata),.load_control(load_control),
.store_control(store_control),.dmem_wdata(dmem_wdata),.address(dmem_word_address),
.program_done(program_done) );

L1_cache #(.n(n),.block_size(block_size))  L1_cache_memory
(.clk(clk),.reset(reset),.L2_busy(L2_busy),.dmem_rdata(dmem_rdata),.load(load_control),
.store(store_control),.dmem_word_address(dmem_word_address),.dmem_wdata(dmem_wdata),
.L1_busy(L1_busy),.flush(flush),.L2_read_word(L2_read_word),.L2_word_address(L2_word_address),
.L2_write_word(L2_write_word),.L2_read_request(L2_read_request),
.L2_write_request(L2_write_request) );

L2_cache #(.n(n),.block_size(block_size))  L2_cache_memory
(.clk(clk),.reset(reset),.L2_busy(L2_busy),.flush(flush),.MM_busy(MM_busy),
.L1_word_address(L2_word_address),.L1_wdata(L2_write_word),
.L1_write_request(L2_write_request),.L1_read_request(L2_read_request),
.MM_read_word(MM_read_word),.L1_rdata(L2_read_word),.MM_word_address(MM_word_address),
.MM_write_word(MM_write_word),.MM_read_request(MM_read_request),
.MM_write_request(MM_write_request)
);

main_memory #(.n(n)) my_main_memory
(.clk(clk),.reset(reset),.MM_busy(MM_busy),.L2_write_request(MM_write_request),
.L2_read_request(MM_read_request),.L2_word_address(MM_word_address),
.L2_wdata(MM_write_word),.L2_rdata(MM_read_word)
);



endmodule

