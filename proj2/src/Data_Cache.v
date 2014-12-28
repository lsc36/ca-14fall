module Data_Cache
(
    read_data_o,
    address_i,
    write_data_i,
    MemRead_i,
    MemWrite_i
);

input   [31:0]  address_i, write_data_i;
input           MemRead_i, MemWrite_i;
output  [31:0]  read_data_o;

reg     [31:0]  read_data_o;
reg     [7:0]   memory  [31:0];

initial begin
    read_data_o <= 0;
end

always @(address_i or write_data_i or MemRead_i or MemWrite_i) begin
    // TODO
end

endmodule
