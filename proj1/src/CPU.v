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
    .MemRead_o  (),
    .MemWrite_o (),
    .RegWrite_o (ctrl_RegWrite),
    .MemToReg_o (),
    .Jump_o     (),
    .Branch_o   ()
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

Data_Memory Data_Memory(
    .read_data_o    (),
    .address_i      (),
    .write_data_i   (),
    .MemRead_i      (),
    .MemWrite_i     ()
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

HazardDetection HazardDetection(
    .bubble_o           (),
    .IF_ID_rs_i         (),
    .IF_ID_rt_i         (),
    .ID_EX_rt_i         (),
    .ID_EX_MemRead_i    ()
);

FW FW
(
    .forward_MUX6   (),
    .forward_MUX7   (),
    .IDEX_rt        (),
    .IDEX_rs        (),
    .EXMEM_rd       (),
    .EXMEM_write    (),
    .MEMWB_rd       (),
    .MEMWB_write    ()
);

IF_ID IF_ID
(
    .HD_i(),
    .Add_pc_i(),
    .Instruction_Memory_i(),
    .Flush_i(),
    .instr_o(),
    .addr_o()
);

ID_EX ID_EX
(
    .clk(),
    .mux8_i(),
    .addr_i(),
    .data1_i(),
    .data2_i(),
    .Sign_extend_i(),
    .instr_i(),
    .EX_MEM_WB_o(),
    .EX_MEM_M_o(),
    .ALUSrc_o(),
    .ALUOp_o(),
    .RegDst_o(),
    .mux6_o(),
    .mux7_o(),
    .mux4_o(),
    .ALU_control_o(),
    .FW_o1(),
    .FW_o2(),
    .mux3_o1(),
    .mux3_o2()
);

EX_MEM EX_MEM
(
    .clk(),
    .wb(),
    .m(),
    .in1(),
    .in2(),
    .in3(),
    .wb_out(),
    .mem_read(),
    .mem_write(),
    .in1_out(),
    .in2_out(),
    .in3_out()
);

MEM_WB MEM_WB
(
    .clk(),
    .wb(),
    .in1(),
    .in2(),
    .in3(),
    .reg_write(),
    .mem_to_reg(),
    .in1_out(),
    .in2_out(),
    .in3_out()
);

MUX5 mux3(
    .data_o     (),
    .data1_i    (),
    .data2_i    (),
    .select_i   ()
);

MUX32 mux4(
    .data_o     (),
    .data1_i    (),
    .data2_i    (),
    .select_i   ()
);

MUX32 mux5(
    .data_o     (),
    .data1_i    (),
    .data2_i    (),
    .select_i   ()
);

MUX32_3 mux6(
    .data_o     (),
    .data1_i    (),
    .data2_i    (),
    .data3_i    (),
    .select_i   ()
);

MUX32_3 mux7(
    .data_o     (),
    .data1_i    (),
    .data2_i    (),
    .data3_i    (),
    .select_i   ()
);

endmodule

