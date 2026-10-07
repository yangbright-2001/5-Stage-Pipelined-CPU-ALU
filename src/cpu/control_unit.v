module control_unit(
input [31:0] instruction,
output reg[4:0] ALU_control,
output reg reg_write,mem_to_reg,mem_write,sig_branch,alu_src, sw_d,
output reg reg_dst,sign_extend, mem_read, sig_shamp, I_type,
output reg[2:0] pc_signal_d
);

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

reg ALUSrc1,ALUSrc2; // ALUSrc1 is used to select SrcBE, ALUSrc2 is used to select SrcAE

reg[5:0] op_code, function_code;

// initial begin
//     op_code = instruction[31:26];
//     function_code = instruction[5:0];
// end

always @(*) begin
    op_code = instruction[31:26];
    function_code = instruction[5:0];
    sig_shamp = 0;
    reg_write = 0;
    mem_to_reg = 0;
    mem_write = 0;
    sig_branch = 0;
    sign_extend = 0;
    alu_src = 0; //0:use RD2E, 1:use immediate
    reg_dst = 0; //0:use rt as destination, 1:use rd
    ALU_control = 5'b00000;
    pc_signal_d = 3'b000;
    mem_read = 0;
    I_type = 0;
    sw_d = 0;
    if (op_code == 6'b000000) begin
        case(function_code)
            6'b100000:begin //add
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                sig_branch = 0;
                alu_src = 0;
                reg_dst = 1;
                sign_extend = 0;
                mem_read = 0;
                sig_shamp = 0;
                ALU_control = ADD;
                I_type = 1;
            end
            6'b100001:begin //addu
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_dst = 1;
                sig_branch = 0;
                sign_extend = 0;
                mem_read = 0;
                sig_shamp = 0;
                ALU_control = ADDU;
                I_type = 1;
            end
            6'b100010:begin //sub
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_dst = 1;
                sig_branch = 0;
                sign_extend = 0;
                mem_read = 0;
                sig_shamp = 0;
                ALU_control = SUB;
                I_type = 1;
            end
            6'b100011:begin //subu
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_dst = 1;
                sig_branch = 0;
                sign_extend = 0;
                mem_read = 0;
                sig_shamp = 0;
                ALU_control = SUBU;
                I_type = 1;
            end
            6'b100100:begin //and
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_dst = 1;
                sig_branch = 0;
                sign_extend = 0;
                mem_read = 0;
                sig_shamp = 0;
                ALU_control = AND;
                I_type = 1;
            end
            6'b100111:begin //nor
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_dst = 1;
                sig_branch = 0;
                sign_extend = 0;
                mem_read = 0;
                sig_shamp = 0;
                ALU_control = NOR;
                I_type = 1;
            end
            6'b100101:begin //or
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_dst = 1;
                sig_branch = 0;
                sign_extend = 0;
                mem_read = 0;
                sig_shamp = 0;
                ALU_control = OR;
                I_type = 1;
            end
            6'b100110:begin //xor
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_dst = 1;
                sig_branch = 0;
                sign_extend = 0;
                mem_read = 0;
                sig_shamp = 0;
                I_type = 1;
                ALU_control = XOR;
            end
            6'b000000:begin //sll
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_dst = 1;
                sig_branch = 0;
                sign_extend = 0;
                mem_read = 0;
                sig_shamp = 1;
                I_type = 1;
                ALU_control = SLL;
            end
            6'b000100:begin //sllv
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_dst = 1;
                sig_branch = 0;
                sign_extend = 0;
                mem_read = 0;
                sig_shamp = 0;
                I_type = 1;
                ALU_control = SLLV;
            end
            6'b000010:begin //srl
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_dst = 1;
                sig_branch = 0;
                sign_extend = 0;
                mem_read = 0;
                sig_shamp = 1;
                I_type = 1;
                ALU_control = SRL;
            end
            6'b000110:begin//srlv
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_dst = 1;
                sig_branch = 0;
                sign_extend = 0;
                mem_read = 0;
                I_type = 1;
                ALU_control = SRLV;
            end
            6'b000011:begin//sra
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_dst = 1;
                sig_branch = 0;
                sign_extend = 0;
                mem_read = 0;
                sig_shamp = 1;
                I_type = 1;
                ALU_control = SRA;
            end
            6'b000111:begin//srav
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_dst = 1;
                sig_branch = 0;
                sign_extend = 0;
                mem_read = 0;
                I_type = 1;
                ALU_control = SRAV;
            end
            6'b101010: begin//slt
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_dst = 1;
                sig_branch = 0;
                sign_extend = 0;
                mem_read = 0;
                I_type = 1;
                ALU_control = SLT;
            end
            6'b001000: begin//jr
                reg_write = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_dst = 1;
                sig_branch = 0;
                sign_extend = 0;
                mem_read = 0;
                ALU_control = JR;
                I_type = 1;
                pc_signal_d = 3'b011;
            end
        
        endcase      
    end

    else if (op_code == 6'b001000) begin   //addi: 把rs和sign_imm的值放进rt
        reg_write = 1;
        mem_to_reg = 0;
        mem_write = 0;
        alu_src = 1;    //用immediate
        reg_dst = 0;    //用rt作为终点
        sig_branch = 0;
        sign_extend = 1;
        mem_read = 0;
        ALU_control = ADDI;
        I_type = 0;
    end

    else if (op_code == 6'b001001) begin   //addiu: 把rs和sign_imm的值放进rt
        reg_write = 1;
        mem_to_reg = 0;
        mem_write = 0;
        alu_src = 1;    //用immediate
        reg_dst = 0;    //用rt作为终点
        sig_branch = 0;
        sign_extend = 1;
        mem_read = 0;
        ALU_control = ADDIU;
        I_type = 0;
    end

    else if (op_code == 6'b001100) begin   //andi: 把rs和unsign_imm的值放进rt
        reg_write = 1;
        mem_to_reg = 0;
        mem_write = 0;
        alu_src = 1;    //用immediate
        reg_dst = 0;    //用rt作为终点
        sig_branch = 0;
        mem_read = 0;
        sign_extend = 0;
        I_type = 0;
        ALU_control = ANDI;
    end

    else if (op_code == 6'b001101) begin   //ori: 把rs和unsign_imm的值放进rt
        reg_write = 1;
        mem_to_reg = 0;
        mem_write = 0;
        alu_src = 1;    //用immediate
        reg_dst = 0;    //用rt作为终点
        sig_branch = 0;
        mem_read = 0;
        sign_extend = 0;
        I_type = 0;
        ALU_control = ORI;
    end

    else if (op_code == 6'b001110) begin   //xori: 把rs和unsign_imm的值放进rt
        reg_write = 1;
        mem_to_reg = 0;
        mem_write = 0;
        alu_src = 1;    //用immediate
        reg_dst = 0;    //用rt作为终点
        sig_branch = 0;
        sign_extend = 0;
        mem_read = 0;
        I_type = 0;
        ALU_control = XORI;
    end

    else if (op_code == 6'b000100) begin   //beq
        reg_write = 0;
        mem_to_reg = 0;
        mem_write = 0;
        sig_branch = 1;
        alu_src = 0;    
        reg_dst = 0;   
        sign_extend = 1;
        mem_read = 0;
        ALU_control = BEQ;
        I_type = 0;
        pc_signal_d = 3'b010;
    end

    else if (op_code == 6'b000101) begin   //bne
        reg_write = 0;
        mem_to_reg = 0;
        mem_write = 0;
        sig_branch = 1;
        alu_src = 0;    
        reg_dst = 0;   
        sign_extend = 1; 
        mem_read = 0;
        I_type = 0;
        pc_signal_d = 3'b010;
        ALU_control = BNE;
    end


    else if (op_code == 6'b100011) begin     //lw
        // $display("hello10");
        reg_write = 1;
        mem_to_reg = 1;
        mem_write = 0;
        sig_branch = 0;
        alu_src = 1;    
        reg_dst = 0;    //用rt作为终点
        sign_extend = 1;
        mem_read = 1;
        I_type = 0;
        ALU_control = LW;
    end

    else if (op_code == 6'b101011) begin  //sw:save the word from register rt at address
        reg_write = 0;
        mem_to_reg = 0;//
        mem_write = 1;
        sig_branch = 0;
        alu_src = 1;    
        reg_dst = 0;    //用rt作为终点
        sign_extend = 1;
        mem_read = 0;
        I_type = 0;
        ALU_control = SW;
        sw_d = 1;
    end

    else if (op_code == 6'b000010) begin     //j
        reg_write = 0;
        mem_to_reg = 0;
        mem_write = 0;
        sig_branch = 0;
        alu_src = 0;    
        reg_dst = 0;    //用rt作为终点
        pc_signal_d = 3'b001;
        I_type = 0;
        ALU_control = J;
    end

    else if (op_code == 6'b000011) begin     //jal
        reg_write = 1;  //要把结果写进$ra
        mem_to_reg = 0;
        mem_write = 0;
        sig_branch = 0;
        alu_src = 0;    
        reg_dst = 0;   
        pc_signal_d = 3'b001;
        I_type = 0;
        ALU_control = JAL;
    end

end

endmodule
