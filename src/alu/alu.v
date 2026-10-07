// instruction: 32-bit instruction
// regA/B: 32-bit data in registerA(addr=00000), registerB(addr=00001)
// result: 32-bit result of Alu execution
// flags: 3-bit alu flag
// flags[2] : zero flag
// flags[1] : negative flag
// flags[0] : overflow flag 

module alu(input[31:0] instruction, input[31:0] regA, input[31:0] regB, output[31:0] result, output[2:0] flags);
reg[5:0] opcode, function_code;
reg[4:0] shift_amount, rs_address, rt_address;
reg[31:0] sign_immediate, unsign_immediate;
reg[31:0] reg_result, temp_A, temp_B;
reg[2:0] reg_flag;

always @(instruction, regA, regB) begin
    // regA之地址是00000， regB之地址是00001
    temp_A = regA;
    temp_B = regB;
    reg_flag = 3'b000;
    opcode = instruction[31:26];
    function_code = instruction[5:0];
    rs_address = instruction[25:21];
    rt_address = instruction[20:16];
    shift_amount = instruction[10:6];
    sign_immediate = {{16{instruction[15]}}, instruction[15:0]};
    unsign_immediate = {{16{1'b0}}, instruction[15:0]};
    
    if (opcode == 6'b000000)
    begin
        case (function_code)
            6'b100000: begin        //add
                reg_result = temp_A + temp_B;
                if ( (temp_A[31]==0 && temp_B[31]==0 && reg_result[31]==1) || (temp_A[31]==1 && temp_B[31]==1 && reg_result[31]==0) ) begin
                    reg_flag = 3'b001;
                end
                else begin
                    reg_flag = 3'b000;
                end
            end

            6'b100001: begin        //addu
                reg_result = temp_A + temp_B;
            end

            6'b100010: begin        //sub,要考虑顺序问题，分清rs和rt具体存在哪个reg里面
                if (rs_address == 5'b00000) begin
                    reg_result = temp_A - temp_B;  //rs的内容存在regA里面，rt的内容存在regB里
                    if ( (temp_A[31]==0 && temp_B[31]==1 && reg_result[31]==1) || (temp_A[31]==1 && temp_B[31]==0 && reg_result[31]==0) ) begin
                        reg_flag = 3'b001;
                    end
                    else begin
                        reg_flag = 3'b000;
                    end
                end
                else if (rs_address == 5'b00001) begin
                    reg_result = temp_B - temp_A;
                    if ( (temp_B[31]==0 && temp_A[31]==1 && reg_result[31]==1) || (temp_B[31]==1 && temp_A[31]==0 && reg_result[31]==0) ) begin
                        reg_flag = 3'b001;
                    end
                    else begin
                        reg_flag = 3'b000;
                    end
                end
            end

            6'b100011: begin        //subu
                if (rs_address == 5'b00000) begin
                    reg_result = temp_A - temp_B;  //rs的内容存在regA里面，rt的内容存在regB里
                end
                else if (rs_address == 5'b00001) begin
                    reg_result = temp_B - temp_A;
                end
            end

            6'b100100: begin        //add
                reg_result = temp_A & temp_B;
            end
            
            6'b100111: begin        //nor
                reg_result = ~(temp_A | temp_B);
            end

            6'b100101: begin        //or
                reg_result = temp_A | temp_B;
            end

            6'b100110: begin        //xor
                reg_result = temp_A ^ temp_B;
            end

            6'b101010: begin        //slt
                if (rs_address == 5'b00000) begin
                    reg_result = temp_A - temp_B;  //rs的内容存在regA里面，rt的内容存在regB里
                end
                else if (rs_address == 5'b00001) begin
                    reg_result = temp_B - temp_A;
                end
                if ( reg_result[31] == 1'b1 ) begin
                    reg_flag = 3'b010;
                end
                else begin
                    reg_flag = 3'b000;
                end
            end

            6'b101011: begin        //sltu
                if (rs_address == 5'b00000) begin
                    reg_result = temp_A - temp_B;  //rs的内容存在regA里面，rt的内容存在regB里
                    if (temp_A < temp_B) begin
                        reg_flag = 3'b010;
                    end
                    else begin
                        reg_flag = 3'b000;
                    end
                end
                else if (rs_address == 5'b00001) begin
                    reg_result = temp_B - temp_A;
                    if (temp_B < temp_A) begin
                        reg_flag = 3'b010;
                    end
                    else begin
                        reg_flag = 3'b000;
                    end
                end
            end

            6'b000000: begin        //sll:rt左移shamt个位置，然后把结果存到rd，域rs被忽略
                if (rt_address == 5'b00000) begin
                    reg_result = temp_A << shift_amount;  //rt的内容存在regA里面，rt的内容存在regB里
                end
                else if (rt_address == 5'b00001) begin
                    reg_result = temp_B << shift_amount;
                end
            end

            6'b000100: begin        //sllv:rt左移rd个位置，然后把结果存到rd
                if (rt_address == 5'b00000) begin
                    reg_result = temp_A << temp_B;  //rt的内容存在regA里面，rt的内容存在regB里
                end
                else if (rt_address == 5'b00001) begin
                    reg_result = temp_B << temp_A;
                end
            end

            6'b000010: begin        //srl:rt右移shamt个位置，然后把结果存到rd，域rs被忽略
                if (rt_address == 5'b00000) begin
                    reg_result = temp_A >> shift_amount;  //rt的内容存在regA里面
                end
                else if (rt_address == 5'b00001) begin
                    reg_result = temp_B >> shift_amount;
                end
            end

            6'b000110: begin        //srlv:rt右移rd个位置，然后把结果存到rd
                if (rt_address == 5'b00000) begin
                    reg_result = temp_A >> temp_B;  //rt的内容存在regA里面
                end
                else if (rt_address == 5'b00001) begin
                    reg_result = temp_B >> temp_A;
                end
            end

            6'b000011: begin        //sra:rt算术右移shamt个位置，然后把结果存到rd，域rs被忽略
                if (rt_address == 5'b00000) begin
                    reg_result = temp_A >>> shift_amount;  //rt的内容存在regA里面
                end
                else if (rt_address == 5'b00001) begin
                    reg_result = temp_B >>> shift_amount;
                end
            end

            6'b000111: begin        //srav:rt算术右移rd个位置，然后把结果存到rd
                if (rt_address == 5'b00000) begin
                    reg_result = temp_A >>> temp_B;  //rt的内容存在regA里面
                end
                else if (rt_address == 5'b00001) begin
                    reg_result = temp_B >>> temp_A;
                end
            end

        endcase
    end

    else if (opcode == 6'b001000) begin   //addi: 把rs和sign_imm的值放进rt
        if (rs_address == 5'b00000) begin
            reg_result = temp_A + sign_immediate;  //rs的内容在regA里面
            if ( (temp_A[31]==0 && sign_immediate[31]==0 && reg_result[31]==1) || (temp_A[31]==1 && sign_immediate[31]==1 && reg_result[31]==0) ) begin
                reg_flag = 3'b001;
            end
            else begin
                reg_flag = 3'b000;
            end
        end
        else if (rs_address == 5'b00001) begin  //rs的内容在regB里面
            reg_result = temp_B + sign_immediate;
            if ( (temp_B[31]==0 && sign_immediate[31]==0 && reg_result[31]==1) || (temp_B[31]==1 && sign_immediate[31]==1 && reg_result[31]==0) ) begin
                reg_flag = 3'b001;
            end
            else begin
                reg_flag = 3'b000;
            end
        end
    end

    else if (opcode == 6'b001000) begin   //addiu: 把rs和sign_imm的值放进rt
        if (rs_address == 5'b00000) begin
            reg_result = temp_A + sign_immediate;  //rs的内容在regA里面
        end
        else if (rs_address == 5'b00001) begin  //rs的内容在regB里面
            reg_result = temp_B + sign_immediate;
        end
    end

    else if (opcode == 6'b001100) begin   //andi: 把rs和unsign_imm的值放进rt
        if (rs_address == 5'b00000) begin
            reg_result = temp_A & unsign_immediate;  //rs的内容在regA里面
        end
        else if (rs_address == 5'b00001) begin
            reg_result = temp_B & unsign_immediate;
        end
    end

    else if (opcode == 6'b001101) begin   //ori: 把rs和unsign_imm的值放进rt
        if (rs_address == 5'b00000) begin
            reg_result = temp_A | unsign_immediate;  //rs的内容在regA里面
        end
        else if (rs_address == 5'b00001) begin
            reg_result = temp_B | unsign_immediate;
        end
    end

    else if (opcode == 6'b001110) begin   //xori: 把rs和unsign_imm的值放进rt
        if (rs_address == 5'b00000) begin
            reg_result = temp_A ^ unsign_immediate;  //rs的内容在regA里面
        end
        else if (rs_address == 5'b00001) begin
            reg_result = temp_B ^ unsign_immediate;
        end
    end

    else if (opcode == 6'b000100) begin   //beq,返回rs-rt
        if (rs_address == 5'b00000) begin
            reg_result = temp_A - temp_B;  //rs的内容在regA里面
        end
        else if (rs_address == 5'b00001) begin
            reg_result = temp_B - temp_A;
        end
        if (reg_result == 32'b0) begin
            reg_flag = 3'b100;
        end
        else begin
            reg_flag = 3'b000;
        end
    end

    else if (opcode == 6'b000101) begin   //bne
        if (rs_address == 5'b00000) begin
            reg_result = temp_A - temp_B;  //rs的内容在regA里面
        end
        else if (rs_address == 5'b00001) begin
            reg_result = temp_B - temp_A;
        end
        if (reg_result == 32'b0) begin
            reg_flag = 3'b100;
        end
        else begin
            reg_flag = 3'b000;
        end
    end

    else if (opcode == 6'b001010) begin   //slti,rs跟sign_immediate比
        if (rs_address == 5'b00000) begin
            reg_result = temp_A - sign_immediate;  //rs的内容在regA里面
        end
        else if (rs_address == 5'b00001) begin
            reg_result = temp_B - sign_immediate;
        end
        if ( reg_result[31] == 1'b1 ) begin
            reg_flag = 3'b010;
        end
        else begin
            reg_flag = 3'b000;
        end
    end

    else if (opcode == 6'b001011) begin   //sltiu,rs跟unsign_immediate比
        if (rs_address == 5'b00000) begin
            reg_result = temp_A - unsign_immediate;  //rs的内容在regA里面
            if (temp_A < unsign_immediate) begin
                reg_flag = 3'b010;
            end
            else begin
                reg_flag = 3'b000;
            end
        end
        else if (rs_address == 5'b00001) begin
            reg_result = temp_B - unsign_immediate;
            if (temp_B < unsign_immediate) begin
                reg_flag = 3'b010;
            end
            else begin
                reg_flag = 3'b000;
            end
        end
    end

    else if (opcode == 6'b100011) begin     //lw
        if (rs_address == 5'b00000) begin
            reg_result = temp_A + sign_immediate;  //rs的内容在regA里面
        end
        else if (rs_address == 5'b00001) begin
            reg_result = temp_B + sign_immediate;
        end
    end

    else if (opcode == 6'b101011) begin     //sw
        if (rs_address == 5'b00000) begin
            reg_result = temp_A + sign_immediate;  //rs的内容在regA里面
        end
        else if (rs_address == 5'b00001) begin
            reg_result = temp_B + sign_immediate;
        end
    end
    
end

assign result = reg_result;
assign flags = reg_flag;

endmodule
