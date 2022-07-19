//작성자: 이광일
//설계명: Stop Watch
//설계 목표: Counter를 이용한 분주기(prescaler)와 Finite State Machine (Moore)를 이용하여 스톱워치 설계
//참고: 시스템은 50MHz의 기본주파수를 갖음

module FSM_Module_StopWatch(
    clk             ,
    rst_n           ,
    i_start_pause   ,
    i_stop          ,
    cnt_ctrl                      
);

input               clk             ;
input               rst_n           ;
input               i_start_pause   ;
input               i_stop          ;

output reg [1:0]    cnt_ctrl        ; //counter control 출력값을 통해 Counter 동작 여부 결정

reg [1:0] state, n_state;

//State parameter
parameter IDLE   = 2'b00;
parameter COUNT  = 2'b01;
parameter PAUSE  = 2'b10;

//State register(DFF)
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        state <= IDLE;
    end else
        state <= n_state;
end

//State logic
always @(state or i_start_pause or i_stop) begin
    case(state)
        IDLE:
            if(i_start_pause)
                n_state = COUNT;
            else
                n_state = IDLE;

        COUNT:
            if(i_start_pause)
                n_state = PAUSE;
            else if(i_stop)
                n_state = IDLE;
            else
                n_state = COUNT;

        PAUSE:
            if(i_start_pause)
                n_state <= COUNT;
            else if(i_stop)
                n_state <= IDLE;
            else
                n_state = PAUSE;

        default: n_state = IDLE;

    endcase
end

//Output logic
always @(state) begin
    case(state)
        IDLE: cnt_ctrl = IDLE;

        COUNT: cnt_ctrl = COUNT;

        PAUSE: cnt_ctrl = PAUSE;

        default : cnt_ctrl = IDLE;

    endcase
end

endmodule
