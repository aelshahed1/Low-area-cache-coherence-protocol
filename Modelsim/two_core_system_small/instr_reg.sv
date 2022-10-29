timeunit 1ns; timeprecision 100ps;
module instr_reg #(parameter n = 32)
(input logic clk,reset,L1_busy,
input logic branch_instruction,
input logic [n-1:0] instruction_next, pc_next, pc_plus_four_next,
output logic [n-1:0] instruction,pc, pc_plus_four );

always_ff @(posedge clk,posedge reset)
begin
if(reset)
	begin
	instruction <= 32'h00000013; //NOP
	end
else
	begin
		if(~L1_busy) begin//clock enable from memory heirarchy	
			if(branch_instruction)
				instruction <= 32'h00000013; //NOP
			else	
				instruction <= instruction_next;
			
			pc <= pc_next;
			pc_plus_four <= pc_plus_four_next;
		end
	end
end

endmodule