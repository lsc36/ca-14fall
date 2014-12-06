module Data_Memory
(
    read_data_o,
    address_i,
    write_data_i,
    memread_i,
    memwrite_i
);

input   [31:0]  address_i, write_data_i;
input           memread_i, memwrite_i;
output  [31:0]  read_data_o;

reg     [31:0]  read_data_o;
reg     [7:0]   memory  [31:0];

always @(address_i or write_data_i or memread_i or memwrite_i) begin
    if (memwrite_i) memory[address_i] = write_data_i;
    if (memread_i) read_data_o = memory[address_i];
end

endmodule
