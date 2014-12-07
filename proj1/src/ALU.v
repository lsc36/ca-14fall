module ALU
(
    data1_i,
    data2_i,
    ALUCtrl_i,
    data_o,
    Zero_o
);

input   [31:0]  data1_i, data2_i;
input   [2:0]   ALUCtrl_i;
output  [31:0]  data_o;
output          Zero_o;

reg     [31:0]  data_o;
reg             Zero_o;

always@(data1_i or data2_i or ALUCtrl_i) begin
    case(ALUCtrl_i)
        3'b000: data_o = data1_i & data2_i;  // and
        3'b001: data_o = data1_i | data2_i;  // or
        3'b010: data_o = data1_i + data2_i;  // add
        3'b011: data_o = data1_i - data2_i;  // sub
        3'b100: data_o = data1_i * data2_i;  // mul
        default: data_o = 32'bx;
    endcase
    Zero_o = data_o == 0 ? 1'b1 : 1'b0;
end

endmodule
