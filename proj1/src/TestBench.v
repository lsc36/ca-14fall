`define CYCLE_TIME 50

module TestBench;

reg                Clk;
reg                Reset;
reg                Start;
integer            i, outfile, counter;
integer            stall, flush;

always #(`CYCLE_TIME/2) Clk = ~Clk;

CPU CPU(
    .clk_i  (Clk),
    .rst_i  (Reset),
    .start_i(Start)
);

initial begin
    counter = 0;
    stall = 0;
    flush = 0;

    // initialize instruction memory
    for(i=0; i<256; i=i+1) begin
        CPU.Instruction_Memory.memory[i] = 32'b0;
    end

    // initialize data memory
    for(i=0; i<32; i=i+1) begin
        CPU.Data_Memory.memory[i] = 8'b0;
    end

    // initialize Register File
    for(i=0; i<32; i=i+1) begin
        CPU.Registers.register[i] = 32'b0;
    end

    // Load instructions into instruction memory
    $readmemb("instruction.txt", CPU.Instruction_Memory.memory);

    // Open output file
    outfile = $fopen("output.txt") | 1;

    // Set Input n into data memory at 0x00
    CPU.Data_Memory.memory[0] = 8'h5;       // n = 5 for example

    Clk = 1;
    Reset = 0;
    Start = 0;

    #(`CYCLE_TIME/4)
    Reset = 1;
    Start = 1;


end

always@(posedge Clk) begin
    if(counter == 30)    // stop after 30 cycles
        $finish;

    if(CPU.HazardDetection.bubble_o == 1 && CPU.Control.Jump_o == 0 && CPU.Control.Branch_o == 0)stall = stall + 1;
    if(CPU.IF_ID.Flush1_i == 1 || CPU.IF_ID.Flush2_i == 1)flush = flush + 1;

$fdisplay(outfile, "\n\n\n\n\n\n\n");

$fdisplay(outfile, "Add_PC_o = %d, mux1 = %d, mux2 = %d, bubble_o = %d", CPU.Add_PC.data_o, CPU.mux1.data_o, CPU.mux2.data_o, CPU.bubble_o);
$fdisplay(outfile, "hazard: %x %x %x %x", CPU.HazardDetection.IF_ID_rs_i, CPU.HazardDetection.IF_ID_rt_i, CPU.HazardDetection.ID_EX_rt_i, CPU.HazardDetection.ID_EX_MemRead_i);
$fdisplay(outfile, "IF_ID:");
$fdisplay(outfile, "instr = %b, rs = %x, rt = %x", CPU.IF_ID.instr_o, CPU.rsData_o, CPU.rtData_o);
$fdisplay(outfile, "mux8_out = %b", CPU.mux8.data_o);
$fdisplay(outfile, "imm32 = %b", CPU.imm32);
$fdisplay(outfile, "Control: %b jump: %d branch: %d", CPU.ctrl[7:0], CPU.Control.Jump_o, CPU.Control.Branch_o);
$fdisplay(outfile, "ID_EX:");
$fdisplay(outfile, "RegDst = %d, ALUSrc = %d , mux6_out = %d, mux7_out = %d, mux4_out = %d, mux3_out = %b, ALU_out = %d", CPU.ID_EX.RegDst_o, CPU.ID_EX.ALUSrc_o, CPU.mux6.data_o, CPU.mux7.data_o, CPU.mux4.data_o, CPU.mux3.data_o, CPU.alu_o);
$fdisplay(outfile, "Fwd: mux6 = %d, mux7 = %d, IDEX_rs = %d, IDEX_rt = %d, EXMEM_rd = %d, MEMWB_rd = %d", CPU.FW.forward_MUX6, CPU.FW.forward_MUX7, CPU.FW.IDEX_rs, CPU.FW.IDEX_rt, CPU.FW.EXMEM_rd, CPU.FW.MEMWB_rd);
$fdisplay(outfile, "EX_MEM: wb = %b, MemRead = %b, MemWrite = %b", CPU.EX_MEM.wb_out, CPU.EX_MEM.mem_read, CPU.EX_MEM.mem_write);
$fdisplay(outfile, "MEM_WB: RegWrite = %b, MemToReg = %b", CPU.MEM_WB.reg_write, CPU.MEM_WB.mem_to_reg);

$fdisplay(outfile, "");

    // print PC
