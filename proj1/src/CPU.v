module CPU
(
    clk_i,
    rst_i,
    start_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

wire    [31:0]      pc_i, pc_o;
wire    [31:0]      instr_o;
wire    [4:0]       regDst_o;
wire    [31:0]      imm32;
wire    [31:0]      rsData_o;
wire    [31:0]      rtData_o;
wire    [31:0]      aluSrc_o;
wire    [2:0]       aluCtrl_o;
wire    [31:0]      alu_o;
wire                ctrl_RegDst;
wire    [1:0]       ctrl_ALUOp;
wire                ctrl_ALUSrc;
wire                ctrl_RegWrite;

Control Control(
    .Op_i       (instr_o[31:26]),
    .RegDst_o   (ctrl_RegDst),
    .ALUOp_o    (ctrl_ALUOp),
    .ALUSrc_o   (ctrl_ALUSrc),
    .RegWrite_o (ctrl_RegWrite)
);

Adder Add_PC(
    .data1_in   (pc_o),
    .data2_in   (32'h4),
    .data_o     (pc_i)
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (pc_i),
    .pc_o       (pc_o)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (pc_o),
    .instr_o    (instr_o)
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (instr_o[25:21]),
    .RTaddr_i   (instr_o[20:16]),
    .RDaddr_i   (regDst_o),
    .RDdata_i   (alu_o),
    .RegWrite_i (ctrl_RegWrite),
    .RSdata_o   (rsData_o),
    .RTdata_o   (rtData_o)
);

MUX5 MUX_RegDst(
    .data1_i    (instr_o[20:16]),
    .data2_i    (instr_o[15:11]),
    .select_i   (ctrl_RegDst),
    .data_o     (regDst_o)
);

MUX32 MUX_ALUSrc(
    .data1_i    (rtData_o),
    .data2_i    (imm32),
    .select_i   (ctrl_ALUSrc),
    .data_o     (aluSrc_o)
);

Signed_Extend Signed_Extend(
    .data_i     (instr_o[15:0]),
    .data_o     (imm32)
);

ALU ALU(
    .data1_i    (rsData_o),
    .data2_i    (aluSrc_o),
    .ALUCtrl_i  (aluCtrl_o),
    .data_o     (alu_o),
    .Zero_o     ()
);

ALU_Control ALU_Control(
    .funct_i    (instr_o[5:0]),
    .ALUOp_i    (ctrl_ALUOp),
    .ALUCtrl_o  (aluCtrl_o)
);

endmodule

