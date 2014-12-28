module CPU
(
    clk_i,
    rst_i,
    start_i,

    mem_data_i,
    mem_ack_i,
    mem_data_o,
    mem_addr_o,
    mem_enable_o,
    mem_write_o
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;
input   [255:0]     mem_data_i;
input               mem_ack_i;
input   [255:0]     mem_data_o;
input   [31:0]      mem_addr_o;
input               mem_enable_o;
input               mem_write_o;

wire    [31:0]      pc_i, pc_o, Add_PC_o;
wire    [31:0]      instr_o;
wire    [4:0]       regDst_o;
wire    [31:0]      imm32;
wire    [31:0]      rsData_o;
wire    [31:0]      rtData_o;
wire    [31:0]      aluSrc_o;
wire    [31:0]      alu_o;
wire    [31:0]      ctrl;
wire                ctrl_jump;
wire    [27:0]      sl26_o;

wire                bubble_o;
wire                mem_stall;
wire    [31:0]      IF_ID_instr;
wire    [31:0]      IF_ID_addr;
wire    [ 1:0]      ID_EX_M;
wire    [ 4:0]      ID_EX_mux3_o1;
wire    [31:0]      ID_EX_mux4_out;
wire    [ 1:0]      EX_MEM_wb;
wire    [31:0]      EX_MEM_in1;
wire    [ 4:0]      EX_MEM_in3;
wire                MEM_WB_RegWrite;
wire    [ 4:0]      MEM_WB_in3;
wire    [31:0]      mux1_out;
wire    [31:0]      mux5_out;
wire    [31:0]      mux7_data_o;
wire    [31:0]      mux8_out;

Control Control(
    .Op_i       (IF_ID_instr[31:26]),
    .RegDst_o   (ctrl[7]),
    .ALUOp_o    (ctrl[6:5]),
    .ALUSrc_o   (ctrl[4]),
    .MemRead_o  (ctrl[3]),
    .MemWrite_o (ctrl[2]),
    .RegWrite_o (ctrl[1]),
    .MemToReg_o (ctrl[0]),
    .Jump_o     (ctrl_jump),
    .Branch_o   ()
);

Adder Add_PC(
    .data1_in   (pc_o),
    .data2_in   (32'h4),
    .data_o     (Add_PC_o)
);

Adder ADD(
    .data1_in   (IF_ID_addr),
    .data2_in   (sl32.data_o),
    .data_o     ()
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .select_i   (bubble_o),
    .pc_i       (pc_i),
    .pc_o       (pc_o),
    .mem_stall  (mem_stall)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (pc_o),
    .instr_o    (instr_o)
);

Data_Cache Data_Cache(
    .clk_i          (clk_i),
    .read_data_o    (),
    .address_i      (EX_MEM_in1),
    .write_data_i   (EX_MEM.in2_out),
    .MemRead_i      (EX_MEM.mem_read),
    .MemWrite_i     (EX_MEM.mem_write),
    .mem_stall      (mem_stall),
    .mem_data_i     (mem_data_i),
    .mem_ack_i      (mem_ack_i),
    .mem_data_o     (mem_data_o),
    .mem_addr_o     (mem_addr_o),
    .mem_enable_o   (mem_enable_o),
    .mem_write_o    (mem_write_o)
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (IF_ID_instr[25:21]),
    .RTaddr_i   (IF_ID_instr[20:16]),
    .RDaddr_i   (MEM_WB_in3),
    .RDdata_i   (mux5_out),
    .RegWrite_i (MEM_WB_RegWrite),
    .RSdata_o   (rsData_o),
    .RTdata_o   (rtData_o)
);

Signed_Extend Signed_Extend(
    .data_i     (IF_ID_instr[15:0]),
    .data_o     (imm32)
);

ALU ALU(
    .data1_i    (mux6.data_o),
    .data2_i    (mux4.data_o),
    .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
    .data_o     (alu_o),
    .Zero_o     ()
);

ALU_Control ALU_Control(
    .funct_i    (ID_EX_mux4_out[5:0]),
    .ALUOp_i    (ID_EX.ALUOp_o),
    .ALUCtrl_o  ()
);

HazardDetection HazardDetection(
    .bubble_o           (bubble_o),
    .IF_ID_rs_i         (IF_ID_instr[25:21]),
    .IF_ID_rt_i         (IF_ID_instr[20:16]),
    .ID_EX_rt_i         (ID_EX_mux3_o1),
    .ID_EX_MemRead_i    (ID_EX_M[1])
);

FW FW
(
    .forward_MUX6   (),
    .forward_MUX7   (),
    .IDEX_rs        (ID_EX.FW_o1),
    .IDEX_rt        (ID_EX.FW_o2),
    .EXMEM_rd       (EX_MEM_in3),
    .EXMEM_write    (EX_MEM_wb[1]),
    .MEMWB_rd       (MEM_WB_in3),
    .MEMWB_write    (MEM_WB_RegWrite)
);

EQUAL Eq(
    .data1_i    (rsData_o),
    .data2_i    (rtData_o),
    .data_o     ()
);

Shift_Left2_26 sl26(
    .data_i (IF_ID_instr[25:0]),
    .data_o (sl26_o)
);

Shift_Left2_32 sl32(
    .data_i (imm32),
    .data_o ()
);

IF_ID IF_ID
(
    .clk(clk_i),
    .HD_i(bubble_o),
    .Add_pc_i(Add_PC_o),
    .Instruction_Memory_i(instr_o),
    .Flush1_i(mux1.cond_o),
    .Flush2_i(ctrl_jump),
    .instr_o(IF_ID_instr),
    .addr_o(IF_ID_addr),
    .mem_stall(mem_stall)
);

ID_EX ID_EX
(
    .clk(clk_i),
    .mux8_i(mux8_out),
    .addr_i(IF_ID_addr),
    .data1_i(rsData_o),
    .data2_i(rtData_o),
    .Sign_extend_i(imm32),
    .instr_i(IF_ID_instr),
    .EX_MEM_WB_o(),
    .EX_MEM_M_o(ID_EX_M),
    .ALUSrc_o(),
    .ALUOp_o(),
    .RegDst_o(),
    .mux6_o(),
    .mux7_o(),
    .mux4_o(ID_EX_mux4_out),
    .ALU_control_o(),
    .FW_o1(),
    .FW_o2(),
    .mux3_o1(ID_EX_mux3_o1),
    .mux3_o2(),
    .mem_stall(mem_stall)
);

EX_MEM EX_MEM
(
    .clk(clk_i),
    .wb(ID_EX.EX_MEM_WB_o),
    .m(ID_EX_M),
    .in1(alu_o),
    .in2(mux7_data_o),
    .in3(mux3.data_o),
    .wb_out(EX_MEM_wb),
    .mem_read(),
    .mem_write(),
    .in1_out(EX_MEM_in1),
    .in2_out(),
    .in3_out(EX_MEM_in3),
    .mem_stall(mem_stall)
);

MEM_WB MEM_WB
(
    .clk(clk_i),
    .wb(EX_MEM_wb),
    .in1(Data_Cache.read_data_o),
    .in2(EX_MEM_in1),
    .in3(EX_MEM_in3),
    .reg_write(MEM_WB_RegWrite),
    .mem_to_reg(),
    .in1_out(),
    .in2_out(),
    .in3_out(MEM_WB_in3),
    .mem_stall(mem_stall)
);

MUXAND mux1(
    .data_o     (mux1_out),
    .cond_o     (),
    .data1_i    (ADD.data_o),
    .data2_i    (Add_PC_o),
    .select1_i   (Eq.data_o),
    .select2_i   (Control.Branch_o)
);

MUX32 mux2(
    .data_o     (pc_i),
    .data1_i    (mux1_out),
    .data2_i    ({mux1_out[31:28], sl26_o}),
    .select_i   (ctrl_jump)
);

MUX5 mux3(
    .data_o     (),
    .data1_i    (ID_EX_mux3_o1),
    .data2_i    (ID_EX.mux3_o2),
    .select_i   (ID_EX.RegDst_o)
);

MUX32 mux4(
    .data_o     (),
    .data1_i    (mux7_data_o),
    .data2_i    (ID_EX_mux4_out),
    .select_i   (ID_EX.ALUSrc_o)
);

MUX32 mux5(
    .data_o     (mux5_out),
    .data1_i    (MEM_WB.in2_out),
    .data2_i    (MEM_WB.in1_out),
    .select_i   (MEM_WB.mem_to_reg)
);

MUX32_3 mux6(
    .data_o     (),
    .data1_i    (ID_EX.mux6_o),
    .data2_i    (mux5_out),
    .data3_i    (EX_MEM_in1),
    .select_i   (FW.forward_MUX6)
);

MUX32_3 mux7(
    .data_o     (mux7_data_o),
    .data1_i    (ID_EX.mux7_o),
    .data2_i    (mux5_out),
    .data3_i    (EX_MEM_in1),
    .select_i   (FW.forward_MUX7)
);

MUX32 mux8(
    .data_o     (mux8_out),
    .data1_i    (ctrl),
    .data2_i    (32'b0),
    .select_i   (bubble_o)
);

endmodule
