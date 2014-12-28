module EX_MEM
(
    clk,
    wb,
    m,
    in1,
    in2,
    in3,
    wb_out,
    mem_read,
    mem_write,
    in1_out,
    in2_out,
    in3_out,
    mem_stall,
);

input           clk;
input   [1:0]   m,wb;
input   [31:0]  in1,in2;
input   [4:0]   in3;
input           mem_stall;

output          mem_read, mem_write;
output  [1:0]   wb_out;
output  [31:0]  in1_out,in2_out;
output  [4:0]   in3_out;

reg             mem_read, mem_write;
reg     [1:0]   wb_out;
reg     [31:0]  in1_out,in2_out;
reg     [4:0]   in3_out;

initial begin
    mem_read <= 0;
    mem_write <= 0;
    wb_out <= 0;
    in1_out <= 0;
    in2_out <= 0;
    in3_out <= 0;
end

always @( posedge clk ) begin
    //m_out <= m;
    if(~mem_stall) begin
        mem_read  <= (m & 2'b10) ? 1'b1 : 1'b0;
        mem_write <= (m & 2'b01) ? 1'b1 : 1'b0;
        wb_out <= wb;
        in1_out <= in1;
        in2_out <= in2;
        in3_out <= in3;
    end
end

endmodule
