module Data_Cache
(
    read_data_o,
    address_i,
    write_data_i,
    MemRead_i,
    MemWrite_i,
    mem_stall,
    // To Data Memory
    mem_data_i,
    mem_ack_i,
    mem_data_o,
    mem_addr_o,
    mem_enable_o,
    mem_write_o
);

input   [31:0]  address_i, write_data_i;
input           MemRead_i, MemWrite_i;
output  [31:0]  read_data_o;
output          mem_stall;

reg     [31:0]  read_data_o;
reg     [23:0]  cache_tag   [0:31];
reg     [255:0] cache_data  [0:31];
reg             mem_stall;

// To Data Memory
input           mem_ack_i;
input   [255:0] mem_data_i;
output          mem_enable_o, mem_write_o;
output  [31:0]  mem_addr_o;
output  [255:0] mem_data_o;

reg             mem_enable_o, mem_write_o;
reg     [31:0]  mem_addr_o;
reg     [255:0] mem_data_o;

wire    [21:0]  tag;
wire    [4:0]   index, offset;

assign tag    = address_i[31:10],
       index  = address_i[9:5],
       offset = {address_i[4:2], 2'b00};

reg             read_wait_ack;

initial begin
    read_data_o <= 0;
    mem_stall <= 0;
    mem_enable_o <= 0;
    mem_write_o <= 0;
    mem_addr_o <= 0;
    mem_data_o <= 0;
    read_wait_ack <= 0;
end

// ack from mem
always @(posedge mem_ack_i) begin
    if (read_wait_ack) begin
        cache_tag[index] = {2'b10, tag};
        cache_data[index] = mem_data_i;
        read_data_o = cache_data[index][offset+:4];
        mem_enable_o = 0;
        mem_stall = 0;
        read_wait_ack = 0;
    end
end

always @(address_i or write_data_i or MemRead_i or MemWrite_i) begin
    if (~mem_stall) begin
        if (MemRead_i) begin
            if (~cache_tag[index][23] || cache_tag[index][21:0] != tag) begin  // cache miss
                if (cache_tag[index][22]) begin  // dirty flag set
                    // TODO
                end
                else begin
                    mem_enable_o = 1;
                    mem_write_o = 0;
                    mem_addr_o = address_i;
                    mem_stall = 1;
                    read_wait_ack = 1;
                end
            end
            else begin
                read_data_o = cache_data[index][offset+:4];
            end
        end
        if (MemWrite_i) begin
            // TODO
        end
    end
end

endmodule
