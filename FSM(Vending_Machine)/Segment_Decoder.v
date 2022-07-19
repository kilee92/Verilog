
//작성자: 이광일
//설계 목표: Finite State Machine (Moore)를 이용한 자판기 설계
module Segment_Decoder(
    BCD_signal  ,
    o_seg            
);

input [1:0]         BCD_signal  ;

output [7:0]        o_seg       ;

//Combinational logic을 통한 output 출력 (Karno map 이용)
assign o_seg[0] = (~i_seg[0]) | i_seg[1];
assign o_seg[1] = 1;
assign o_seg[2] = i_seg[0] | (~i_seg[1]);
assign o_seg[3] = (~i_seg[0]) | i_seg[1];
assign o_seg[4] = ~i_seg[0];
assign o_seg[5] = (~i_seg[0]) & (~i_seg[1]);
assign o_seg[6] = i_seg[1];
assign o_seg[7] = 0;

endmodule
