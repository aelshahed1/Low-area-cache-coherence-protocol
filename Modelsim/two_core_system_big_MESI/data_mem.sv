timeunit 1ns; timeprecision 100ps;
module data_mem #(parameter n = 32,dmem_size = 8)
(input logic clk,
input logic [31:0] dmem_wdata,
input logic [5:0] address, 
//input logic [n-3:0] address,
input logic load_control,
input logic store_control,
output logic [31:0] dmem_rdata);

logic [n-1:0] dmem [(1<<dmem_size)-1:0];

initial //initialise data memory to 0s
	$readmemh("dmem_init.hex", dmem);
	
always_ff @(posedge clk) //synchronous write
begin

if(store_control) //SW (store word)
	dmem[address] <= dmem_wdata;
	
end	

always_comb  //asynchronous read
begin

if(load_control) //LW (load word)
	dmem_rdata = dmem[address];
else	
	dmem_rdata = 32'd0;
end	
	
endmodule	
