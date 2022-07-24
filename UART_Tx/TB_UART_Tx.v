//작성자: 이광일
//설계명: UART(Tx)
//설계 목표: Shift Register를 포함하는 비동기 통신 중 하나인 UART Tx Module 설계
//참고: Buad Rate은 115200(1/115200초 마다 1비트 전송)이며 시작비트(0)과 끝비트(1)을 포함하고 데이터비트는 8비트이다.

`timescale 1ns/1ns

module TB_UART_Tx();

reg               clk             ;
reg               rst_n           ;
reg [7:0]         i_tx_d          ;
reg               i_tx_en         ;

wire              o_tx_complete   ;
wire              o_tx_d          ;

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

endmodule
