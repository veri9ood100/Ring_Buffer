`timescale 1ns / 1ps

module tb_top(

    );

localparam R = 2'b01;
localparam W = 2'b10;

reg clk;
reg reset_n;
reg [1:0] mode;
reg [7:0] WData;
wire isEmpty;
wire [7:0] RData;
wire isFull;
    
Ring_Buffer#(
 .REG_WIDTH(8),
 .PTR_SIZE(3)
)
DUT
(
    .clk(clk),
    .reset_n(reset_n),
    .mode(mode),
    .WData(WData),
    .isEmpty(isEmpty),
    .RData(RData),
    .isFull(isFull)
);

always #10 clk = ~clk;

integer i = 0;
initial begin
    clk <= 0;
    reset_n <= 0;
    mode <= 0;
    WData <= 1;
    #10 reset_n <= 1;
    #10 mode <= W;
    repeat(4) #20 WData <= WData + 1;
    mode <= 0;
    #50 mode <= R;
    #100 mode<= W; 
    repeat(8) #20 WData <= WData + 1;
    mode <= 0;
end

initial begin
    #500 $finish;
end
endmodule
