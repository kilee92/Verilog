module ALU_8bit(
    i_a         ,
    i_b         ,
    i_func      ,
    alu_result    
);

input [7:0]         i_a         ;
input [7:0]         i_b         ;
input [3:0]         i_func      ;

output reg [7:0]    alu_result  ;

always @(i_a or i_b or i_func) begin
    case
        4'b0000: //A AND B
            alu_result = i_a & i_b;
        
        4'b0001: //A OR B
            alu_result = i_a | i_b;

        4'b0010: // A + B
            if(i_a + i_b >= 9'b1_0000_0000)
                alu_result = 8'hEE;
            else
                alu_result = i_a + i_b;

        4'b0011: //A - B
            if(i_a >= i_b)
                alu_result = i_a - i_b;
            else
                alu_result = 8'hEE;

        4'b0100: //A << B
            alu_result = i_a << i_b;
        
        4'b0101: //A >> B
            alu_result = i_a >> i_b;
        
        4'b0110: //A >>> B
            alu_result = i_a >>> i_b;
        
        4'b0111: //A XOR B
            alu_result = i_a ^ i_b;

        4'b1000: //if A = B, Y is True
            alu_result = (i_a == i_b) ? 8'h01 : 8'h00;

        4'b1001: //if A >= B, Y is True
            alu_result = (i_a >= i_b) ? 8'h01 : 8'h00;

        4'b1010: //if A < B, Y is True
            alu_result = (i_a < i_b) ? 8'h01 : 8'h00;

        4'b1011: // A + B*2
            alu_result = i_a + (i_b <<1);

        4'b1100: //A + 4'H4
            alu_result = i_a + 4h'4;

        4'b1101: // A - 4'H4
            alu_result = i_a - 4h'4;

        4'b1110: //if A > B, Y is A Else Y is 0
            alu_result = (i_a > i_b) ? i_a : 8'h00;

        4'b1111: //if A < B, Y is A Else Y is 0
            alu_result = (i_a < i_b) ? i_a : 8'h00

        default:
            alu_result = 8'h00;

    endcase
end
endmodule
