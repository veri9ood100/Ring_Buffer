`timescale 1ns / 1ps

module Ring_Buffer
#(
    parameter REG_WIDTH = 8,
    parameter PTR_SIZE = 3
)
(
    input clk,
    input reset_n,
    input [1:0] mode,
    input [REG_WIDTH-1:0] WData,
    output reg isEmpty,
    output reg [REG_WIDTH-1:0] RData,
    output reg isFull
);

localparam BUFFER_SIZE = 1<<PTR_SIZE;

reg [1:0] S;
reg [PTR_SIZE:0] ptr_R;
reg [PTR_SIZE:0] ptr_W;
reg [REG_WIDTH-1:0] Buffer [BUFFER_SIZE-1:0];

//state parameter
localparam S0 = 2'b00;
localparam S1 = 2'b01;
localparam S2 = 2'b10;

//RW parameter
localparam R = 2'b01;
localparam W = 2'b10;

integer i;
always @(posedge clk, negedge reset_n) begin
    if(!reset_n) begin
        ptr_R <= 0;
        ptr_W <= 0;
        RData <= 0;
        S <= 0;
        for(i = 0; i < BUFFER_SIZE; i = i + 1) begin
            Buffer[i] <= 0;
        end
    end
    
    else begin   
        case(mode)
            R: begin
                if(!isEmpty) begin
                    
                    RData <= Buffer[ptr_R[PTR_SIZE-1:0]];
                    Buffer[ptr_R[PTR_SIZE-1:0]] <= 'd0;
                    ptr_R <= ptr_R + 1; 
                end
            end
            
            W: begin
                if(!isFull) begin                    
                    Buffer[ptr_W[PTR_SIZE-1:0]] <= WData;
                    ptr_W <= ptr_W+1;
                end
            end
            
            default: begin
                RData <= 0;
            end
        endcase
    end
end
    
always @(S) begin    
    case(S)
        S0: begin
            isEmpty <= 1;
            isFull <= 0;
        end
        
        S1: begin
            isEmpty <= 0;
            isFull <= 0;
        end
        
        S2: begin
            isEmpty <= 0;
            isFull <= 1;
        end
        
        default: begin
            isEmpty <= 'bx;
            isFull <= 'bx;
        end
    endcase
end

always @(*) begin
    if(ptr_R == ptr_W) S <= S0;
    else if((ptr_W[PTR_SIZE] != ptr_R[PTR_SIZE]) && (ptr_W[PTR_SIZE-1:0] == ptr_R[PTR_SIZE-1:0])) S <= S2;
    else S <= S1;
end

endmodule
