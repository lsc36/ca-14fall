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

/*
Control Control(
    .Op_i       (),
    .RegDst_o   (),
    .ALUOp_o    (),
    .ALUSrc_o   (),
    .RegWrite_o ()
);
*/

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
    .RDaddr_i   (instr_o[15:11]),
    .RDdata_i   (),
    .RegWrite_i (),
    .RSdata_o   (),
    .RTdata_o   ()
);

MUX5 MUX_RegDst(
    .data1_i    (),
    .data2_i    (),
    .select_i   (),
    .data_o     ()
);

MUX32 MUX_ALUSrc(
    .data1_i    (),
    .data2_i    (),
    .select_i   (),
    .data_o     ()
);

/*
Signed_Extend Signed_Extend(
    .data_i     (),
    .data_o     ()
);
*/

/*
ALU ALU(
    .data1_i    (),
    .data2_i    (),
    .ALUCtrl_i  (),
    .data_o     (),
    .Zero_o     ()
);
*/

/*
ALU_Control ALU_Control(
    .funct_i    (),
    .ALUOp_i    (),
    .ALUCtrl_o  ()
);
*/

endmodule

