//작성자: 이광일
//설계명: Simple MPU
//설계 목표: 기존에 설계했던 UART Rx/Tx, ALU를 이용하여 간단한 Microprocessor 설계
//참고: PC에서부터 데이터를 UART Rx 통해 받아 ALU 연산 이후 UART Tx를 통해 PC로 전송

module Top_MPU
#(
    parameter SYS_CLK   = 50000000  ,
    parameter BAUD_RATE = 115200    ,
    parameter DIVISION  = 16         
)
(
    clk             ,
    rst_n           ,
    i_rx_d          ,   
    o_tx_complete   ,
    o_tx_d           
);

input               clk             ;
input               rst_n           ;
input               i_rx_d          ;

output              o_tx_complete   ;
output              o_tx_d          ;

wire [7:0]          rx_data         ;
wire                rx_complete     ;
wire                rx_error        ;
wire [7:0]          txd             ;
wire                tx_en           ;


//module instance
Top_UART_Rx u0(
    .clk            (clk        ),
    .rst_n          (rst_n      ),
    .i_rx_d         (i_rx_d     ),
    .o_rx_d         (rx_data    ),  
    .o_rx_complete  (rx_complete),
    .o_rx_error     (rx_error   ) 
);

Top_Control_Unit u1(
    .clk         (clk        ),
    .rst_n       (rst_n      ),
    .rx_data     (rx_data    ),
    .rx_complete (rx_complete),
    .rx_error    (rx_error   ),
    .txd         (txd        ),
    .tx_en       (tx_en      ) 
);

Top_UART_Tx u1(
    .clk             (clk          ),
    .rst_n           (rst_n        ),
    .i_tx_d          (txd          ),
    .i_tx_en         (tx_en        ),
    .o_tx_complete   (o_tx_complete),
    .o_tx_d          (o_tx_d       ) 
);

endmodule
