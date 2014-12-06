module MEM_WB
(
    clk,
    wb,
    in1,
    in2,
    in3,
    reg_write,
    mem_to_reg,
    in1_out,
    in2_out,
    in3_out
);

input           clk;
input   [1:0]   wb;
input   [31:0]  in1,in2;
input   [4:0]   in3;

output          reg_write, mem_to_reg;
output  [31:0]  in1_out,in2_out;
output  [4:0]   in3_out;

reg             reg_write, mem_to_reg;
reg     [31:0]  in1_out,in2_out;
reg     [4:0]   in3_out;

always @( posedge clk ) begin
    //m_out <= m;
    reg_write  <= (wb & 2'b10) ? 1'b1 : 1'b0;
    mem_to_reg <= (wb & 2'b01) ? 1'b1 : 1'b0;
    in1_out <= in1;
    in2_out <= in2;
    in3_out <= in3;
end

endmodule


