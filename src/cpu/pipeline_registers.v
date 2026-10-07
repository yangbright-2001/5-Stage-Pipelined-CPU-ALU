module IF_ID(clock, sig_flush, pc_plus4f, instruct_f, pc_plus4d, instruct_d);
input clock;
input sig_flush;
input [31:0] pc_plus4f;
input [31:0] instruct_f;
output reg[31:0] pc_plus4d;
output reg[31:0] instruct_d;

always@(posedge clock) begin
    if (sig_flush == 1) begin
        instruct_d <= 32'b0;
        pc_plus4d <= 0;
    end
    else begin
        instruct_d <= instruct_f;
        pc_plus4d <= pc_plus4f;
    end
end
endmodule



module ID_EX(
input clock,
input sig_stall,
input reg_write_d,mem_to_reg_d,mem_write_d,alu_src_d,
input reg_dst_d, mem_read_d, sig_shamp_d, I_type_d,sw_d,
input [4:0] alu_control_d, 
input [4:0] rs_address_d, rt_address_d, rd_address_d, shamp_d,
input [31:0] extend_num_d, 
output reg reg_write_e,mem_to_reg_e,mem_write_e,
output reg alu_src_e, reg_dst_e, mem_read_e, sig_shamp_e, I_type_e,sw_e,
output reg[4:0] alu_control_e, 
output reg[4:0] rs_address_e, rt_address_e, rd_address_e, shamp_e,
output reg[31:0] extend_num_e
);

always@(posedge clock) begin
    if (sig_stall == 1) begin
        // reg_write_e <= 0;
        // mem_to_reg_e <= 0;
        // mem_write_e <= 0;
        // //sig_branch_e <= sig_branch_d;
        // alu_src_e <= 0;
        // reg_dst_e <= 0;
        // mem_read_e <= 0;
        // extend_num_e <= 0;
        // alu_control_e <= 0;
        // // instruction_e <= 0;
        // rs_address_e <= 0;
        // rt_address_e <= 0;
        // rd_address_e <= 0;
        // shamp_e <= 0;
        // sig_shamp_e <= 0;
        // I_type_e <= 0;
        // sw_e <= 0;
        
        reg_write_e <= 0; //
        mem_to_reg_e <= mem_to_reg_d;
        mem_write_e <= 0;
        //sig_branch_e <= 1'b0;
        alu_control_e <= alu_control_d; //
        alu_src_e <= alu_src_d;
        reg_dst_e <= reg_dst_d;
        rs_address_e <= rs_address_d;
        rt_address_e <= rt_address_d;
        rd_address_e <= rd_address_d;
        extend_num_e <= extend_num_d;
        shamp_e <= shamp_d;
        sig_shamp_e <= sig_shamp_d;
        mem_read_e <= mem_read_d;
        sw_e <= 0;

    end
    else begin
        reg_write_e <= reg_write_d;
        mem_to_reg_e <= mem_to_reg_d;
        mem_write_e <= mem_write_d;
        //sig_branch_e <= sig_branch_d;
        alu_src_e <= alu_src_d;
        reg_dst_e <= reg_dst_d;
        mem_read_e <= mem_read_d;
        extend_num_e <= extend_num_d;
        alu_control_e <= alu_control_d;
        // instruction_e <= instruction_d;
        rs_address_e <= rs_address_d;
        rt_address_e <= rt_address_d;
        rd_address_e <= rd_address_d;
        shamp_e <= shamp_d;
        sig_shamp_e <= sig_shamp_d;
        I_type_e <= I_type_d;
        sw_e <= sw_d;
    end

    // reg_write_e <= reg_write_d;
    // mem_to_reg_e <= mem_to_reg_d;
    // mem_write_e <= mem_write_d;
    // //sig_branch_e <= sig_branch_d;
    // alu_src_e <= alu_src_d;
    // reg_dst_e <= reg_dst_d;
    // mem_read_e <= mem_read_d;
    // extend_num_e <= extend_num_d;
    // alu_control_e <= alu_control_d;
    // // instruction_e <= instruction_d;
    // rs_address_e <= rs_address_d;
    // rt_address_e <= rt_address_d;
    // rd_address_e <= rd_address_d;
    // shamp_e <= shamp_d;
    // sig_shamp_e <= sig_shamp_d;
    // I_type_e <= I_type_d;
    // sw_e <= sw_d;

end
endmodule


module EX_MEM(
input clock, reg_write_e,mem_to_reg_e,mem_write_e, mem_read_e, I_type_e, sw_e,
input[31:0] write_data_e, 
input[4:0] write_reg_e, rd_address_e,
input[31:0] alu_out_e,
output reg reg_write_m,mem_to_reg_m,mem_write_m, mem_read_m, I_type_m, sw_m,
output reg[31:0] write_data_m, 
output reg[4:0] write_reg_m, rd_address_m,
output reg[31:0] alu_out_m
);
always @(posedge clock) begin
    reg_write_m <= reg_write_e;
    mem_to_reg_m <= mem_to_reg_e;
    mem_write_m <= mem_write_e;
    mem_read_m <= mem_read_e;
    alu_out_m <= alu_out_e;
    write_data_m <= write_data_e;
    write_reg_m <= write_reg_e;
    rd_address_m <= rd_address_e;
    I_type_m <= I_type_e;
    sw_m <= sw_e;
end
endmodule


module MEM_WB(
input clock, 
input reg_write_m,mem_to_reg_m,I_type_m, sw_m,
input [31:0] read_data_m, 
input [4:0] write_reg_m,
input [31:0] alu_out_m,
output reg reg_write_w,mem_to_reg_w, I_type_w, sw_w,
output reg[31:0] read_data_w, 
output reg[4:0] write_reg_w,
output reg[31:0] alu_out_w
);
always @(posedge clock) begin
    reg_write_w <= reg_write_m;
    mem_to_reg_w <= mem_to_reg_m;
    read_data_w <= read_data_m;
    write_reg_w <= write_reg_m;
    alu_out_w <= alu_out_m;
    I_type_w <= I_type_m;
    sw_w <= sw_m;
end

endmodule