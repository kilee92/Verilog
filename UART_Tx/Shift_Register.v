//작성자: 이광일
//설계명: UART(Tx)
//설계 목표: Shift Register를 포함하는 비동기 통신 중 하나인 UART TX Module 설계
//참고: Buad Rate은 115200(1/115200마다 1비트 전송)이며 시작비트(0)과 끝비트(1)을 포함하고 데이터비트는 8비트이다.

//IDLE(대기), LOAD_TX(데이터저장), SEND_TX(데이터전송)
//Baud Rate를 맞추기 위해 bps 카운터는 데이터 송신 상태인 SEND_TX 상태일 때만 구동

module Shift_Register(
    clk         ,
    rst_n       ,
    d           ,
    load        ,
    shift_en    ,
    q            
);

input               clk         ;
input               rst_n       ;
input [7:0]         d           ;
input               load        ;
input               shift_en    ;

output              q           ;

reg [9:0] d_reg;

always @(posedge clk) begin
    if(!rst_n)
        d_reg <= 10'b11_1111_1111;
    else if(load)
        d_reg <= {1'b1, d, 1'b0};
    else if(shift_en)
        tx_d_reg <= {1'b1, tx_d_reg[9:1]};
    else
        tx_d_reg <= tx_d_reg;
end

assign o_tx_d = tx_d_reg[0];

endmodule
