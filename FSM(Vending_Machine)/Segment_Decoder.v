//작성자: 이광일
//설계명: Vending Machine
//설계 목표: 커피와 스프라이트를 판매하는 자판기를 Finite State Machine (Moore)를 이용하여 설계
//참고: 최대 3원까지 투입이 가능하며 7-Segment Decoder를 이용하여 LED출력 

module Segment_Decoder(
    BCD_signal  ,
    o_seg            
);

input [1:0]         BCD_signal  ;

output [7:0]        o_seg       ;

//Combinational logic을 통한 output 출력 (Karno map 이용)
assign o_seg[0] = ~BCD_signal[0] | ~BCD_signal[1];
assign o_seg[1] = 1;
assign o_seg[2] = ~BCD_signal[0] | (~BCD_signal[1]);
assign o_seg[3] = (~BCD_signal[0]) | ~BCD_signal[1];
assign o_seg[4] = ~BCD_signal[0];
assign o_seg[5] = (~BCD_signal[0]) & (~BCD_signal[1]);
assign o_seg[6] = BCD_signal[1];
assign o_seg[7] = 0;

endmodule
