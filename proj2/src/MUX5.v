module MUX5
(
    data_o,
    data1_i,
    data2_i,
    select_i
);

input   [4:0]   data1_i, data2_i;
input           select_i;
output  [4:0]   data_o;

reg     [4:0]   data_o;

always@(select_i or data1_i or data2_i) begin
    if(select_i) data_o = data2_i;
    else data_o = data1_i;
end

endmodule
