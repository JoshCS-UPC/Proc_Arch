module assignment_1 (
	input clock,
	input reset,
	input [11:0] initial_val,
	output taken);

reg [31:0] imem[0:11];	// instruction memory
reg [31:0] dmem[0:11];	// data memory
reg [31:0] r[0:31];	// 32 registers
reg taken;

reg [11:0] pc;
initial begin
	assign pc	=	initial_val;
end

wire [31:0] instruction	=	imem[pc];
wire [3:0] opcode	=	instruction[3:0];
wire [4:0] reg_a	=	instruction[18:14];
wire [4:0] reg_b	=	instruction[13:9];
wire [4:0] reg_d	=	instruction[8:4];
wire [17:0] offset 	=	{instruction[31:19],reg_d};
wire [22:0] immediate	=	instruction[31:9];

always (posedge clock) begin
if(reset) begin
	pc <= 12'd0;
	taken <= 1'b0;
end else
	case(opcode) begin
		4'h0:	r[reg_d] <= r[reg_a]+r[reg_b];				// ADD reg_b and reg_b
		4'h1:	r[reg_d] <= dmem[(r[reg_b]+offset)%(1<<12)];		// LW in reg_d
		4'h2:	dmem[(r[reg_b]+offset)%(1<<12)] <= r[reg_b];		// SW in reg_b
		4'h3:	if (r[reg_a]==r[reg_b]) begin				// BEQ
				pc <= (pc + offset[11:0]) % (1<<12);
				taken <= 1'b1;
			end
		4'h4: 	if ($signed(r[reg_a]) > $signed(r[reg_b])) begin	//BGT
				pc <= (pc + offset[11:0]) % (1<<12);
				taken <= 1'b1;
			end
		4'h5:	if ($signed(r[reg_a]) >= $signed(r[reg_b])) begin	//BGE
				pc <= (pc + offset[11:0]) % (1<<12);
				taken <= 1'b1;
			end
		4'h6:	begin							//JUMP
				taken <= 1'b1;
				pc <= r[reg_a]%(1<<12)
			end
		4'h7:	begin                      				// LI
				r[reg_d] <= {9*{immediate(21)},immediate};
			end
		default: panic_o <= 1;
		
	endcase
	if (panic_o == 0 && taken == 0) begin
            pc <= (pc + 1) % (1<<AW);
	end

end
end


endmodule
