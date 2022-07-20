//작성자: 이광일
//설계명: UART(Tx)
//설계 목표: Shift Register를 포함하는 비동기 통신 중 하나인 UART Tx Module 설계
//참고: Buad Rate은 115200(1/115200초 마다 1비트 전송)이며 시작비트(0)과 끝비트(1)을 포함하고 데이터비트는 8비트이다.

module Top_Vending_Machine(
    clk             ,
    rst_n           ,
    i_coin          ,
    i_coffee        ,
    i_sprite        ,
    o_led_coffee    ,
    o_led_sprite    ,
    o_coffee        ,
    o_sprite        ,
    o_seg            
);

input               clk             ;
input               rst_n           ;
input               i_coin          ;
input               i_coffee        ;
input               i_sprite        ;

output              o_led_coffee    ;
output              o_led_sprite    ;
output              o_coffee        ;
output              o_sprite        ;
output [7:0]        o_seg           ;

wire [1:0]          BCD_signal      ;


//module instance
FSM_Module_VM u0(
    .clk             (clk         ),
    .rst_n           (rst_n       ),
    .i_coin          (i_coin      ),
    .i_coffee        (i_coffee    ),
    .i_sprite        (i_sprite    ),
    .o_led_coffee    (o_led_coffee),
    .o_led_sprite    (o_led_sprite),
    .o_coffee        (o_coffee    ),
    .o_sprite        (o_sprite    ),
    .BCD_signal      (BCD_signal  ) 
);

Segment_Decoder u1(
    .BCD_signal  (BCD_signal),
    .o_seg       (o_seg     ) 
);

endmodule
