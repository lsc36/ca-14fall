module Adder
(
    car_out,
    data_o,
    data1_in,
    data2_in,
    car_in
);

input           car_in;
input   [31:0]  data1_in, data2_in;
output  [31:0]  data_o;
output          car_out;
reg     [31:0]  data_o;
reg             car_out;
reg     [32:0]  I;

always@(data1_in or data2_in) begin
    I = data1_in + data2_in + car_in;
    data_o = I[31:0];
    car_out = I[32];
end

endmodule