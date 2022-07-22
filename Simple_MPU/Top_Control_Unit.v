//작성자: 이광일
//설계명: Simple MPU
//설계 목표: 기존에 설계했던 UART Rx/Tx, ALU를 이용하여 간단한 Microprocessor 설계
//참고: PC에서부터 데이터를 UART Rx 통해 받아 ALU 연산 이후 UART Tx를 통해 PC로 전송

module Top_Control_Unit(
    clk         ,
    rst_n       ,
    rx_data     ,
    rx_complete ,
    rx_error    ,
    txd         ,
    tx_en        
);

input               clk         ;
input               rst_n       ;
input [7:0]         rx_data     ;
input               rx_complete ;
input               rx_error    ;

output reg [7:0]    txd         ;
output reg          tx_en       ;

wire [7:0]          a_reg       ;
wire [7:0]          b_reg       ;
wire [3:0]          f_reg       ;
wire [7:0]          alu_result  ;

//Module instance
FSM_Control_Unit u0(
    .clk         (clk        ),
    .rst_n       (rst_n      ),
    .rx_data     (rx_data    ),
    .rx_complete (rx_complete),
    .rx_error    (rx_error   ),
    .alu_result  (alu_result ),
    .txd         (txd        ),
    .tx_en       (tx_en      ),
    .a_reg       (a_reg      ),
    .b_reg       (b_reg      ),
    .f_reg       (f_reg      ) 
);

ALU u1(
    .i_a         (a_reg     ),
    .i_b         (b_reg     ),
    .i_func      (f_reg     ),
    .alu_result  (alu_result)  
);

endmodule
