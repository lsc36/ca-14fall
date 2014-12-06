module HazardDetection
(
    bubble_o,
    IF_ID_rs_i,
    IF_ID_rt_i,
    ID_EX_rt_i,
    ID_EX_MemRead_i
);

input   [4:0]   IF_ID_rs_i, IF_ID_rt_i, ID_EX_rt_i;
input           ID_EX_MemRead_i;
output          bubble_o;

assign bubble_o = ID_EX_MemRead_i && (
    (ID_EX_rs_i == ID_EX_rt_i) || (ID_EX_rt_i == IF_ID_rt_i)
    );

endmodule
