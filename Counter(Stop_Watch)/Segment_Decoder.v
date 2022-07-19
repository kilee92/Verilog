//작성자: 이광일
//설계명: Stop Watch
//설계 목표: Counter를 이용한 분주기(prescaler)와 Finite State Machine (Moore)를 이용하여 스톱워치 설계
//참고: 시스템은 50MHz의 기본주파수를 갖음

module Segment_Decoder(
    BCD_signal  ,
    o_seg        
);

input [3:0]         BCD_signal  ;
output [7:0]        o_seg       ;

always @(BCD_signal) begin
    case(BCD_signal)
        4'd0: o_seg = 8'b0011_1111;
        4'd1: o_seg = 8'b0000_0110;
        4'd2: o_seg = 8'0101_1011;
        4'd3: o_seg = 8'b0100_1111;
        4'd4: o_seg = 8'b0110_0110;
        4'd5: o_seg = 8'b0110_1101;
        4'd6: o_seg = 8'b0111_1100;
        4'd7: o_seg = 8'b0000_0111;
        4'd8: o_seg = 8'b0111_1111;
        4'd9: o_seg = 8'b0110_0111;
        default: o_seg = 8'b0000_0000;
    endcase
end

endmodule
