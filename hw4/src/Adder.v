module Adder
(
    data_o,
    data1_in,
    data2_in,
);

input   [31:0]  data1_in, data2_in;
output  [31:0]  data_o;
reg     [31:0]  data_o;
reg     [32:0]  I;

always@(data1_in or data2_in) begin
    I = data1_in + data2_in;
    data_o = I[31:0];
end

endmodule
