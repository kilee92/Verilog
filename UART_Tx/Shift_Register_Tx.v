//작성자: 이광일
//설계명: UART(Tx)
//설계 목표: Shift Register를 포함하는 비동기 통신 중 하나인 UART Tx Module 설계
//참고: Buad Rate은 115200(1/115200초 마다 1비트 전송)이며 시작비트(0)과 끝비트(1)을 포함하고 데이터비트는 8비트이다.

module Shift_Register_Tx(
    clk         ,
    rst_n       ,
    i_tx_d      ,
    load        ,
    shift_en    ,
    o_tx_d                             
);

input               clk         ;
input               rst_n       ;
input [7:0]         i_tx_d      ;
input               load        ;
input               shift_en    ;

output              o_tx_d      ;

reg [9:0] d_reg;

always @(posedge clk) begin
    if(!rst_n)
        d_reg <= 10'b11_1111_1111;
    else if(load)
        d_reg <= {1'b1, i_tx_d, 1'b0};
    else if(shift_en)
        d_reg <= {1'b1, d_reg[9:1]};
    else
        d_reg <= d_reg;
end

assign o_tx_d = d_reg[0];

endmodule
