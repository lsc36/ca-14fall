module Shift_Left2_26
(
    data_i,
    data_o
);
input   [25:0]  data_i;
output  [27:0]  data_o;
reg     [27:0]  data_o;
always@(data_i) begin
    data_o = {data_i, 2'b00};
end
endmodule

module Shift_Left2_32
(
    data_i,
    data_o
);
input   [31:0]  data_i;
output  [31:0]  data_o;
reg     [31:0]  data_o;
always@(data_i) begin
    data_o = {data_i[29:0], 2'b00};
end
endmodule
