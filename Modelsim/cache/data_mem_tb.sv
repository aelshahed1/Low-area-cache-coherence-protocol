timeunit 1ns; timeprecision 100ps;

module data_mem_tb;

parameter n = 32,dmem_size = 7;

logic clk;
logic [31:0] dmem_wdata;
logic [n-3:0] address;
logic [2:0] load_control;
logic [1:0] store_control;
logic [31:0] dmem_rdata;


data_mem #(.n(n),.dmem_size(dmem_size)) data_memory(.*);

initial begin
clk = '0;
forever #5 clk = ~clk;
end

initial begin

#22

load_control = 3'b000;
store_control = 2'b01;

dmem_wdata = 55;
address = 20;

#30

load_control = 3'b001;
store_control = 2'b00;

address = 20;

#20 $finish;
end


initial begin
$monitor("address %d in memory contains  = %d", address,data_memory.dmem[address]);
end

endmodule
