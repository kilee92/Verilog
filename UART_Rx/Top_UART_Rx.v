
//작성자: 이광일
//설계명: UART(Rx)
//설계 목표: Shift Register를 포함하는 비동기 통신 중 하나인 UART Tx Module 설계 (Baud Rate = 115200)
//참고:
//- 데이터 전송 시점을 예측할 수 없기 때문에 1/Baud Rate보다 빠른 주기로 샘플링 하여 시작 비트가 수신되었는지 감지하는 기능을 포함해야함.
//- 신호선의 무결성을 보장할 수 없으므로, 데이터 비트의 중간 지점 3부분에서 데이터를 샘플링하여 가장 많이 샘플링된 데이터 값을 저장해야함.

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
