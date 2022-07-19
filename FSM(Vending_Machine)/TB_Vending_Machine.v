
//작성자: 이광일
//설계 목표: Finite State Machine (Moore)를 이용한 자판기 설계

`timescale 1ns/1ps

module TB_Vending_Machine();

reg             clk             ;
reg             rst_n           ;
reg             i_coin          ;
reg             i_coffee        ;
reg             i_sprite        ;

wire            o_led_coffee    ;
wire            o_led_sprite    ;
wire            o_coffee        ;
wire            o_sprite        ;
wire [7:0]      o_seg           ;

wire [1:0]      BCD_signal      ;

always #10 clk = ~clk; //클럭 주파수는 50MHz로 설정 (주기는 20ns)

initial begin
    clk = 0;
    rst_n = 1;
    i_coin = 0;
    i_coffee = 0;
    i_sprite = 0;
    #20

    //Reset
    rst_n = 0;
    #20

    rst_n = 1;
    #100



    //CHECK IDLE, COIN_1, COFFEE_OUT_1
    i_coin = 1;
    #20

    i_coin = 0;
    #20

    i_coffee = 1;
    #20

    i_coffee = 0;
    #100


    //CHECK COIN_2, COFFEE_OUT_2
    i_coin = 1;
    #20

    i_coin = 0;
    #20

    i_coin = 1;
    #20

    i_coin = 0;
    #20

    i_coffee = 1;
    #20

    i_coffee = 0;
    #100


    //CHECK COIN_3, COFFEE_OUT_3
    i_coin = 1;
    #20

    i_coin = 0;
    #20

    i_coin = 1;
    #20

    i_coin = 0;
    #20

    i_coffee = 1;
    #20

    i_coffee = 0;
    #100



    //CHECK COIN_3, SPRITE_OUT_3
    i_coin = 1;
    #20

    i_coin = 0;
    #20

    i_sprite = 1;
    #20

    i_sprite = 0;
    #100

    $finish;

end

//Module instance
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

Segment_Decoder U1(
    .BCD_signal  (BCD_signal),
    .o_seg       (o_seg     )     
);

endmodule
