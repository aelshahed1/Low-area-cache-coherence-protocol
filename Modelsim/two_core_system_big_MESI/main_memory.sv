module main_memory #(parameter n = 32)
//Design of a 128K Main Memory
(input logic clk,reset,
input logic L2_read_request,L2_write_request,
input logic [14:0] L2_word_address, //15-bit address of data from L2 cache
input logic [n-1:0] L2_wdata, //data coming from L2 cache 
output logic [n-1:0] L2_rdata //sending requested data to L2 cache
);

//(* ram_style = "block" *) logic [n-1:0] ram [32767:0]; 
logic [n-1:0] ram [32767:0]; 


initial //initialise data memory to 0s
	$readmemh("MM_init.hex", ram);

always_ff @(posedge clk) begin
if(reset)
    L2_rdata <= '0;
else begin
    if(L2_write_request)
       ram[L2_word_address] <= L2_wdata; 
    else if(L2_read_request)
        L2_rdata <= ram[L2_word_address];

end
end





endmodule