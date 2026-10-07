# test:compile; vvp ALU;
# compile: alu.v test_alu.v; 
# 		 iverilog -o ALU.v test_alu.v;

alu: ALU.v test_ALU.v
	iverilog -o alu ALU.v test_ALU.v
	vvp alu