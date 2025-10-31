//Processor Verilog description

module processor
(
    input  wire        clk,
    input  wire        reset,
    output reg         [11:0] pc,       
    output wire        taken
);


	// --------------------------------
    // Register file and memories
    // --------------------------------
    reg [31:0] r [0:31];          // 32 general-purpose registers
    reg [31:0] imem [0:4095];     // Instruction memory (ROM)
    reg [31:0] dmem [0:4095];     // Data memory (RAM)


    // --------------------------------
    // Fetch and decode current instruction
    // --------------------------------
    wire [31:0] instr   = imem[pc];
    wire [3:0]  opcode  = instr[3:0];
    wire [4:0]  rd      = instr[8:4];
    wire [4:0]  rb      = instr[13:9];
    wire [4:0]  ra      = instr[18:14];
    
    wire [17:0] off18 = {instr[31:19], rd};s
    wire signed [31:0] offset = {{(32-18){off18[17]}}, off18};
    
    wire signed [22:0] imm_field = instr[31:9];
	wire signed [31:0] immediate = {{(32-23){imm_field[22]}}, imm_field};
    
    // --------------------------------
    // "Taken" wire description for branch decision
    // --------------------------------
    assign taken = (opcode == 4'h3 && r[ra] == r[rb]) ||               		// BEQ
                   (opcode == 4'h4 && $signed(r[ra]) >  $signed(r[rb])) || 	// BGT
                   (opcode == 4'h5 && $signed(r[ra]) >= $signed(r[rb])) || 	// BGE
                   (opcode == 4'h6);                                  	    // JUMP


	// Output depends only on the state
	always @ (posedge clk or posedge rst) begin
	 if (reset) begin
            pc <= 12'd0;           // reset pc value
        end
      else
		begin
			case (opcode)
			    4'h0: r[rd] <= r[ra] + r[rb];											// BEQ
				4'h1: r[rd] <= dmem[(r[rb] + offset) & 12'hFFF];						// LW
				4'h2: dmem[(r[rb] + offset) & 12'hFFF] <= r[ra];						// SW
                4'h3: if (r[ra] == r[rb])                  pc <= pc + offset[11:0]; 	// BEQ
                4'h4: if ($signed(r[ra]) >  $signed(r[rb])) pc <= pc + offset[11:0]; 	// BGT
                4'h5: if ($signed(r[ra]) >= $signed(r[rb])) pc <= pc + offset[11:0]; 	// BGE
                4'h6:  										pc <= r[ra][11:0];       	// JUMP
                4'h7: r[rd] <= immediate;												//LI
					default:
						pc <= pc + 12'd1;
			endcase
	end
endmodule
