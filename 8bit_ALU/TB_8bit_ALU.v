`timesclae 1ns/1ns

module TB_8bit_ALU();

reg [7:0]         i_a           ;
reg [7:0]         i_b           ;
reg [3:0]         i_func        ;

wire [7:0]        alu_result    ;

initial begin
    i_a = 8'd7;
    i_b = 8'd4;
    i_func = 4'b0000;
    #10
    
    i_func = 4'b0001;
    #10
    
    i_func = 4'b0010;
    #10
    
    i_func = 4'b0011;
    #10
    
    i_func = 4'b0100;
    #10
    
    i_func = 4'b0101;
    #10
    
    i_func = 4'b0110;
    #10
    
    i_func = 4'b0111;
    #10
    
    i_func = 4'b1000;
    #10
    
    i_func = 4'b1001;
    #10
    
    i_func = 4'b1010;
    #10
    
    i_func = 4'b1011;
    #10
    
    i_func = 4'b1100;
    #10
    
    i_func = 4'b1101;
    #10
    
    i_func = 4'b1110;
    #10
    
    i_func = 4'b1111;
    #10
    
    $finish;
end

//Module instance
8bit_ALU u0(
    .i_a          (i_a   ),
    .i_b          (i_b   ),
    .i_func       (i_func),
    .alu_result   (alu_result )

);

endmodule