$fdisplay(outfile, "cycle = %d, Start = %d, Stall = %d, Flush = %d\nPC = %d", counter, Start, stall, flush, CPU.PC.pc_o);

// print Registers
$fdisplay(outfile, "Registers");
$fdisplay(outfile, "R0(r0) = %d, R8 (t0) = %d, R16(s0) = %d, R24(t8) = %d", CPU.Registers.register[0], CPU.Registers.register[8] , CPU.Registers.register[16], CPU.Registers.register[24]);
$fdisplay(outfile, "R1(at) = %d, R9 (t1) = %d, R17(s1) = %d, R25(t9) = %d", CPU.Registers.register[1], CPU.Registers.register[9] , CPU.Registers.register[17], CPU.Registers.register[25]);
$fdisplay(outfile, "R2(v0) = %d, R10(t2) = %d, R18(s2) = %d, R26(k0) = %d", CPU.Registers.register[2], CPU.Registers.register[10], CPU.Registers.register[18], CPU.Registers.register[26]);
$fdisplay(outfile, "R3(v1) = %d, R11(t3) = %d, R19(s3) = %d, R27(k1) = %d", CPU.Registers.register[3], CPU.Registers.register[11], CPU.Registers.register[19], CPU.Registers.register[27]);
$fdisplay(outfile, "R4(a0) = %d, R12(t4) = %d, R20(s4) = %d, R28(gp) = %d", CPU.Registers.register[4], CPU.Registers.register[12], CPU.Registers.register[20], CPU.Registers.register[28]);
$fdisplay(outfile, "R5(a1) = %d, R13(t5) = %d, R21(s5) = %d, R29(sp) = %d", CPU.Registers.register[5], CPU.Registers.register[13], CPU.Registers.register[21], CPU.Registers.register[29]);
$fdisplay(outfile, "R6(a2) = %d, R14(t6) = %d, R22(s6) = %d, R30(s8) = %d", CPU.Registers.register[6], CPU.Registers.register[14], CPU.Registers.register[22], CPU.Registers.register[30]);
$fdisplay(outfile, "R7(a3) = %d, R15(t7) = %d, R23(s7) = %d, R31(ra) = %d", CPU.Registers.register[7], CPU.Registers.register[15], CPU.Registers.register[23], CPU.Registers.register[31]);

// print Data Memory
$fdisplay(outfile, "Data Memory: 0x00 = %d", {CPU.Data_Memory.memory[3] , CPU.Data_Memory.memory[2] , CPU.Data_Memory.memory[1] , CPU.Data_Memory.memory[0] });
$fdisplay(outfile, "Data Memory: 0x04 = %d", {CPU.Data_Memory.memory[7] , CPU.Data_Memory.memory[6] , CPU.Data_Memory.memory[5] , CPU.Data_Memory.memory[4] });
$fdisplay(outfile, "Data Memory: 0x08 = %d", {CPU.Data_Memory.memory[11], CPU.Data_Memory.memory[10], CPU.Data_Memory.memory[9] , CPU.Data_Memory.memory[8] });
$fdisplay(outfile, "Data Memory: 0x0c = %d", {CPU.Data_Memory.memory[15], CPU.Data_Memory.memory[14], CPU.Data_Memory.memory[13], CPU.Data_Memory.memory[12]});
$fdisplay(outfile, "Data Memory: 0x10 = %d", {CPU.Data_Memory.memory[19], CPU.Data_Memory.memory[18], CPU.Data_Memory.memory[17], CPU.Data_Memory.memory[16]});
$fdisplay(outfile, "Data Memory: 0x14 = %d", {CPU.Data_Memory.memory[23], CPU.Data_Memory.memory[22], CPU.Data_Memory.memory[21], CPU.Data_Memory.memory[20]});
$fdisplay(outfile, "Data Memory: 0x18 = %d", {CPU.Data_Memory.memory[27], CPU.Data_Memory.memory[26], CPU.Data_Memory.memory[25], CPU.Data_Memory.memory[24]});
$fdisplay(outfile, "Data Memory: 0x1c = %d", {CPU.Data_Memory.memory[31], CPU.Data_Memory.memory[30], CPU.Data_Memory.memory[29], CPU.Data_Memory.memory[28]});

$fdisplay(outfile, "\n");

counter = counter + 1;


end


endmodule
