module Signed_Extend
(
    data_i,
    data_o
);

input   [15:0]  data_i;
output  [31:0]  data_o;

reg     [31:0]  data_o;

always@(data_i) begin
    if(data_i[15]) data_o = {16'hFFFF, data_i};
    else data_o = {16'h0, data_i};
end

endmodule
