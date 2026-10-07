# test:compile; vvp CPU;
# compile: cpu.v test_cpu.v; 
# 		 iverilog -o CPU cpu.v test_cpu.v;
cpu : test_cpu.v
	iverilog -o cpu.vvp test_cpu.v
	vvp cpu.vvp