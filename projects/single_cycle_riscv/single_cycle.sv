
// Apply immediate field decoding and extend it to signed 32 bit value.
// See courses/ch07.md
module extend
		(input logic [31:7] Imm,
		 input logic [1:0] ImmSrc,
		 output logic [31:0] ImmExt);
	always_comb
		case (ImmSrc)
			2'b00: ImmExt = {{20{Imm[31]}}, Imm[31:20]};
			2'b01: ImmExt = {{20{Imm[31]}}, Imm[31:25], Imm[11:7]};
			2'b10: ImmExt = {{19{Imm[31]}}, Imm[31], Imm[7],
							 Imm[30:25], Imm[11:8], 1'b0};
			2'b11: ImmExt = {{11{Imm[31]}}, Imm[31], Imm[19:12],
							 Imm[20], Imm[30:21], 1'b0};
		endcase
endmodule

// Control unit is separate into main decoder and ALU decoder.
// It also produce PCSrc depending on previous control value.
// See courses/ch07.md
module control_unit
		(input logic [6:0] op,
		 input logic [2:0] funct3,
		 input logic funct7_5,
		 input logic zero,
		 output logic RegWrite,
		 output logic [1:0] ImmSrc,
		 output logic ALUSrc,
		 output logic MemWrite,
		 output logic [1:0] ResultSrc,
		 output logic PCSrc,
		 output logic Jump,
		 output logic [2:0] ALUControl);
	logic Branch;
	logic [1:0] ALUOp;

	main_decoder main_decoder_i(
		.op(op),
		.RegWrite(RegWrite),
		.ImmSrc(ImmSrc),
		.ALUSrc(ALUSrc),
		.MemWrite(MemWrite),
		.ResultSrc(ResultSrc),
		.Branch(Branch),
		.ALUOp(ALUOp),
		.Jump(Jump)
	);

	alu_decoder alu_decoder_i(
		.ALUOp(ALUOp),
		.funct3(funct3),
		.op_5(op[5]),
		.funct7_5(funct7_5),
		.ALUControl(ALUControl)
	);

	assign PCSrc = (Branch & zero) | Jump;
endmodule

// Main decoder produce control value that's not related to ALU.
// See courses/ch07.md
module main_decoder
		(input logic [6:0] op,
		 output logic RegWrite,
		 output logic [1:0] ImmSrc,
		 output logic ALUSrc,
		 output logic MemWrite,
		 output logic [1:0] ResultSrc,
		 output logic Branch,
		 output logic [1:0] ALUOp,
		 output logic Jump);
	always_comb begin
		RegWrite = 1'b0;
		ImmSrc = 2'b00;
		ALUSrc = 1'b0;
		MemWrite = 1'b0;
		ResultSrc = 2'b00;
		Branch = 1'b0;
		ALUOp = 2'b00;
		Jump = 1'b0;

		case (op)
			7'b0000011: begin // lw
				RegWrite = 1'b1;
				ALUSrc = 1'b1;
				ResultSrc = 2'b01;
			end
			7'b0100011: begin // sw
				ImmSrc = 2'b01;
				ALUSrc = 1'b1;
				MemWrite = 1'b1;
			end
			7'b0110011: begin // R-type
				RegWrite = 1'b1;
				ALUOp = 2'b10;
			end
			7'b1100011: begin // beq
				ImmSrc = 2'b10;
				Branch = 1'b1;
				ALUOp = 2'b01;
			end
			7'b0010011: begin // I-type ALU
				RegWrite = 1'b1;
				ALUSrc = 1'b1;
				ALUOp = 2'b10;
			end
			7'b1101111: begin // jal
				RegWrite = 1'b1;
				ImmSrc = 2'b11;
				ResultSrc = 2'b10;
				ALUOp = 2'b10;
				Jump = 1'b1;
			end
			default: ;
		endcase
	end
endmodule

// ALU decoder produce ALUcontrol value.
// See courses/ch07.md
module alu_decoder
		(input logic [1:0] ALUOp,
		 input logic [2:0] funct3,
		 input logic op_5,
		 input logic funct7_5,
		 output logic [2:0] ALUControl);
	always_comb
		case (ALUOp)
			2'b00: ALUControl = 3'b000; // add
			2'b01: ALUControl = 3'b001; // subtract
			default:
				case (funct3)
					3'b000:
						if (op_5 & funct7_5)
							ALUControl = 3'b001; // sub
						else
							ALUControl = 3'b000; // add
					3'b010: ALUControl = 3'b101; // slt
					3'b110: ALUControl = 3'b011; // or
					3'b111: ALUControl = 3'b010; // and
					default: ALUControl = 3'bxxx;
				endcase
		endcase
endmodule

// Used for instruction memory and data memory (2 separate instance)
// N * M bits storages.
// For 4096 words of 32 bits use N=12 M=32
module ram #(parameter N = 12, M = 32)
			(input logic 		clk,
			 input logic 		we,
			 input logic 		[N-1:0] addr,
			 input logic 		[M-1:0] din,
			 output logic 		[M-1:0] dout);
	logic [M-1:0] mem [2**N-1:0];

	always_ff @(posedge clk) begin
		if (we)
			mem[addr] <= din;

		dout <= mem[addr];
	end
	
