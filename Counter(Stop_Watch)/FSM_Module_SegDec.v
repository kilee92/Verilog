//작성자: 이광일
//설계명: Stop Watch
//설계 목표: Counter를 이용한 분주기(prescaler)와 Finite State Machine (Moore)를 이용하여 스톱워치 설계
//참고: 시스템은 50MHz의 기본주파수를 갖음

module FSM_Module_SegDec(
    clk         ,
    rst_n       ,
    t_ms0       ,
    t_ms1       ,
    t_s0        ,
    t_s1        ,
    t_m0        ,
    t_m1        ,
    BCD_signal  ,
    seg_sel      
);

input               clk         ;
input               rst_n       ;
input [3:0]         t_ms0       ;
input [3:0]         t_ms1       ;
input [3:0]         t_s0        ;
input [3:0]         t_s1        ;
input [3:0]         t_m0        ;
input [3:0]         t_m1        ;

output [3:0]        BCD_signal  ; //segment 값 결정
output [5:0]        seg_sel     ; //몇번째 segment에 값을 출력할지 결정

reg [2:0] state, n_state;

parameter S0 = 3'b000;
parameter S1 = 3'b001;
parameter S2 = 3'b010;
parameter S3 = 3'b011;
parameter S4 = 3'b100;
parameter S5 = 3'b101;

always @(posedge clk or negedge rst_n) begin
    if(rst_n)
        state <= S0;
    else
        state <= n_state;
end

//State logic - 매 Clock 마다 state 변경
always @(state) begin
    case(state)
        S0: n_state = S1;
        S1: n_state = S2;
        S2: n_state = S3;
        S3: n_state = S4;
        S4: n_state = S5;
        S5: n_state = S0;
        default: S0;
    endcase
end

//Output logic - 매 클락마다 순서대로 segment 값 변경
always @(state) begin
    case(state)
        S0: 
            BCD_signal <= t_ms0;
            seg_sel <= 6'b10_0000; //1번째 Segment

        S1: n_state = S2
            BCD_signal <= t_ms1;
            seg_sel <= 6'b01_0000; //2번째 Segment
                    
        S2: n_state = S3
            BCD_signal <= t_s0;
            seg_sel <= 6'b00_1000; //3번째 Segment
            
        S3: n_state = S4
            BCD_signal <= t_s1;
            seg_sel <= 6'b00_0100; //4번째 Segment
            
        S4: n_state = S5
            BCD_signal <= t_m0;
            seg_sel <= 6'b00_0010; //5번째 Segment
            
        S5: n_state = S0
            BCD_signal <= t_m1;
            seg_sel <= 6'b00_0001; //6번째 Segment
            
        default: 
            BCD_signal <= 4'b0000;
            seg_sel <= 6'b00_0000;
            
    endcase
end

endmodule
