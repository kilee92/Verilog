module Top_Module(
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

output reg          o_led_coffee    ;
output reg          o_led_sprite    ;
output reg          o_coffee        ;
output reg          o_sprite        ;
output [7:0]        o_seg           ;

wire [1:0]          BCD_signal      ;

//Module instance
FSM_Vedning_Machine u0(
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

Segment_Decoder U1(
    .BCD_signal  (BCD_signal),
    .o_seg       (o_seg     )     
);

endmodule
