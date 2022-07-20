//작성자: 이광일
//설계명: UART(Rx)
//설계 목표: Shift Register를 포함하는 비동기 통신 중 하나인 UART Tx Module 설계
//참고: 데이터 전송 시점을 예측할 수 없기 때문에 1/Baud Rate보다 빠른 주기로 샘플링 하여 시작 비트가 수신되었는지 감지하는 기능을 포함해야함.
//      신호선의 무결성을 보장할 수 없으므로, 데이터 비트의 중간 지점 3부분에서 데이터를 샘플링하여 가장 많이 샘플링된 데이터 값 2개를 저장해야함.

module Sampling_Counter
#(
    parameter SYS_CLK   = 50000000  ,
    parameter BAUD_RATE = 115200    ,
    parameter DIVISION  = 16         
)
(
    clk         ,
    rst_n       ,
    sampling    ,                    
)

input               clk         ,
input               rst_n       ,

output              sampling    ,

reg [4:0] sampling_reg;

//Sampling count register
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        sampling_reg <= 0;
    else if(sampling_reg == SYS_CLK/(BAUD_RATE*DIVISION) - 1'b1) //1초에 115200*16개의 Sample 확인(baud rate보다 16빠른 속도)
        sampling_reg <= 0;
    else
        sampling_reg <= sampling_reg + 1'b1;
end

//Output logic
always @(posedge clk or negedge rst_n) begin
    if(sampling_reg == SYS_CLK/(BAUD_RATE*DIVISION) - 1'b1)
        sampling <= 1;
    else 
        sampling <= 0;
end

endmodule
