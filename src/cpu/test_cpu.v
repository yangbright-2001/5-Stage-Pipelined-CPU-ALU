`timescale 1ns/1ps

`include "cpu.v"

module cpu_test();
    reg clock;
    parameter time_period = 10;

    CPU my_cpu(
        .CLK(clock)
    );

    initial begin
        clock = 0;
    end

    always begin
        #(time_period/2) clock = ~clock;
    end
endmodule
