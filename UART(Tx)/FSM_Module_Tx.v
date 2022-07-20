//작성자: 이광일
//설계명: UART(Tx)
//설계 목표: Shift Register를 포함하는 비동기 통신 중 하나인 UART Tx Module 설계
//참고: Buad Rate은 115200(1/115200초 마다 1비트 전송)이며 시작비트(0)과 끝비트(1)을 포함하고 데이터비트는 8비트이다.

module FSM_Module_Tx(
    clk             ,
    rst_n           ,
    i_tx_en         ,
    tx_done         ,
    bps_cnt_en      ,
    load            ,
    o_tx_complete            
);

input               clk             ;
input               rst_n           ;
input               i_tx_en         ;
input               tx_done         ;

output reg          bps_cnt_en      ;
output reg          load            ;
output              o_tx_complete   ;

reg [1:0] state, n_state;

localparam IDLE      = 2'b00; //대기 상태
localparam LOAD_TX   = 2'b01; //데이터 저장 상태
localparam SEND_TX   = 2'b11; //데이터 전송 상태

//State register
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        state <= IDLE;
    else
        state <= n_state;
end

//State logic
always @(state or i_tx_en or tx_done) begin
    case(state)
        IDLE:
            if(i_tx_en)
                n_state = LOAD_TX;
            else
                n_state = IDLE;
        
        LOAD_TX:
            n_state = SEND_TX; //데이터 저장 후 바로 전송 상태로 이동

        SEND_TX:
            if(tx_done)
                n_state = IDLE;
            else
                n_state = SEND_TX;

        default:
            n_state = IDLE;

    endcase
end

//Output logic
always @(state) begin
    case(state)
        IDLE: begin
            bps_cnt_en = 0;
            load       = 0;
        end

        LOAD_TX: begin  
            bps_cnt_en = 0;
            load       = 1; // Shift Register에 8bit data 저장
        end

        SEND_TX: begin
            bps_cnt_en = 1; // BPS_Counter enable시켜 Count 시작
            load       = 0;
        end

        default: begin 
            bps_cnt_en = 0;
            load       = 0;
        end
    endcase
end

assign o_tx_complete = tx_done;

endmodule
