//작성자: 이광일
//설계명: UART(Rx)
//설계 목표: Shift Register를 포함하는 비동기 통신 중 하나인 UART Tx Module 설계 (Baud Rate = 115200)
//참고:
//- 데이터 전송 시점을 예측할 수 없기 때문에 1/Baud Rate보다 빠른 주기로 샘플링 하여 시작 비트가 수신되었는지 감지하는 기능을 포함해야함.
//- 신호선의 무결성을 보장할 수 없으므로, 데이터 비트의 중간 지점 3부분에서 데이터를 샘플링하여 가장 많이 샘플링된 데이터 값을 저장해야함.

`timescale 1ns/1ns

module TB_UART_Rx
#(
    parameter SYS_CLK   = 50000000  ,
    parameter BAUD_RATE = 115200    ,
    parameter DIVISION  = 16         
)();

reg               clk             ;
reg               rst_n           ;
reg [7:0]         i_tx_d          ;
reg               i_tx_en         ;

wire              o_tx_complete   ;
wire              o_tx_d          ;

wire [7:0]        o_rx_d          ;
wire              o_rx_complete   ;
wire              o_rx_error      ;

always #10 clk = ~clk;

initial begin
    clk = 0;
    rst_n = 1;
    i_tx_d = 8'b1111_1111;
    i_tx_en = 0;
    #20

    //Reset
    rst_n = 0;
    #20

    rst_n = 1;
    #20

    #100

    //데이터 및 전송 시작 신호 인가
    i_tx_en = 1;
    i_tx_d = 8'b0101_0101;
    #20

    i_tx_en = 0;
    #20
    
    if(o_rx_complete) begin
        if(i_tx_d == o_rx_d)
            $display("complete", o_rx_d);
        else
            $display("complete", o_rx_d);
    end
        
    
    //모든 데이터가 전송되는 시간을 계산하여 run time 동안 대기
    #100000

    $finish;
end

Top_UART_Tx u0(
    .clk             (clk          ),
    .rst_n           (rst_n        ),
    .i_tx_d          (i_tx_d       ),
    .i_tx_en         (i_tx_en      ),
    .o_tx_complete   (o_tx_complete),
    .o_tx_d          (o_tx_d       ) 
);

Top_UART_Rx u1(
    .clk                 (clk          ),
    .rst_n               (rst_n        ),
    .i_rx_d              (o_tx_d       ),
    .o_rx_d              (o_rx_d       ),  
    .o_rx_complete       (o_rx_complete),
    .o_rx_error          (o_rx_error   ) 
);

endmodule
