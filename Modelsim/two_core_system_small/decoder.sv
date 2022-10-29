timeunit 1ns; timeprecision 100ps;
`include "opcodes.sv"
`include "alu_codes.sv"

module decoder( input logic [6:0] opcode, input logic [9:0] functs,
input logic eq,lt,ltu, //input flags from ALU and comparator
output logic [1:0] pc_sel, //signal to select program counter input 
output logic [2:0] op2_immediate , //op2 immediate 000=not,001=ALUI/LW/JALR,010=SW,011=LUI/AUIPC,100=branches
output logic [3:0] alu_func, // function signal for ALU
output logic [2:0] wdata_sel, //select signal for register file
output logic op1_pc, op1_ZERO,  //alu op1 to be program_counter value or 0
output logic load_control, //control signal for external data memory load instructions
output logic store_control, //control signal for external data memory store instructions
output logic program_done
);

logic take_branch;

always_comb
begin
//default values to control signals
take_branch = 1'b0;
pc_sel = 2'b00; //increment program counter
alu_func = `FNONE;
wdata_sel = 3'b000;
op1_pc = 1'b0; //op1 by default from register file (1 for AUIPC and Branches only)
op1_ZERO = 1'b0; //will be true only for LUI only
op2_immediate = 3'b00; //op2 by default from 
load_control = 1'b0; //default: dont load from external data memory
store_control = 1'b0; //default: dont store from external data memory
program_done = 1'b0; //led to turn on when program is finished

unique case(opcode) //assigning control signals to each instruction

`ADD: begin //this opcode is used for many instructions
	  	unique casez(functs)
		
		`funct_ADD: begin
					alu_func = `FADD;
					wdata_sel = 3'b001;
					end
		`funct_SUB: begin
				    alu_func = `FSUB;
					wdata_sel = 3'b001;
					end
		`funct_AND: begin
				    alu_func = `FAND;
					wdata_sel = 3'b001;
					end
		`funct_OR: begin
				    alu_func = `FOR;
					wdata_sel = 3'b001;
					end
		`funct_XOR: begin
				    alu_func = `FXOR;
					wdata_sel = 3'b001;
					end			
		`funct_SLT: begin
				    alu_func = `FSLT;
					wdata_sel = 3'b001;
					end	
		`funct_SLTU: begin
				    alu_func = `FSLTU;
					wdata_sel = 3'b001;
					end
		`funct_SLL: begin
				    alu_func = `FSLL;
					wdata_sel = 3'b001;
					end
		`funct_SRL: begin
				    alu_func = `FSRL;
					wdata_sel = 3'b001;
					end
		`funct_SRA: begin
				    alu_func = `FSRA;
					wdata_sel = 3'b001;
					end
		`funct_MUL: begin
				    alu_func = `FMULT;
					wdata_sel = 3'b001;
					end
		`funct_MULH: begin
				    alu_func = `FMULTH;
					wdata_sel = 3'b001;
					end	
		`funct_MULHSU: begin
				    alu_func = `FMULTH;
					wdata_sel = 3'b001;
					end	
		`funct_MULHU: begin
				    alu_func = `FMULTH;
					wdata_sel = 3'b001;
					end	
		default: $display("functs value not found %b", functs);			
		endcase			
	  end

