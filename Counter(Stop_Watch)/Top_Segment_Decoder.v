//작성자: 이광일
//설계명: Stop Watch
//설계 목표: Counter를 이용한 분주기(prescaler)와 Finite State Machine (Moore)를 이용하여 스톱워치 설계
//참고: 시스템은 50MHz의 기본주파수를 갖음

module Top_Segment_decoder(
    clk         ,
    rst_n       ,
    t_ms0       ,
    t_ms1       ,
    t_s0        ,
    t_s1        ,
    t_m0        ,
    t_m1        ,
    seg_sel     ,
    o_seg            
);

input               clk         ;
input               rst_n       ;
input [3:0]         t_ms0       ;
input [3:0]         t_ms1       ;
input [3:0]         t_s0        ;
input [3:0]         t_s1        ;
input [3:0]         t_m0        ;
input [3:0]         t_m1        ;

output [5:0]        seg_sel     ;
output [7:0]        o_seg       ;

wire [3:0] BCD_signal;

//Module instance
FSM_Module_SegDec u0(
    .clk         (clk       ),
    .rst_n       (rst_n     ),
    .t_ms0       (t_ms0     ),
    .t_ms1       (t_ms1     ),
    .t_s0        (t_s0      ),
    .t_s1        (t_s1      ),
    .t_m0        (t_m0      ),
    .t_m1        (t_m1      ),
    .BCD_signal  (BCD_signal),
    .seg_sel     (seg_sel   )     
);

Segment_Decoder u1(
    .BCD_signal  (BCD_signal),
    .o_seg       (o_seg     )     
);

endmodule
