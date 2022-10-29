timeunit 1ns; timeprecision 100ps;
module program_counter #(parameter pc_size = 32)
(input logic clk,reset,L1_busy,
input logic [1:0] pc_select,
input logic [pc_size-1:0] alu_result,jal_address,
output logic [pc_size-1:0] pc_next,pc_plus_four_next,
output logic branch_instruction
);

logic [pc_size-1:0] delayed_pc;
logic delay_happening,enable_pc;

always_ff @(posedge clk, posedge reset)
begin
if(reset)
	begin
	pc_next <= {pc_size{1'b0}};
	//branch_instruction <= 1'b0;
	end
else
	begin
		if(~L1_busy) //clock enable from memory heirarchy	
			begin
			if(pc_select == 2'b00) //increment
				pc_next <= pc_next + 4;
			else if(pc_select == 2'b01) //conditional branches
				//pc_next <= pc_next + alu_result;
				pc_next <= alu_result;
			else if(pc_select == 2'b10) //jal 
				begin
				//delay_happening <= 1'b1;
				//delayed_pc <= pc_next + jal_address;
				pc_next <= pc_next + jal_address - 4;
				end
			else  if(pc_select == 2'b11) //jalr
				pc_next <= {alu_result[pc_size-1:1],1'b0}; //LSB must be 0
		
			pc_plus_four_next<= pc_next + 8;	
			end
			
			/*
			if(delay_happening == 1'b1)
				begin
				pc_next <= delayed_pc;
				delay_happening <= 1'b0;
				end
			*/
			
			/*
			if(pc_select == 2'b00) //if branch, flush fetched instruction
				branch_instruction <= 1'b0;
			else	
				branch_instruction <= 1'b1;
			*/	
	end
end



assign branch_instruction = ~(pc_select === 2'b00);

endmodule