`ADDI: begin //this opcode is used for many instructions
	  	unique casez(functs)
		
		`funct_ADDI: begin
					 program_done = 1'b1;	
					 alu_func = `FADD;
					 wdata_sel = 3'b001;
					 op2_immediate = 3'b001;
					 end
		`funct_ANDI: begin
					 alu_func = `FAND;
					 wdata_sel = 3'b001;
					 op2_immediate = 3'b001;
					 end
		`funct_ORI: begin
					 alu_func = `FOR;
					 wdata_sel = 3'b001;
					 op2_immediate = 3'b001;
					 end
		`funct_XORI: begin
					 alu_func = `FXOR;
					 wdata_sel = 3'b001;
					 op2_immediate = 3'b001;
					 end			 
		`funct_SLTI: begin
					 alu_func = `FSLT;
					 wdata_sel = 3'b001;
					 op2_immediate = 3'b001;
					 end
		`funct_SLTIU: begin
					 alu_func = `FSLTU;
					 wdata_sel = 3'b001;
					 op2_immediate = 3'b001;
					 end
		`funct_SLLI: begin
					 alu_func = `FSLL;
					 wdata_sel = 3'b001;
					 op2_immediate = 3'b001;
					 end
		`funct_SRLI: begin
					 alu_func = `FSRL;
					 wdata_sel = 3'b001;
					 op2_immediate = 3'b001;
					 end
		`funct_SRAI: begin
					 alu_func = `FSRA;
					 wdata_sel = 3'b001;
					 op2_immediate = 3'b001;
					 end
		default: $display("functs value not found %b", functs);				
		endcase		


	   end	

`LW: begin //this opcode is used for many instructions
	  	unique casez(functs)
		
		`funct_LW: begin
					 alu_func = `FADD;
					 wdata_sel = 3'b100;
					 op2_immediate = 3'b001;
					 load_control = 1'b1;
					 end
		`funct_LH: begin
					 alu_func = `FADD;
					 wdata_sel = 3'b100;
					 op2_immediate = 3'b001;
					 load_control = 1'b1;
					 end
		`funct_LHU: begin
					 alu_func = `FADD;
					 wdata_sel = 3'b100;
					 op2_immediate = 3'b001;
					 load_control = 1'b1;
					 end
		`funct_LB: begin
					 alu_func = `FADD;
					 wdata_sel = 3'b100;
					 op2_immediate = 3'b001;
					 load_control = 1'b1;
					 end
		`funct_LBU: begin
					 alu_func = `FADD;
					 wdata_sel = 3'b100;
					 op2_immediate = 3'b001;
					 load_control = 1'b1;
					 end
		default: $display("functs value not found %b", functs);			 
		endcase		

	   end			 

`SW: begin //this opcode is used for many instructions
	  	unique casez(functs)
		
		`funct_SW:   begin
					 alu_func = `FADD;
					 op2_immediate = 3'b010;
					 store_control = 1'b1;
					 end
		`funct_SH:   begin
					 alu_func = `FADD;
					 op2_immediate = 3'b010;
					 store_control = 1'b1;
					 end
		`funct_SB:   begin
					 alu_func = `FADD;
					 op2_immediate = 3'b010;
					 store_control = 1'b1;
					 end
		default: $display("functs value not found %b", functs);			 
		endcase
	 
	 end

`BEQ: begin //this opcode is used for many instructions
	  	unique casez(functs)
		
		`funct_BEQ:   begin
					 alu_func = `FADD;
					 op1_pc = 1'b1;
					 op2_immediate = 3'b100;
					 take_branch = eq;  //branch if equal flag = 1
					 end
		`funct_BNE:   begin
					 alu_func = `FADD;
					 op1_pc = 1'b1;
					 op2_immediate = 3'b100;
					 take_branch = ~eq;  //branch if equal flag = 0
					 end
		`funct_BLT:   begin
					 alu_func = `FADD;
					 op1_pc = 1'b1;
					 op2_immediate = 3'b100;
					 take_branch = lt;  //branch if less than flag = 1
					 end
		`funct_BLTU:   begin
					 alu_func = `FADD;
					 op1_pc = 1'b1;
					 op2_immediate = 3'b100;
					 take_branch = ltu;  //branch if less than unsigned flag = 1
					 end
		`funct_BGE:   begin
					 alu_func = `FADD;
					 op1_pc = 1'b1;
					 op2_immediate = 3'b100;
					 take_branch = ~lt;  //branch if less than flag = 0
					 end
		`funct_BGEU:   begin
					 alu_func = `FADD;
					 op1_pc = 1'b1;
					 op2_immediate = 3'b100;
					 take_branch = ~ltu;  //branch if less than unsigned flag = 0
					 end			 
		default: $display("functs value not found %b", functs);
		endcase
	 end

`JALR: begin
	    alu_func = `FADD;
		wdata_sel = 3'b010;
		op2_immediate = 3'b001;
		pc_sel = 2'b11;
	   end
	   
`JAL: begin
		program_done = 1'b1;
		wdata_sel = 3'b010;
		pc_sel = 2'b10;
	   end	   
	 
`AUIPC: begin
		alu_func = `FADD;
		op1_pc = 1'b1;
		op2_immediate = 3'b011;
		wdata_sel = 3'b001;
		end
		
`LUI: begin
		alu_func = `FADD;
		op1_ZERO = 1'b1;
		op2_immediate = 3'b011;
		wdata_sel = 3'b001;
	  end		
	 
default: begin
		 program_done = 1'b1;
		 $display("opcode not found %b", opcode);
		 end


endcase


if(take_branch)
	pc_sel = 2'b01;



end



endmodule