module HazardDetection
(
    mux8_o,  // bubble
    Flush_o,
    IF_ID_rs_i,
    IF_ID_rt_i,
    ID_EX_rt_i,
    ID_EX_memread_i
);

input   [4:0]   IF_ID_rs_i, IF_ID_rt_i, ID_EX_rt_i;
input           ID_EX_memread_i;
output          mux8_o, Flush_o;

assign {mux8_o, Flush_o} =
    (ID_EX_memread_i && ((ID_EX_rs_i == ID_EX_rt_i) || (
        (ID_EX_rs_i !== ID_EX_rt_i) && (ID_EX_rt_i == IF_ID_rt_i)
    ))) ? 2'b00 : 2'b11;

endmodule
