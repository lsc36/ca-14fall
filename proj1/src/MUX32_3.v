module MUX32_3
(
    data_o,
    data1_i,
    data2_i,
    data3_i,
    select_i
);

input   [31:0]   data1_i, data2_i, data3_i;
input   [ 1:0]   select_i;
output  [31:0]   data_o;

reg     [31:0]   data_o;

always@(select_i or data1_i or data2_i or data3_i) begin
    if(select_i == 2'b01) data_o = data2_i;
    else if(select_i == 2'b10) data_o = data3_i;
    else data_o = data1_i;
end

endmodule
