module IF_ID
(
    clk,
    HD_i,    //Hazard Detection unit
    Add_pc_i,
    Instruction_Memory_i,
    Flush1_i,
    Flush2_i,
    instr_o,//Instruction.
    addr_o    //Back to PC_address
);

input           clk;
input            HD_i;
input   [31:0]  Add_pc_i;
input   [31:0]  Instruction_Memory_i;
input           Flush1_i;
input           Flush2_i;
output  [31:0]  instr_o;
output    [31:0]    addr_o;

reg     [31:0]  instr_o;
reg        [31:0]    addr_o;

initial begin
    instr_o <= 0;
    addr_o <= 0;
end

always@(posedge clk) begin
    if(HD_i)
    begin
        instr_o <= 0;
        addr_o <= 0;
    end
    else if(Flush1_i)
    begin
        instr_o <= 0;
        addr_o <= 0;
    end
    else if(Flush2_i)
    begin
        instr_o <= 0;
        addr_o <= 0;
    end
    else
    begin
        instr_o <= Instruction_Memory_i;
        addr_o <= Add_pc_i;
    end
end

endmodule
