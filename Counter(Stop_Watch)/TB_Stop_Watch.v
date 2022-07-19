//작성자: 이광일
//설계명: Stop Watch
//설계 목표: Counter를 이용한 분주기(prescaler)와 Finite State Machine (Moore)를 이용하여 스톱워치 설계
//참고: 시스템은 50MHz의 기본주파수를 갖음
`timesclae 10ns/10ns

module TB_Stop_Watch();

reg             clk             ;
reg             rst_n           ;
reg             i_start_pause   ;
reg             i_stop          ;

wire [1:0]      cnt_ctrl        ;
      
wire [3:0]      t_ms0           ;
wire [3:0]      t_ms1           ;
wire [3:0]      t_s0            ;
wire [3:0]      t_s1            ;
wire [3:0]      t_m0            ;
wire [3:0]      t_m1            ;

wire [3:0]      BCD_signal      ;

wire {7:0}      o_seg           ;
wire [6:0]      seg_sel         ;

always #10 clk = ~clk;

initial begin
    clk = 0;
    rst_n = 1;
    i_start_pause = 0;
    i_stop = 0;
    #2

    //Reset
    rst_n = 0;
    #2

    rst_n = 1;
    #10

    //Stop Watch Start
    i_start_pause = 1;
    #2

    i_start_pause = 0;
    #2

    #2500

    i_start_pause = 1;
    #2

    i_start_pause =0;
    #2

    #2500

    i_stop = 1;
    #2

    i_stop = 0;
    #10

    $finish;
end

//Module instance
Top_Stop_Watch u0(
    .clk             (clk          ),
    .rst_n           (rst_n        ),
    .i_start_pause   (i_start_pause),
    .i_stop          (i_stop       ), 
    .t_ms0           (t_ms0        ),
    .t_ms1           (t_ms1        ),
    .t_s0            (t_s0         ),
    .t_s1            (t_s1         ),
    .t_m0            (t_m0         ),
    .t_m1            (t_m1         )
);

Top_Segment_decoder u1(
    .clk         (clk    ),
    .rst_n       (rst_n  ),
    .t_ms0       (t_ms0  ),
    .t_ms1       (t_ms1  ),
    .t_s0        (t_s0   ),
    .t_s1        (t_s1   ),
    .t_m0        (t_m0   ),
    .t_m1        (t_m1   ),
    .seg_sel     (seg_sel),
    .o_seg       (o_seg  )       
);

endmodule
