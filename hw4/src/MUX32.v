module MUX32
(
    data_o,
    data1_i,
    data2_i,
    select_i
);

input   [31:0]  data1_i, data2_i;
input           select_i;
output  [31:0]  data_o;

reg     [31:0]  data_o;

always@(select_i or data1_i or data2_i) begin
    if(select_i) data_o = data2_i;
    else data_o = data1_i;
end

endmodule
