module MUXAND(
    data1_i, //branch address
    data2_i, //normal address
    select1_i,//control branch
    select2_i,//equal of beq
    data_o,  //output address
    cond_o
);

input   [31:0]  data1_i, data2_i;
input           select1_i, select2_i;
output  [31:0]  data_o;
output          cond_o;

reg     [31:0]  data_o;

assign cond_o = select1_i & select2_i;

always@(data1_i or data2_i or select1_i or select2_i)
begin
    if(select1_i & select2_i)
        data_o = data1_i;
    else
        data_o = data2_i;
end

endmodule
