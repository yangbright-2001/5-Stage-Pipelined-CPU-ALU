// CLK: input clock signal
`include "pipeline_registers.v"
`include "control_unit.v"
`include "alu.v"
`include "MainMemory.v"
`include "InstructionRAM.v"

module CPU(input CLK);

localparam 
    ADD = 0,
    ADDU = 1,
    SUB = 2,
    SUBU = 3,
    AND = 4,
    NOR = 5,
    OR = 6,
    XOR = 7,
    SLL = 8,
    SLLV = 9,
    SRL = 10,
    SRLV = 11,
    SRA = 12,
    SRAV = 13,
    SLT = 14,
    JR = 15,
    ADDI = 16,
    ADDIU = 17,
    ANDI = 18,
    ORI = 19,
    BEQ = 20,
    BNE = 21,
    LW = 22,
    SW = 23,
    J = 24,
    JAL = 25,
    XORI = 26;

reg forward_m_a, forward_m_b, forward_w_a, forward_w_b;
reg START = 0;
reg [31:0] instruction;
reg[13:0] clk_cycle = 14'b0;

//IF signal
reg[31:0] pc, pc_plus4_f, current_pc, pcf;
wire[31:0] instruction_f;
reg[2:0] pc_signal;
wire[2:0] pc_sig;

reg[4:0] rs_address;
reg stall_signal, flush_signal;

//ID signal
wire[31:0] instruction_d;
wire[31:0] pc_plus4_d;
wire[4:0] alu_control_d;
wire reg_write_d, mem_to_reg_d, mem_write_d, sig_branch_d, alu_src_d;
wire reg_dst_d, sign_extend_d, mem_read_d, sig_shamp_d, sw_d; 
wire[31:0] extend_num_d;
reg[31:0] rs, rt;
reg[31:0] PC_branch;
reg[4:0] rs_address_d, rt_address_d, rd_address_d, shamp_d;

//register file
reg [31:0] gr[31:0];

//EX signal
wire reg_write_e,mem_to_reg_e,mem_write_e,alu_src_e, reg_dst_e, sw_e; 
wire mem_read_e, sig_shamp_e;
wire[31:0] extend_num_e;
wire[31:0] instruction_e;
wire[4:0] alu_control_e;
wire[4:0] shamp_e, rs_address_e, rt_address_e, rd_address_e;
reg forward_AE, forward_BE, forward_m, forward_w;
reg[31:0] pre_mux_AE, pre_mux_BE, src_AE, src_BE;
reg[31:0] write_data_e;
reg[4:0] write_reg_e;

wire[31:0] alu_out_e;
wire[2:0] flags; 

//MEM signal
wire reg_write_m,mem_to_reg_m,mem_write_m, mem_read_m, sw_m;
wire[31:0] write_data_m;
wire[4:0] write_reg_m, rd_address_m;
wire[31:0] alu_out_m;
wire[31:0] read_data_m;

//WB signal
wire reg_write_w,mem_to_reg_w, sw_w;
wire[31:0] read_data_w;
wire[4:0] write_reg_w;
wire[31:0] alu_out_w;
reg[31:0] result_w;

integer i;
always @(START) begin
  if (START == 0) begin
    for (i = 0; i <= 31; i = i+1) begin
      // gr[i] = 32'hfffffff8;
      gr[i] = 0;
    end
    gr[0] = 32'b0;
    pc_plus4_f = 32'b0;
    pc_signal = 3'b000;
    stall_signal = 0;
    flush_signal = 0;
    forward_AE = 0;
    forward_BE = 0;
    forward_m = 0;
    forward_w = 0;
    pc = 32'b0;
    START = 1;
  end
end

// // clock count
// always @ (posedge CLK) begin
//   clk_cycle <= clk_cycle + 1;
// end

/******************IF**********************/
//pc
always @(*) begin
//always @(pc_plus4_f, START, pc_signal, instruction_d, stall_signal) begin
  if (START == 1'b1) begin  //记得到时变回0
  // else if (stall_signal == 0)begin
    if (pc_signal == 3'b000) begin //正常的
      // current_pc = current_pc + 4;
      pc = pc_plus4_f;
      // $display("pc: %b",pc);
      // $display("1");
    end
    else if (pc_signal == 3'b001) begin  //JUMP:j, jal
      // current_pc = current_pc + 4;
      // current_pc = {current_pc[31:28],(instruction_d[25:0] << 2)};
      pc = {pc_plus4_d[31:28],(instruction_d[25:0] << 2)};
      // $display("next pc is: %d",pc);
    end
    else if (pc_signal == 3'b010) begin  //branch
      // current_pc = current_pc + 4;
      // current_pc = current_pc + (instruction_d[15:0] << 2);
      pc = PC_branch;
    end
    else if (pc_signal == 3'b011) begin //jr (unconditional jump to instruction whose address is in rs)
      // current_pc = gr[rs_address];
      pc = gr[instruction_d[25:21]];
    end
    
  end
end

always @(posedge CLK) begin  
  if (stall_signal==1'b0) begin
    
    pcf <= pc;
  end
  // else begin
  //   $display("stop!");
  // end
end

InstructionRAM instruction_RAM(
  .CLOCK(CLK),
  .FETCH_ADDRESS(pcf >> 2),
  .ENABLE(1'b1),
  .RESET(1'b0),
  .DATA(instruction_f)
);

// always @(pcf) begin
always @(*) begin
  pc_plus4_f = pcf + 4;
end

//IF/ID reg
IF_ID if_id_reg(
  .clock(CLK),
  .sig_flush(flush_signal),
  .pc_plus4f(pc_plus4_f),
  .instruct_f(instruction_f),
  .pc_plus4d(pc_plus4_d),
  .instruct_d(instruction_d));


/******************ID**********************/
wire I_type_d;
control_unit cu(
  .instruction(instruction_d), 
  .ALU_control(alu_control_d), 
  .reg_write(reg_write_d),
  .mem_to_reg(mem_to_reg_d),
  .mem_write(mem_write_d),
  .sig_branch(sig_branch_d),
  .alu_src(alu_src_d), 
  .reg_dst(reg_dst_d), 
  .pc_signal_d(pc_sig),
  .sign_extend(sign_extend_d),
  .mem_read(mem_read_d),
  .sig_shamp(sig_shamp_d),
  .I_type(I_type_d),
  .sw_d(sw_d));

// always @(pc_sig) begin
always @(*) begin
  pc_signal = pc_sig;
end

// always @(instruction_d) begin
always @(*) begin
  rs_address_d = instruction_d[25:21];
  rt_address_d = instruction_d[20:16];
  rd_address_d = instruction_d[15:11];
  shamp_d = instruction_d[10:6];
end

//write data to register
always @(negedge (CLK))
begin
    if(reg_write_w == 1)
    begin
      gr[write_reg_w] <= result_w;
      // $display("originally, gr[%b] is %h, now gr[%b] = %h",
      //   write_reg_w, gr[write_reg_w],write_reg_w,result_w);
    end 
end

//提前算branch address
reg[31:0] extend_num;
// always @(sign_extend_d) begin
always @(*) begin
  if (sign_extend_d == 1) begin
    extend_num = {{16{instruction_d[15]}}, instruction_d[15:0]};
  end
  else begin
    extend_num = {16'b0, instruction_d[15:0]};
  end
  PC_branch = (extend_num<<2) + pc_plus4_d;
end
assign extend_num_d = extend_num;
//assign ext_imm_d = (sign_extend_d == 0) ? {16'b0,instruction_d[15:0]} : {{16{instruction_d[15]}},instruction_d[15:0]};

//branch hazard
// always @(sig_branch_d) begin
always @(*) begin
  pc_signal = 3'b000;
  if (sig_branch_d == 1) begin
    rs = gr[rs_address_d];
    rt = gr[rt_address_d];
    if ( (alu_control_d == BEQ) && (rs == rt)) begin
      pc_signal = 3'b010; //branch
      flush_signal = 1;
    end
    else if ( (alu_control_d == BNE) && (rs != rt)) begin
      pc_signal = 3'b010; //branch
      flush_signal = 1;
    end
  end
end


/******************EX**********************/
wire I_type_e;
ID_EX id_ex_reg(
.clock(CLK),
.sig_stall(stall_signal),
.reg_write_d(reg_write_d),
.mem_to_reg_d(mem_to_reg_d),
.mem_write_d(mem_write_d),
.alu_control_d(alu_control_d),
.alu_src_d(alu_src_d), 
.reg_dst_d(reg_dst_d), 
.mem_read_d(mem_read_d),
.extend_num_d(extend_num_d),
.shamp_d(shamp_d),
.rs_address_d(rs_address_d),
.rt_address_d(rt_address_d),
.rd_address_d(rd_address_d),
.sig_shamp_d(sig_shamp_d),
.I_type_d(I_type_d),
.sw_d(sw_d),
.reg_write_e(reg_write_e),
.mem_to_reg_e(mem_to_reg_e),
.mem_write_e(mem_write_e),
.alu_src_e(alu_src_e), 
.alu_control_e(alu_control_e),
.reg_dst_e(reg_dst_e), 
.mem_read_e(mem_read_e),
.extend_num_e(extend_num_e),
.sig_shamp_e(sig_shamp_e),
.rs_address_e(rs_address_e),
.rt_address_e(rt_address_e),
.rd_address_e(rd_address_e),
.shamp_e(shamp_e),
.I_type_e(I_type_e),
.sw_e(sw_e)
);

//stall hazard
// always @(rt_address_e, rs_address_d, rt_address_d) begin
always @(*) begin
  stall_signal = 0;
  pc_signal = 3'b000;
  if ( (mem_read_e == 1'b1) ) begin
    if ( (rt_address_e == rs_address_d) || (rt_address_e == rt_address_d) ) begin
      stall_signal = 1;
    end
    else begin
      stall_signal = 0;
    end    
  end
  else begin
    stall_signal = 0;
  end
  if (stall_signal == 1) begin
    pc_signal = 3'b100; //不给动
    // $display("pc_signal: %b",pc_signal);
  end
end

//srcAE前之三进一multiplexer
// always @ (forward_AE, forward_m, forward_w, rs_address_e) begin
integer k,m;
always @(*) begin
  pre_mux_AE = gr[rs_address_e];
  pre_mux_BE = gr[rt_address_e];
  if ( (forward_m_a == 1) || (forward_w_a == 1) )begin    //forwarding
    if ( (forward_m_a == 1) && (forward_w_a == 1) ) begin //double hazards
      // $display("great0!");
      pre_mux_AE = alu_out_m;
    end
    else if ( (forward_m_a == 1) && (forward_w_a == 0) ) begin
      // $display("pre_mux_AE: %d",pre_mux_AE);
      // $display("ALU_out_m: %h", alu_out_m);
      pre_mux_AE = alu_out_m;
      // $display("forward_m_rs -> rs_address_e: %b, pre_mux_AE:%h",rs_address_e,pre_mux_AE);
    end
    else if ( (forward_m_a == 0) && (forward_w_a == 1) ) begin
      // $display("great2!");
      if (stall_signal == 0) begin
        pre_mux_AE = alu_out_w;
      end
      else begin
        // $display("great2!");
        pre_mux_AE = read_data_w;
      end
      
    end
  end
  // else begin
  //   pre_mux_AE = gr[rs_address_e];
  //   $display("great3!");
  // end
  if ( (forward_m_b == 1) || (forward_w_b == 1) )begin    //forwarding
    if ( (forward_m_b == 1) && (forward_w_b == 1) ) begin //double hazards
      pre_mux_BE = alu_out_m;
    end
    else if ( (forward_m_b == 1) && (forward_w_b == 0) ) begin
      pre_mux_BE = alu_out_m;
    end
    else if ( (forward_m_b == 0) && (forward_w_b == 1) ) begin
      if (stall_signal == 0) begin
        pre_mux_BE = alu_out_w;
      end
      else begin
        pre_mux_BE = read_data_w;
      end
    end
  end

end

//srcAE multiplexer, 主要是分rd和shampt
// always @(sig_shamp_e, alu_control_e, instruction_e) begin
always @(*) begin
  if (sig_shamp_e == 0) begin
    src_AE = pre_mux_AE;
    // $display("src_AE: %h",src_AE);
  end
  else begin
    src_AE = {27'b0,shamp_e};
  end 
end

// always @ (forward_BE, forward_m, forward_w, rs_address_e) begin
always @(*) begin
  if ( (forward_m_b == 1) || (forward_w_b == 1) )begin    //forwarding
    if ( (forward_m_b == 1) && (forward_w_b == 1) ) begin //double hazards
      pre_mux_BE = alu_out_m;
    end
    else if ( (forward_m_b == 1) && (forward_w_b == 0) ) begin
      pre_mux_BE = alu_out_m;
    end
    else if ( (forward_m_b == 0) && (forward_w_b == 1) ) begin
      pre_mux_BE = alu_out_w;
    end
  end
  else begin
    pre_mux_BE = gr[rt_address_e];
  end
end

//srcAE multiplexer, 主要是分rd和shampt
// always @(alu_src_e, alu_control_e, instruction_e) begin
always @(*) begin
  if (alu_src_e == 0) begin
    src_BE = pre_mux_BE;
    // $display("src_BE: %h",src_BE);
  end
  else begin
    src_BE = extend_num_e;
  end 
end

//write data_e 和 write_reg_e
// always @(reg_dst_e, pre_mux_BE) begin
always @(*) begin
  write_data_e = pre_mux_BE;
  if (reg_dst_e == 1) begin
    write_reg_e = rd_address_e;
  end
  else begin
    write_reg_e = rt_address_e;
  end
end

ALU my_alu(
.src_AE(src_AE),
.src_BE(src_BE),
.alu_control(alu_control_e),
.alu_out_e(alu_out_e),
.reg_flag(flags));

/******************MEM**********************/
wire I_type_m;
EX_MEM ex_mem_reg(
.clock(CLK),
.reg_write_e(reg_write_e),
.mem_to_reg_e(mem_to_reg_e),
.mem_write_e(mem_write_e),
.mem_read_e(mem_read_e),
.write_data_e(write_data_e),
.write_reg_e(write_reg_e),
.alu_out_e(alu_out_e),
.rd_address_e(rd_address_e),
.I_type_e(I_type_e),
.sw_e(sw_e),
.reg_write_m(reg_write_m),
.mem_to_reg_m(mem_to_reg_m),
.mem_write_m(mem_write_m),
.mem_read_m(mem_read_m),
.write_data_m(write_data_m),
.write_reg_m(write_reg_m),
.alu_out_m(alu_out_m),
.rd_address_m(rd_address_m),
.I_type_m(I_type_m),
.sw_m(sw_m)
);

MainMemory main_memory(
  .CLOCK(CLK),
  .RESET(1'b0),
  .ENABLE(mem_write_m),
  .FETCH_ADDRESS(alu_out_m>>2),
  // .EDIT_SERIAL({mem_write_m,alu_out_m[31:0]>>2,write_data_m[31:0]}),
  .EDIT_SERIAL({mem_write_m,alu_out_m>>2,write_data_m}),
  .DATA(read_data_m)
);

//hazard
//forwarding at EX/MEM
//always @(rs_address_e, write_reg_m) begin
always @(*) begin
  forward_m_a = 0;
  forward_m_b = 0;
  forward_w_a = 0;
  forward_w_b = 0;
  // I-type的forward(实际的R—type)
  if ( (write_reg_m != 5'b0) && (reg_write_m == 1) && (I_type_m == 1) && (I_type_e == 1)) begin
    if (rs_address_e == write_reg_m) begin
      forward_m_a = 1;
      forward_m_b = 0;
      // $display("m_case1: forward_m_a:%b, forward_m_b: %b, forward_w_a:%b, forward_w_b:%b",forward_m_a,forward_m_b,forward_w_a, forward_w_b );
    end
    if (rt_address_e == write_reg_m) begin
      forward_m_a = 0;
      forward_m_b = 1;
      // $display("m_case2: forward_m_a:%b, forward_m_b: %b, forward_w_a:%b, forward_w_b:%b",forward_m_a,forward_m_b,forward_w_a, forward_w_b );
    end
  end
  
  //J-type的forward(实际的i-type)
  else if ( (write_reg_m != 5'b0) && (reg_write_m == 1) && (I_type_m == 1) && (I_type_e == 0)) begin
    // $display("rs_address_e:%b, forward_m_b: %b, forward_w_a:%b, forward_w_b:%b",forward_m_a,forward_m_b,forward_w_a, forward_w_b );
    if (rs_address_e == write_reg_m) begin
      forward_m_a = 1;
      forward_m_b = 0;
    end
    if ( (sw_e == 1'b1) && (rt_address_e == write_reg_m) ) begin  //sw比较特殊
      // $display("HAVE FUN");
      forward_m_a = 0;
      forward_m_b = 1;
    end
  end

  if ( (write_reg_w !=5'b0) && (reg_write_w == 1) && (I_type_w == 1) && (I_type_e == 1)) begin
    if (rs_address_e == write_reg_w) begin
      //$display("case1: write_w: %b, rs_e:%b, rt_e:%b",write_reg_w,rs_address_e, rt_address_e );
      forward_w_a = 1;
      forward_w_b = 0;
      //$display("w_case1: forward_m_a:%b, forward_m_b: %b, forward_w_a:%b, forward_w_b:%b",forward_m_a,forward_m_b,forward_w_a, forward_w_b );
    end
    if (rt_address_e == write_reg_w) begin
      //$display("case2: write_w: %b, rs_e:%b, rt_e:%b",write_reg_w,rs_address_e, rt_address_e );
      forward_w_a = 0;
      forward_w_b = 1;
      //$display("w_case2: forward_m_a:%b, forward_m_b: %b, forward_w_a:%b, forward_w_b:%b",forward_m_a,forward_m_b,forward_w_a, forward_w_b );
    end     
  end

  if (stall_signal == 1) begin
    if (rt_address_e == rs_address_d) begin
      forward_w_a = 1;
      forward_w_b = 0;
    end
    else if (rt_address_e == rt_address_d)  begin
      forward_w_a = 0;
      forward_w_b = 1;
    end
  end
 
end

/******************WB**********************/
wire I_type_w;
MEM_WB mem_wb_reg(
.clock(CLK), 
.reg_write_m(reg_write_m),
.mem_to_reg_m(mem_to_reg_m),
.read_data_m(read_data_m), 
.write_reg_m(write_reg_m),
.alu_out_m(alu_out_m),
.I_type_m(I_type_m),
.sw_m(sw_m),
.reg_write_w(reg_write_w),
.mem_to_reg_w(mem_to_reg_w),
.read_data_w(read_data_w), 
.write_reg_w(write_reg_w),
.alu_out_w(alu_out_w),
.I_type_w(I_type_w),
.sw_w(sw_w)
);


// always @(mem_to_reg_w) begin
always @(*) begin
  if (mem_to_reg_w == 0) begin
    result_w = alu_out_w;
  end
  else begin
    result_w = read_data_w;
  end
end

// clock count
// always @ (posedge CLK) begin
//   clk_cycle <= clk_cycle + 1;
// end

integer j;
integer num=0;
integer file_name, command_fetch;
integer last_period=0;
integer finish_tag=0;
initial begin
    file_name = $fopen("data.bin", "wb");
    command_fetch = $fopen("command.bin", "wb");
end

always @(negedge(CLK)) begin
  // #900;
  num = num + 1;
  // $display("number %d, instruction: %b, mem_write: %b, pc_signal: %b", num-3, instruction_d, mem_write_e, pc_signal);
  //$display("pc_signal: %b, stall_signal: %b, memory_read: %b", pc_signal, stall_signal, mem_read_e);
  //$display("pc_signal: %b, stall_signal: %b", pc_signal, stall_signal);
  // $display("number %d, forward_m_a: %b, forward_m_b: %b, forward_w_a: %b, forward_w_b: %b", 
  //         num - 3, forward_m_a, forward_m_b, forward_w_a, forward_w_b);
  if (num > 3) begin
    $fdisplayb(command_fetch,instruction_d);
  end
  if (instruction_d == 32'b11111111111111111111111111111111)  begin //after this instruction, then last 5 cycle, the program ends
  //if (num >= 24) begin
    finish_tag = 1;
    $fclose(command_fetch);
  end
  if (finish_tag==1) begin
    last_period = last_period + 1;
    $display("finish");
  end
  if (last_period>=5) begin
  // display the main memory data
    j = 0;
    while(j<512) begin
      $fdisplayb(file_name,main_memory.DATA_RAM[j]);
      $display("%b", main_memory.DATA_RAM[j]);
      j = j + 1;
    end
    $display("Total clock cycles: %d", num);
    $fclose(file_name);
    $finish;
  end
end

endmodule
