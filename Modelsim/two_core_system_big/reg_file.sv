timeunit 1ns; timeprecision 100ps;
module reg_file #(parameter n = 32)
(input logic clk, 
input logic [n-1:0] wdata, pc_plus_four, external_input,
input logic [2:0] write_sel, //001 = write_alu, 010 = jal_return, 100 = external
input logic [4:0] rs1,rs2,rd,
output logic [n-1:0] data1,data2);

logic [n-1:0] gpr [n-1:0]; //32 32-bit registers

initial //initialise data memory to 0s
	$readmemh("regs_init.hex", gpr);

//synchronous write
always_ff @(posedge clk)
begin

if(write_sel == 3'b001)
	gpr[rd] <= wdata;

else if (write_sel == 3'b010)
	gpr[rd] <= pc_plus_four;
	
else if (write_sel == 3'b100)	
	gpr[rd] <= external_input;

end


//asynchronous read, x0 will always output 0
always_comb
begin

		if (rs1==5'd0)
	         data1 =  {n{1'b0}};
        else  data1 = gpr[rs1];
	 
        if (rs2==5'd0)
	        data2 =  {n{1'b0}};
		else  data2 = gpr[rs2];	
end


endmodule