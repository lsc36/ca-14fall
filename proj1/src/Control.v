module Control(
    Op_i,
    RegDst_o,   // EX
    ALUOp_o,    // EX
    ALUSrc_o,   // EX
    MemRead_o,  // MEM
    MemWrite_o, // MEM
    RegWrite_o, // WB
    MemToReg_o, // WB
    Jump_o,
    Branch_o
);

input   [5:0]   Op_i;
output          RegDst_o, ALUSrc_o, RegWrite_o, MemToReg_o, MemRead_o,
                MemWrite_o, Jump_o, Branch_o;
output  [1:0]   ALUOp_o;

assign RegDst_o     = Op_i[5] == Op_i[3];  // 0: rt, 1: rd
assign ALUOp_o      = {1'b0, Op_i[3]};
assign ALUSrc_o     = Op_i[5] | Op_i[3];
assign MemRead_o    = Op_i[5] & ~Op_i[3];
assign MemWrite_o   = Op_i[5] & Op_i[3];
assign RegWrite_o   = ~(Op_i[5] & Op_i[3]);
assign MemToReg_o   = Op_i[5] & ~Op_i[3];
assign Jump_o       = (Op_i == 6'b000010) ? 1 : 0;
assign Branch_o     = (Op_i == 6'b000100) ? 1 : 0;

endmodule
