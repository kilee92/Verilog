//작성자: 이광일
//설계명: UART(Rx)
//설계 목표: Shift Register를 포함하는 비동기 통신 중 하나인 UART Tx Module 설계
//참고:
//- 데이터 전송 시점을 예측할 수 없기 때문에 1/Baud Rate보다 빠른 주기로 샘플링 하여 시작 비트가 수신되었는지 감지하는 기능을 포함해야함.
//- 신호선의 무결성을 보장할 수 없으므로, 데이터 비트의 중간 지점 3부분에서 데이터를 샘플링하여 가장 많이 샘플링된 데이터 값을 저장해야함.

module Shift_Register_Rx(
    clk             ,
    rst_n           ,
    shift_rst       ,
    catch_bit       ,
    catch_bit_cnt   ,
    o_rx_d                                        
);

input               clk             ;
input               rst_n           ;
input               shift_rst       ;
input               catch_bit       ;
input [3:0]         catch_bit_cnt   ;

output reg [7:0]    o_rx_d          ;           

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        o_rx_d <= 8'b0000_0000;
    else if(shift_rst)
        o_rx_d <= 8'b0000_0000;
    else
        o_rx_d[catch_bit_cnt] <= catch_bit;
end

endmodule
