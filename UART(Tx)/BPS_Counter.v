//작성자: 이광일
//설계명: UART(Tx)
//설계 목표: Shift Register를 포함하는 비동기 통신 중 하나인 UART Tx Module 설계
//참고: Buad Rate은 115200(1/115200초 마다 1비트 전송)이며 시작비트(0)과 끝비트(1)을 포함하고 데이터비트는 8비트이다.

module BPS_Counter
#(
    parameter SYS_CLK   = 50000000,
    parameter BAUD_RATE = 115200 
)
(
    clk         ,
    rst_n       ,
    bps_cnt_en  ,
    tx_done     ,
    shift_en      
);

input               clk         ;
input               rst_n       ;
input               bps_cnt_en  ;

output reg          tx_done     ;
output reg          shift_en    ; //Baud Rate에 맞춰 Shift 하기 위해 output 값에 맞춰 데이터 전송

reg [9:0] bps_cnt_reg;
reg [3:0] bit_cnt_reg;

//BPS Count register
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        bps_cnt_reg <= 10'b0;
    else if(bps_cnt_reg == (SYS_CLK / BAUD_RATE -1'b1)) //Frequency / Baud Rate -> count할 클럭 수(434회의 클럭 신호 당 1bit 전송)
        bps_cnt_reg <= 10'b0;
    else if(bps_cnt_en == 1)
        bps_cnt_reg <= bps_cnt_reg + 10'b1;
    else
        bps_cnt_reg <= 10'b0; // bps_cnt_en = 1 일 때만 카운트 시작
end

//Bit Count Register
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        bit_cnt_reg <= 0;
    else if(bit_cnt_reg == 4'd10)
        bit_cnt_reg <= 0;
    else if(bps_cnt_reg == (SYS_CLK / BAUD_RATE -1'b1))
        bit_cnt_reg <= bit_cnt_reg + 1'b1;
    else
        bit_cnt_reg <= bit_cnt_reg;
end

//Output logic
always @(posedge clk) begin
    if(bps_cnt_reg == (SYS_CLK / BAUD_RATE -1'b1)) begin       
        shift_en <= 1;
      if(bit_cnt_reg == 4'd9) //bps_cnt_reg = SYS_CLK / BAUD_RATE -1'b1 일 때 bit_cnt_reg = 9이면 10bit data (0~9 count) 전송
            tx_done <= 1;
        else
            tx_done <= 0;
    end else begin
        shift_en <= 0;
        tx_done <= 0;
    end
end

endmodule
