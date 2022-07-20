//작성자: 이광일
//설계명: Vending Machine
//설계 목표: 커피와 스프라이트를 판매하는 자판기를 Finite State Machine (Moore)를 이용하여 설계
//참고: 최대 3원까지 투입이 가능하며 7-Segment Decoder를 이용하여 LED출력 

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
Top_Vending_Machine u0(
    .clk             (clk         ),
    .rst_n           (rst_n       ),
    .i_coin          (i_coin      ),
    .i_coffee        (i_coffee    ),
    .i_sprite        (i_sprite    ),
    .o_led_coffee    (o_led_coffee),
    .o_led_sprite    (o_led_sprite),
    .o_coffee        (o_coffee    ),
    .o_sprite        (o_sprite    ),
    .o_seg           (o_seg       ) 
);

endmodule
