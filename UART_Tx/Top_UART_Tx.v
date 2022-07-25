//작성자: 이광일
//설계명: UART(Tx)
//설계 목표: Shift Register를 포함하는 비동기 통신 중 하나인 UART Tx Module 설계
//참고: Buad Rate은 115200(1/115200초 마다 1비트 전송)이며 시작비트(0)과 끝비트(1)을 포함하고 데이터비트는 8비트이다.

module Top_UART_Tx(
    clk             ,
    rst_n           ,
    i_tx_d          ,
    i_tx_en         ,
    o_tx_complete   ,
    o_tx_d           
);

input               clk             ;
input               rst_n           ;
input [7:0]         i_tx_d          ;
input               i_tx_en         ;

output              o_tx_complete   ;
output              o_tx_d          ;

wire                tx_done         ;
wire                bps_cnt_en      ;
wire                load            ;
wire                shift_en        ;


//module instance
FSM_Module_Tx u0(
    .clk             (clk          ),
    .rst_n           (rst_n        ),
    .i_tx_en         (i_tx_en      ),
    .tx_done         (tx_done      ),
    .bps_cnt_en      (bps_cnt_en   ),
    .load            (load         ),
    .o_tx_complete   (o_tx_complete) 
);

BPS_Counter u1(
    .clk         (clk       ),
    .rst_n       (rst_n     ),
    .bps_cnt_en  (bps_cnt_en),
    .tx_done     (tx_done   ),
    .shift_en    (shift_en  ) 
);

Shift_Register_Tx u2(
    .clk         (clk     ),
    .rst_n       (rst_n   ),
    .i_tx_d      (i_tx_d  ),
    .load        (load    ),
    .shift_en    (shift_en),
    .o_tx_d      (o_tx_d  )     
);

endmodule
