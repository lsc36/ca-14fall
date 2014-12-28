module FW
(
    forward_MUX6,
    forward_MUX7,
    IDEX_rt,
    IDEX_rs,
    EXMEM_rd,
    EXMEM_write,
    MEMWB_rd,
    MEMWB_write
);

input           EXMEM_write, MEMWB_write;
input   [4:0]   IDEX_rt, IDEX_rs, EXMEM_rd, MEMWB_rd;
output  [1:0]   forward_MUX6, forward_MUX7;
reg     [1:0]   forward_MUX6, forward_MUX7;

initial begin
    forward_MUX6 = 0;
    forward_MUX7 = 0;
end

always @(*) begin
    forward_MUX6 = 
        (EXMEM_write && (EXMEM_rd !== 0) && (EXMEM_rd == IDEX_rs)) ? 2'b10 :
        (MEMWB_write && (MEMWB_rd !== 0) && (MEMWB_rd == IDEX_rs)) ? 2'b01 :
        2'b00;
    forward_MUX7 =
        (EXMEM_write && (EXMEM_rd !== 0) && (EXMEM_rd == IDEX_rt)) ? 2'b10 :
        (MEMWB_write && (MEMWB_rd !== 0) && (MEMWB_rd == IDEX_rt)) ? 2'b01 :
        2'b00;
end

endmodule