endmodule

// Resettable register for PC
module register #(parameter N = 32)
				(input logic clk,
				input logic reset,
				input logic [N-1:0] d,
				output logic [N-1:0] q);
	always_ff @(posedge clk)
		q <= (reset == 1 ? 0 : d);
endmodule

module regfile #(parameter N = 32)
				(input logic clk,
				input logic we3,
				input logic [4:0] a1, a2, a3,
				input logic [N-1:0] wd3,
				output logic [N-1:0] rd1, rd2);
	logic [N-1:0] rf[N-1:0];
	// read two ports combinationally (A1/RD1, A2/RD2)
	// write third port on rising edge of clock (A3/WD3/WE3)
	// register 0 hardwired to 0
	always_ff @(posedge clk)
		if (we3) rf[a3] <= wd3;

	assign rd1 = (a1 != 0) ? rf[a1] : 0;
	assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule

module alu #(parameter N = 32)
			(input logic [N-1:0] a, b,
				input logic [2:0] alu_control,
				output logic zero,
				output logic [N-1:0] c);
	always_comb
		begin
			case (alu_control)
				3'b000: c = a + b;
				3'b001: c = a - b;
				3'b010: c = a & b;
				3'b011: c = a | b;
				3'b101: c = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; 
				default: c = 32'bx;
			endcase
			zero = (c == 0 ? 1'b1 : 1'b0);
		end
endmodule

module single_cycle (input logic reset,
						input logic clk);
    localparam int N_INST = 12;
    localparam int N_DATA = 12;
    localparam int M = 32;

	logic pc_src; // Control value for choosing PC_next source
	logic memory_write; // Control value for data_mem write
	logic register_write; // Control value for regs register write
	logic [31:0] pc;
	logic [31:0] pc_next;
	logic [31:0] pc_plus_4; // Potential PC_next (normal), depends on PC_src.
	logic [31:0] pc_target; // Potential PC_next (branch), depends on PC_src.
	logic [31:0] instruction; // output of inst_mem
	logic [31:0] write_data; // input of data_mem
	logic [31:0] read_data; // output of data_mem
	logic [1:0] result_src; // control value to select the result source.
	logic [31:0] result; // final output, after mux selection
	logic [31:0] src_a; // first input of ALU
	logic [31:0] src_b; // second input of ALU
	logic alu_zero; // output of ALU, zero flag
	logic alu_src; // control value to set wether src_b come from imm or reg
	logic [2:0] alu_control; // control value for ALU operations
	logic [31:0] alu_result; // output of ALU
	logic [1:0] imm_src; // control value for immediate extend computation
	logic [31:0] imm_ext; // immediate value extended to 32bit signed

	register PC_reg(
		.clk(clk),
		.reset(reset),
		.d(pc_next),
		.q(pc)
	);
	ram #(.N(N_INST), .M(M)) inst_mem (
		.clk(clk),
		.addr(pc[N_INST+1:2]),
		.dout(instruction)
	);
	ram #(.N(N_DATA), .M(M)) data_mem (
		.clk(clk),
		.din(write_data),
		.we(memory_write),
		.addr(alu_result[N_DATA+1:2]),
		.dout(read_data)
	);
	regfile regs (
		.clk(clk),
		.we3(register_write),
		.a1(instruction[19:15]),
		.a2(instruction[24:20]),
		.a3(instruction[11:7]),
		.wd3(result),
		.rd1(src_a),
		.rd2(write_data)
	);
	alu alu_i(
		.a(src_a),
		.b(src_b),
		.alu_control(alu_control),
		.zero(alu_zero),
		.c(alu_result)
	);
	control_unit control_unit_i(
		.op(instruction[6:0]),
		.funct3(instruction[14:12]),
		.funct7_5(instruction[30]),
		.zero(alu_zero),
		.RegWrite(register_write),
		.ImmSrc(imm_src),
		.ALUSrc(alu_src),
		.MemWrite(memory_write),
		.ResultSrc(result_src),
		.PCSrc(pc_src),
		.ALUControl(alu_control)
	);
	extend extend_i(
		.Imm(instruction[31:7]),
		.ImmSrc(imm_src),
		.ImmExt(imm_ext)
	);
	always_comb
		begin 
			// pc_target logic
			pc_target = imm_ext + pc;

			// pc_plus_4 logic
			pc_plus_4 = pc + 4;

			// pc_next logic
			case (pc_src)
				1'b0: pc_next = pc_plus_4;
				1'b1: pc_next = pc_target;
			endcase

			// alu_src logic
			case (alu_src)
				1'b0: src_b = write_data;
				1'b1: src_b = imm_ext;
			endcase

			//result logic
			case (result_src)
				2'b00: result = alu_result;
				2'b01: result = read_data;
				2'b10: result = pc_plus_4;
				2'b11: result = 32'hDEADBEEF;
			endcase
		end
endmodule
