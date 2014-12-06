module ID_EX
(
    clk,
    mux8_i,    //Bubble unit
    addr_i,
    data1_i,
    data2_i,
    Sign_extend_i,
    instr_i,
    EX_MEM_WB_o,
    EX_MEM_M_o,
    ALUSrc_o,
    ALUOp_o,
    RegDst_o,
    mux6_o,
    mux7_o,
    mux4_o,
    ALU_control_o,
    FW_o1,
    FW_o2,
    mux3_o1,
    mux3_o2
);

input    [31:0]    mux8_i;
input   [31:0]  addr_i;
input   [31:0]  data1_i;
input   [31:0]  data2_i;
input   [31:0]  Sign_extend_i;
input   [14:0]  instr_i;
output          EX_MEM_WB_o;
output          EX_MEM_M_o;
output          ALUSrc_o;
output    [1:0]    ALUOp_o;
output            RegDst_o;
output    [31:0]    mux6_o;
output    [31:0]    mux7_o;
output    [31:0]    mux4_o;
output    [31:0]    ALU_control_o;
output    [4:0]    FW_o1;
output    [4:0]    FW_o2;
output    [4:0]    mux3_o1;
output    [4:0]    mux3_o2;

reg                  EX_MEM_WB_o;
reg              EX_MEM_M_o;
reg              ALUSrc_o;
reg        [1:0]    ALUOp_o;
reg                RegDst_o;
reg        [31:0]    mux6_o;
reg        [31:0]    mux7_o;
reg        [31:0]    mux4_o;
reg        [31:0]    ALU_control_o;
reg        [4:0]    FW_o1;
reg        [4:0]    FW_o2;
reg        [4:0]    mux3_o1;
reg        [4:0]    mux3_o2;

always@(posedge clk) begin
    EX_MEM_WB_o <=    mux8_i[7:6];
    EX_MEM_M_o     <=    mux8_i[5:4];
    ALUSrc_o    <=    mux8_i[3];
    ALUOp_o        <=    mux8_i[2:1];
    RegDst_o    <=    mux8_i[0];
    mux6_o        <=    data1_i;
    mux7_o        <=    data2_i;
    mux4_o        <=    Sign_extend_i;
    ALU_Control_o    <=    Sign_extend_i;
    FW_o1        <=    instr[14:10];
    FW_o2        <=    instr[9:5];
    mux3_o1        <=    instr[9:5];
    mux3_o2        <=    instr[4:0];
end

endmodule
