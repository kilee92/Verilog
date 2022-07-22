//작성자: 이광일
//설계명: UART(Tx)
//설계 목표: Shift Register를 포함하는 비동기 통신 중 하나인 UART Tx Module 설계
//참고: Buad Rate은 115200(1/115200초 마다 1비트 전송)이며 시작비트(0)과 끝비트(1)을 포함하고 데이터비트는 8비트이다.

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
