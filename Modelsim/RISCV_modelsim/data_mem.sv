timeunit 1ns; timeprecision 100ps;
module data_mem #(parameter n = 32,dmem_size = 7)
(input logic clk,
input logic [31:0] dmem_wdata,
input logic [14:0] address,
//input logic [n-3:0] address,
input logic [2:0] load_control,
input logic [1:0] store_control,
output logic [31:0] dmem_rdata);

logic [n-1:0] dmem [(1<<dmem_size)-1:0];
logic [n-1:0] read_value;

logic [dmem_size-1:0] local_address;

assign local_address = address[dmem_size-1:0];

assign read_value = dmem[local_address];

initial //initialise data memory to 0s
	$readmemh("dmem_init.hex", dmem);
	
always_ff @(posedge clk) //synchronous write
begin

if(store_control == 2'b01) //SW (store word)
	dmem[local_address] <= dmem_wdata;
	
else if(store_control == 2'b10) //SH (store half word)
	dmem[local_address] <= {{16{1'b0}},dmem_wdata[15:0]};

else if(store_control == 2'b11) //SB (store byte)
	dmem[local_address] <= {{24{1'b0}},dmem_wdata[7:0]};
	
end	

always_comb  //asynchronous read
begin

if(load_control == 3'b001) //LW (load word)
	dmem_rdata = read_value;

else if(load_control == 3'b010) //LH (load half word)
	dmem_rdata = {{16{read_value[1]}},read_value[15:0]};	
	
else if(load_control == 3'b011) //LHU (load half word unsigned)
	dmem_rdata = {{16{1'b0}},read_value[15:0]};		

else if(load_control == 3'b100) //LB (load byte)
	dmem_rdata = {{24{read_value[1]}},read_value[7:0]};	

else if(load_control == 3'b101) //LBU (load byte unsigned)
	dmem_rdata = {{24{1'b0}},read_value[7:0]};	

else	
	dmem_rdata = 32'd0;
end	
	
endmodule	



/* Memory to synthesise block ram

(input logic clk,
input logic [31:0] dmem_wdata,
input logic [14:0] address,
//input logic [n-3:0] address,
input logic load_control,
input logic store_control,
output logic [31:0] dmem_rdata);

logic [n-1:0] dmem [(1<<dmem_size)-1:0];
logic [n-1:0] read_value;

logic [dmem_size-1:0] local_address;

assign local_address = address[dmem_size-1:0];

assign read_value = dmem[local_address];

initial //initialise data memory to 0s
	$readmemh("dmem_init.hex", dmem);
	
always_ff @(posedge clk) //synchronous write
begin

if(store_control) //SW (store word)
	dmem[local_address] <= dmem_wdata;

if(load_control) //LW (load word)
	dmem_rdata <= read_value;

end	

*/