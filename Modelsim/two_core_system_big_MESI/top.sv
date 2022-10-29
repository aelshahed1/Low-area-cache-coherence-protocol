timeunit 1ns; timeprecision 100ps;
module top #( parameter n = 32)  

(input logic clk, reset,
input logic L1_busy, //clock_enable for L1_cahce
input logic [n-1:0] dmem_rdata,
output logic load_control,store_control,
output logic [n-1:0] dmem_wdata,
output logic [14:0] address,
output logic program_done //clock_enable for L1_cahce
); 

//decoder signals
logic decoder_load_control;
logic decoder_store_control;

//ALU Signals
logic [3:0] alu_func; 
logic [n-1:0] multiplexed_a,multiplexed_b,ALU_result;
logic op1_pc,op1_ZERO;
logic [2:0] op2_immediate;

// Program Counter signals
localparam pc_size = 32; 
logic [1:0] pc_select;
logic [pc_size-1 : 0] pc_next,pc_plus_four_next; //output of pc into instmem
logic branch_instruction;

// Instruction Memory signals
localparam Isize = 32; // Isize - instruction width
localparam mem_size = 10; //instruction memory address width (could store 2^mem_size instructions)
logic [Isize-1:0] instruction_next; // I - instruction code

//comparator signals
logic eq,lt,ltu;

//register file signals
logic [n-1:0] data1,data2;
logic [2:0] write_sel;
logic [n-1:0] reg_file_rdata;

//data memory signals
logic stack_load_control;
logic stack_store_control;
logic [31:0] stack_dmem_rdata;

localparam dmem_size = 6; //stack size = 2^dmem_size

//instruction register signals
logic [Isize-1:0] instruction;
logic [pc_size-1 : 0] pc_plus_four;
logic [pc_size-1 : 0] pc;

// module instantiations
instr_mem #(.mem_size(mem_size),.Isize(Isize)) //program memory instantiation 
      instrMEMORY (.address(pc_next),.instruction(instruction_next));
	  
instr_reg #(.n(n)) I_reg (.clk(clk), .reset(reset), .L1_busy(L1_busy),
			.instruction_next(instruction_next),.branch_instruction(branch_instruction),
			.instruction(instruction),.pc_plus_four_next(pc_plus_four_next),
			.pc_plus_four(pc_plus_four), .pc(pc), .pc_next(pc_next)); 
	  
program_counter  #(.pc_size(pc_size)) progCounter (.clk(clk),.reset(reset), //program counter instantiation  
        .pc_select(pc_select), .L1_busy(L1_busy),
        .alu_result(ALU_result), .branch_instruction(branch_instruction),
		//.jal_address({{12{instruction_next[31]}},instruction_next[19:12],instruction_next[20],instruction_next[30:21],1'b0}),		
		.jal_address({{12{instruction[31]}},instruction[19:12],instruction[20],instruction[30:21],1'b0}),
		.pc_next(pc_next), .pc_plus_four_next(pc_plus_four_next) );

alu    #(.n(n))  ALU(.a(multiplexed_a),.b(multiplexed_b), //alu instantiation 
       .func(alu_func), .result(ALU_result)); 

comparator #(.n(n)) comp1(.a(data1),.b(data2),.eq(eq),.lt(lt),.ltu(ltu));

reg_file   #(.n(n))  regs(.clk(clk),.pc_plus_four(pc_plus_four), //register file instantiation
        .wdata(ALU_result),.external_input(reg_file_rdata), .write_sel(write_sel),
		.rs1(instruction[19:15]),  // source 1 register
		.rs2(instruction[24:20]),  // source 2 register
		.rd(instruction[11:7]), // destination register
        .data1(data1),.data2(data2));

decoder  Decoder (.opcode(instruction[6:0]),.eq(eq),.lt(lt),.ltu(ltu), //decoder instantiation
            .functs({instruction[31:25],instruction[14:12]}),
		  .alu_func(alu_func),.pc_sel(pc_select), .op2_immediate(op2_immediate),
		  .wdata_sel(write_sel),.op1_pc(op1_pc),.op1_ZERO(op1_ZERO),
		  .store_control(decoder_store_control),
		  .load_control(decoder_load_control),.program_done(program_done));		

data_mem #(.n(n),.dmem_size(dmem_size)) data_memory (.clk(clk),.dmem_wdata(data2),
				.address(address[5:0]),.load_control(stack_load_control),
				.store_control(stack_store_control),.dmem_rdata(stack_dmem_rdata));		  

always_comb begin
if(op2_immediate == 3'b001)
	multiplexed_b = {{21{instruction[31]}},instruction[30:20]};
else if(op2_immediate == 3'b010)
	multiplexed_b = {{21{instruction[31]}},instruction[30:25],instruction[11:7]};
else if(op2_immediate == 3'b011)
	multiplexed_b = {instruction[31:12],{12{1'b0}}};
else if(op2_immediate == 3'b100)
	multiplexed_b = {{20{instruction[31]}},instruction[7],instruction[30:25],instruction[11:8],1'b0};
else	
	multiplexed_b = data2;	
end

always_comb begin
if(op1_pc)
	multiplexed_a = pc;
else if(op1_ZERO)
	multiplexed_a = 32'd0;
else	
	multiplexed_a = data1;	
end

assign address = ALU_result[16:2];
assign dmem_wdata = data2;


always_comb begin //multiplexing loads and stores between stack and L1 cache
	if(decoder_load_control || decoder_store_control) begin
		if(address < 64) begin //stack operations
			reg_file_rdata = stack_dmem_rdata;
			stack_load_control = decoder_load_control;
			stack_store_control = decoder_store_control;
			load_control = 1'b0;
			store_control = 1'b0;
		end 
		else begin                        // L1 cache operations
			reg_file_rdata = dmem_rdata;
			load_control = decoder_load_control;
			store_control = decoder_store_control;
			stack_load_control = 1'b0;
			stack_store_control = 1'b0;
		end
	end
	else begin //default values
		reg_file_rdata = stack_dmem_rdata;
		load_control = 1'b0;
		store_control = 1'b0;
		stack_load_control = 1'b0;
		stack_store_control = 1'b0;
	end
end


//assign load_control = decoder_load_control;
//assign store_control = decoder_store_control;

endmodule
