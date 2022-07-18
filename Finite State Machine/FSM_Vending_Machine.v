//작성자: 이광일
//설계 목표: Finite State Machine (Moore)를 이용한 자판기 설계

module FSM_Vedning_Machine(
    clk             ,
    rst_n           ,
    i_coin          ,
    i_coffee        ,
    i_sprite        ,
    o_led_coffee    ,
    o_led_sprite    ,
    o_coffee        ,
    o_sprite        ,
    BCD_signal       
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
output reg [1:0]    BCD_signal      ; // Segment Decoder input을 위한 BCD signal 출력 (2bit: 0~4)

reg [2:0] state, n_state;

//State parameter - local 파라미터: FSM 내부에서만 사용하는 파라미터 선언(외부 변경 불가)
localparam  IDLE            = 3'b000;
localparam  COIN_1          = 3'b001;
localparam  COIN_2          = 3'b010;
localparam  COIN_3          = 3'b011;
localparam  COFFEE_OUT_1    = 3'b100;
localparam  COFFEE_OUT_2    = 3'b101;
localparam  COFFEE_OUT_3    = 3'b110;
localparam  SPRITE_OUT      = 3'b111;

//State register
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
    end else
        state <= n_state;
end

//State logic
always(state or i_coin or i_coffee or i_sprite) begin
    case(state)
        IDLE:
            if(i_coin)
                n_state = COIN_1;
            else
                n_state = IDLE;

        COIN_1:
            if(i_coin)
                n_state = COIN_2;
            else if(i_coffee)
                n_state = COFFEE_OUT_1;
            else
                n_state = COIN_1;

        COIN_2:
            if(i_coin)
                n_state = COIN_3;
            else if(i_coffee)
                n_state = COFFEE_OUT_2;
            else
                n_state = COIN_2;

        COIN_3:
            if(i_coffee)
                n_state = COFFEE_OUT_3;
            else if(i_sprite)
                n_state = SPRITE_OUT;
            else
                n_state = COIN_3;
        
        COFFEE_OUT_1: n_state = IDLE;

        COFFEE_OUT_2: n_state = COIN_1;

        COFFEE_OUT_3: n_state = COIN_2;

        SPRITE_OUT: n_state = IDLE;

        default: n_state = IDLE;

    endcase
end

//Output logic (Moore: 현재 상태(state)에 의해서만 output 출력)
always @(state) begin
    case(state)
        IDLE: 
            o_led_coffee <= 0;
            o_led_sprite <= 0;
            o_coffee <= 0;
            o_sprite <= 0;
            BCD_signal <= 2'b00;

        COIN_1:
            o_led_coffee <= 1;
            o_led_sprite <= 0;
            o_coffee <= 0;
            o_sprite <= 0;
            BCD_signal <= 2'b01;

        COIN_2:
            o_led_coffee <= 1;
            o_led_sprite <= 0;
            o_coffee <= 0;
            o_sprite <= 0;
            BCD_signal <= 2'b10;

        COIN_3:
            o_led_coffee <= 1;
            o_led_sprite <= 1;
            o_coffee <= 0;
            o_sprite <= 0;
            BCD_signal <= 2'b11;

        COFFEE_OUT_1: //coffee가 나온 후 IDLE state로 이동
            o_led_coffee <= 0;
            o_led_sprite <= 0;
            o_coffee <= 1;
            o_sprite <= 0;
            BCD_signal <= 2'b00;

        COFFEE_OUT_2: //coffee가 나온 후 COIN_1 state로 이동
            o_led_coffee <= 1;
            o_led_sprite <= 0;
            o_coffee <= 1;
            o_sprite <= 0;
            BCD_signal <= 2'b01;

        COFFEE_OUT_3: //coffee가 나온 후 COIN_2 state로 이동
            o_led_coffee <= 1;
            o_led_sprite <= 0;
            o_coffee <= 1;
            o_sprite <= 0;
            BCD_signal <= 2'b10;

        SPRITE_OUT: //sprite가 나온 후 IDLE state로 이동
            o_led_coffee <= 0;
            o_led_sprite <= 0;
            o_coffee <= 0;
            o_sprite <= 1;
            BCD_signal <= 2'b00;

        default: //Latch 방지
            o_led_coffee <= 0;
            o_led_sprite <= 0;
            o_coffee <= 0;
            o_sprite <= 0;
            BCD_signal <= 2'b00;

    endcase
end

endmodule
