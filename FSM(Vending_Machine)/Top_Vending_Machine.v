//작성자: 이광일
//설계명: Vending Machine
//설계 목표: 커피와 스프라이트를 판매하는 자판기를 Finite State Machine (Moore)를 이용하여 설계
//참고: 최대 3원까지 투입이 가능하며 7-Segment Decoder를 이용하여 LED출력 

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
