//작성자: 이광일
//설계명: Simple MPU
//설계 목표: 기존에 설계했던 UART Rx/Tx, ALU를 이용하여 간단한 Microprocessor 설계
//참고: PC에서부터 데이터를 UART Rx 통해 받아 ALU 연산 이후 UART Tx를 통해 PC로 전송

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
output              o_tx_d

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

Shift_Register u2(
    .clk         (clk     ),
    .rst_n       (rst_n   ),
    .i_tx_d      (i_tx_d  ),
    .load        (load    ),
    .shift_en    (shift_en),
    .o_tx_d      (o_tx_d  )     
);

endmodule
