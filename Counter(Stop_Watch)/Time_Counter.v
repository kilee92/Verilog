//작성자: 이광일
//설계명: Stop Watch
//설계 목표: Counter를 이용한 분주기(prescaler)와 Finite State Machine (Moore)를 이용하여 스톱워치 설계
//참고: 시스템은 50MHz의 기본주파수를 갖음

module Time_Counter(
    clk         ,
    rst_n       ,   
    cnt_ctrl    ,
    t_ms0       ,
    t_ms1       ,
    t_s0        ,
    t_s1        ,
    t_m0        ,
    t_m1              
);

input               clk         ;
input               rst_n       ;
input [1:0]         cnt_ctrl    ;

//단위 시간별(0.01초, 0.1초, 1초, 10초, 1분, 10분) Output값 출력하여 Segment Decoder Module에 전달
output reg [3:0]    t_ms0       ;
output reg [3:0]    t_ms1       ;
output reg [3:0]    t_s0        ;
output reg [3:0]    t_s1        ;
output reg [3:0]    t_m0        ;
output reg [3:0]    t_m1        ;

//2^16 = 65536
reg [15:0] cnt_reg;

parameter IDLE   = 2'b00;
parameter COUNT  = 2'b01;
parameter PAUSE  = 2'b10;

//Count register
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        cnt_reg <= 16'b0;
    else if((cnt_reg == 49/*9999*/) || (cnt_ctrl == IDLE))
        cnt_reg <= 16'b0;
    else if(cnt_ctrl == COUNT)
        cnt_reg <= cnt_reg + 32'b1;
    else
        cnt_reg <= cnt_reg;
end

//Output logic - 0.01초
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        t_ms0 <= 4'b0;
    else if((t_ms0 == 4'd10) || (cnt_ctrl == IDLE))
        t_ms0 <= 4'b0;
    else if(cnt_reg == 49/*9999*/)//50MHz(1초에 50000000번) -> 500000 카운트하여 0.01초를 찾음 (test를 위해 49로 축소)
        t_ms0 <= t_ms0 + 4'b1;
    else
        t_ms0 <= t_ms0;
end

//Output logic - 0.1초
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        t_ms1 <= 4'b0;
    else if((t_ms1 == 4'd10) || (cnt_ctrl == IDLE))
        t_ms1 <= 4'b0;
    else if(t_ms0 == 4'd10)
        t_ms1 <= t_ms1 + 4'b1;
    else
        t_ms1 <= t_ms1;
end

//Output logic - 1초
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        t_s0 <= 4'b0;
    else if((t_s0 == 4'd10) || (cnt_ctrl == IDLE))
        t_s0 <= 4'b0;
    else if(t_ms1 == 4'd10)
        t_s0 <= t_s0 + 4'b1;
    else
        t_s0 <= t_s0;
end

//Output logic - 10초
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        t_s1 <= 4'b0;
    else if((t_s1 == 4'd10) || (cnt_ctrl == IDLE))
        t_s1 <= 4'b0;
    else if(t_s0 == 4'd10)
        t_s1 <= t_s1 + 4'b1;
    else
        t_s1 <= t_s1;
end

//Output logic - 1분
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        t_m0 <= 4'b0;
    else if((t_m0 == 4'd10) || (cnt_ctrl == IDLE))
        t_m0 <= 4'b0;
    else if(t_s1 == 4'd10)
        t_m0 <= t_m0 + 4'b1;
    else
        t_m0 <= t_m0;
end

//Output logic - 10분
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        t_m1 <= 4'b0;
    else if((t_m1 == 4'd10) || (cnt_ctrl == IDLE))
        t_m1 <= 4'b0;
    else if(t_m0== 4'd10)
        t_m1 <= t_m1 + 4'b1;
    else
        t_m1 <= t_m1;
end

endmodule
