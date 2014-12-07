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

reg             RegDst_o, ALUSrc_o, RegWrite_o, MemToReg_o, MemRead_o,
                MemWrite_o, Jump_o, Branch_o;
reg     [1:0]   ALUOp_o;

initial begin
    ALUOp_o = 2'b00;
end

always @ (*)
begin
    ALUOp_o = 2'b00;

    case(Op_i)
        default: begin //???
            RegDst_o = 0;
            ALUSrc_o = 0;
            MemToReg_o = 0;
            RegWrite_o = 0;
            MemWrite_o = 0;
            MemRead_o = 0;
            Branch_o = 0;
            Jump_o = 0;
        end
        6'h8: begin //addi
            RegDst_o = 0;
            ALUSrc_o = 1;
            MemToReg_o = 0;
            RegWrite_o = 1;
            MemWrite_o = 0;
            MemRead_o = 0;
            Branch_o = 0;
            Jump_o = 0;
        end
        6'h0: begin //add,sub
            RegDst_o = 1;
            ALUSrc_o = 0;
            MemToReg_o = 0;
            RegWrite_o = 1;
            MemWrite_o = 0;
            MemRead_o = 0;
            Branch_o = 0;
            Jump_o = 0;
        end
        6'h23: begin //lw
            RegDst_o = 0;
            ALUSrc_o = 1;
            MemToReg_o = 1;
            RegWrite_o = 1;
            MemWrite_o = 0;
            MemRead_o = 1;
            Branch_o = 0;
            Jump_o = 0;
            ALUOp_o = 2'b01;
        end
        6'h2b: begin //sw
            RegDst_o = 1'bx;
            ALUSrc_o = 1;
            MemToReg_o = 1'bx;
            RegWrite_o = 0;
            MemWrite_o = 1;
            MemRead_o = 0;
            Branch_o = 0;
            Jump_o = 0;
            ALUOp_o = 2'b01;
        end
        6'h4: begin
            RegDst_o = 1'bx;
            ALUSrc_o = 0;
            MemToReg_o = 1'bx;
            RegWrite_o = 0;
            MemWrite_o = 0;
            MemRead_o = 0;
            Branch_o = 1;
            Jump_o = 0;
        end
        6'h2: begin //j
            RegDst_o = 1'bx;
            ALUSrc_o = 1'bx;
            MemToReg_o = 1'bx;
            RegWrite_o = 0;
            MemWrite_o = 0;
            MemRead_o = 0;
            Branch_o = 0;
            Jump_o = 1;
        end
    endcase

end

/*
assign RegDst_o     = Op_i[5] == Op_i[3];  // 0: rt, 1: rd
assign ALUOp_o      = {1'b0, Op_i[3]};
assign ALUSrc_o     = Op_i[5] | Op_i[3];
assign MemRead_o    = Op_i[5] & ~Op_i[3];
assign MemWrite_o   = Op_i[5] & Op_i[3];
assign RegWrite_o   = ~(Op_i[5] & Op_i[3]);


assign MemToReg_o   = Op_i[5] & ~Op_i[3];
assign Jump_o       = (Op_i == 6'b000010) ? 1 : 0;
assign Branch_o     = (Op_i == 6'b000100) ? 1 : 0;
*/
endmodule
