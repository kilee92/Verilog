//작성자: 이광일
//설계명: Stop Watch
//설계 목표: Counter를 이용한 분주기(prescaler)와 Finite State Machine (Moore)를 이용하여 스톱워치 설계
//참고: 시스템은 50MHz의 기본주파수를 갖음

module Top_Stop_Watch();

input               clk             ;
input               rst_n           ;
input               i_start_pause   ;
input               i_stop          ;
      
output  [3:0]       t_ms0    ;
output  [3:0]       t_ms1    ;
output  [3:0]       t_s0     ;
output  [3:0]       t_s1     ;
output  [3:0]       t_m0     ;
output  [3:0]       t_m1     ;

wire [1:0] cnt_ctrl;

//Module instance
FSM_Module_StopWatch u0(
    .clk             (clk          ),
    .rst_n           (rst_n        ),
    .i_start_pause   (i_start_pause),
    .i_stop          (i_stop       ),
    .cnt_ctrl        (cnt_ctrl     )     
);

Time_Counter u1(
    .clk         (clk     ),
    .rst_n       (rst_n   ),   
    .cnt_ctrl    (cnt_ctrl),
    .t_ms0       (t_ms0   ),
    .t_ms1       (t_ms1   ),
    .t_s0        (t_s0    ),
    .t_s1        (t_s1    ),
    .t_m0        (t_m0    ),
    .t_m1        (t_m1    )      
);

endmodule
