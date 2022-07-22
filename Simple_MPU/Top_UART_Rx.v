//작성자: 이광일
//설계명: Simple MPU
//설계 목표: 기존에 설계했던 UART Rx/Tx, ALU를 이용하여 간단한 Microprocessor 설계
//참고: PC에서부터 데이터를 UART Rx 통해 받아 ALU 연산 이후 UART Tx를 통해 PC로 전송

module Top_UART_Rx
#(
    parameter SYS_CLK   = 50000000  ,
    parameter BAUD_RATE = 115200    ,
    parameter DIVISION  = 16         
)
(
    clk                 ,
    rst_n               ,
    i_rx_d              ,
    o_rx_d              ,  
    o_rx_complete       ,
    o_rx_error           
);

input               clk                 ;
input               rst_n               ;
input               i_rx_d              ;

output reg [7:0]    o_rx_d              ;  
output              o_rx_complete       ;
output              o_rx_error          ; 

wire                sampling            ;
wire                catch_bit           ;
wire [3:0]          catch_bit_cnt       ;
wire                shift_rst           ;
wire                o_rx_complete       ;
wire                o_rx_error          ;


//module instance
FSM_Module_Rx u0(
    clk                 (clk          ),
    rst_n               (rst_n        ),
    i_rx_d              (i_rx_d       ),
    sampling            (sampling     ),
    catch_bit           (catch_bit    ),
    catch_bit_cnt       (catch_bit_cnt),
    shift_rst           (shift_rst    ),
    o_rx_complete       (o_rx_complete),
    o_rx_error          (o_rx_error   ) 
);

Sampling_Counter u1(
    clk         (clk     ),
    rst_n       (rst_n   ),
    sampling    (sampling) 
);

Shift_Register u2(
    clk             (clk          ),
    rst_n           (rst_n        ),
    shift_rst       (shift_rst    ),
    catch_bit       (catch_bit    ),
    catch_bit_cnt   (catch_bit_cnt),
    o_rx_d          (o_rx_d       ) 
);

endmodule
