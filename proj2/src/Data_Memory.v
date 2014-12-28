module Data_Memory
(
    clk_i,
    rst_i,
    addr_i,
    data_i,
    enable_i,
    write_i,
    ack_o,
    data_o
);

input           clk_i, rst_i, enable_i, write_i;
input   [31:0]  addr_i;
input   [255:0] data_i;
output          ack_o;
output  [255:0] data_o;

reg             ack_o;
reg     [255:0] data_o;
reg     [255:0] memory  [0:511];

parameter       STATE_IDLE   = 0,
                STATE_WAIT   = 1,
                STATE_ACK    = 2,
                STATE_FINISH = 3;
reg     [2:0]   state;
reg     [3:0]   count;

always @(posedge clk_i or negedge rst_i) begin
    if (~rst_i) begin
        ack_o <= 0;
        data_o <= 0;
        state = STATE_IDLE;
        count = 0;
    end
    else begin
        case (state)
            STATE_IDLE: begin
                if (enable_i) begin
                    count = count + 1;
                    state = STATE_WAIT;
                end
            end
            STATE_WAIT: begin
                if (count == 10) state = STATE_ACK;
                else count = count + 1;
            end
            STATE_ACK: begin
                if (write_i) memory[addr_i >> 5] = data_i;
                data_o = memory[addr_i >> 5];
                count = 0;
                ack_o = 1;
                state = STATE_FINISH;
            end
            STATE_FINISH: begin
                ack_o = 0;
                state = STATE_IDLE;
            end
        endcase
    end
end

endmodule
