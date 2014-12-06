module Data_Memory
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

always @(address_i or write_data_i or MemRead_i or MemWrite_i) begin
    if (MemWrite_i) memory[address_i] = write_data_i;
    if (MemRead_i) read_data_o = memory[address_i];
end

endmodule
