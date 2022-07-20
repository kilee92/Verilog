//작성자: 이광일
//설계명: UART(Rx)
//설계 목표: Shift Register를 포함하는 비동기 통신 중 하나인 UART Tx Module 설계
//참고: 데이터 전송 시점을 예측할 수 없기 때문에 1/Baud Rate보다 빠른 주기로 샘플링 하여 시작 비트가 수신되었는지 감지하는 기능을 포함해야함.
//      신호선의 무결성을 보장할 수 없으므로, 데이터 비트의 중간 지점 3부분에서 데이터를 샘플링하여 가장 많이 샘플링된 데이터 값 2개를 저장해야함.

module FSM_Module_Rx(
    clk                 ,
    rst_n               ,
    i_rx_d              ,
    sampling            ,
    o_rx_d              ,
    o_rx_complete       ,
    o_rx_error           
);

input               clk                 ;
input               rst_n               ;
input               i_rx_d              ;
input               sampling            ;

o_rx_d              ;
o_rx_complete       ;
o_rx_error          ;


[3:0] bit_cnt_reg;
b0, b1, b2;
 catch_bit;

reg [3:0] state, n_state;

//State parameter
parameter IDLE              = 4'd0;
parameter START_CHECK       = 4'd1;
parameter SAMPLE_CNT_RST    = 4'd2;
parameter F_WAIT            = 4'd3;
parameter F_SAMPLE          = 4'd4;
parameter S_WAIT            = 4'd5;
parameter S_SAMPLE          = 4'd6;
parameter T_WAIT            = 4'd7;
parameter T_SAMPLE          = 4'd8;
parameter DATA_DECISION     = 4'd9;
parameter STOP_DECISION     = 4'd10;
parameter RECEIVE_COMPLETE  = 4'd11;
parameter RECEIVE_ERROR     = 4'd12;

//State register
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        state <= IDLE;
    else   
        state <= n_state;
end

//State logic
always @(state or i_rx_d or sampling) begin //state, i_rx_d, sampling 신호가 바뀔 때에만 동작(clk와 상관(X))
    case(state)
        IDLE: begin
            if(sampling == 1 && i_rx_d == 0) //sampling하여 시작 비트(0)를 감지
                n_state = START_CHECK;
            else
                n_state = IDLE;
        end

        START_CHECK: begin
            if(sampling == 1 && i_rx_d == 1) //sampling 하는 시작 비트(0)가 1이 될 경우(Noise가 낄 경우) 다시 IDLE로 상태로 돌아가 새로운 신호 전송을 기다림
                n_state = IDLE;
            else if(sample_cnt == 7) // 8 check (0 ~ 7) -> middle point
                n_state = SAMPLE_CNT_RST;
            else
                n_state = START_CHECK;
        end

        SAMPLE_CNT_RST:
            n_state = F_WAIT;

        F_WAIT: begin

            if(sampling_flag == 1) begin
                if(sample_cnt_reg == 13) 
                    n_state = F_SAMPLE;
                else
                    n_state = F_WAIT;
            end else
                n_state = F_WAIT;
        end

        F_SAMPLE:
            n_state = S_WAIT;

        S_WAIT: begin
            if(sampling_flag == 1) begin
                if(sample_cnt_reg == 14) 
                    n_state = S_SAMPLE;
                else
                    n_state = S_WAIT;
            end else
                n_state = S_WAIT;
        end

        S_SAMPLE:
            n_state = T_WAIT;

        T_WAIT: begin
            if(sampling_flag == 1) begin
                if(sample_cnt_reg == 15) //16 times flag(cnt = 15) -> bit middle point
                    n_state = T_SAMPLE;
                else
                    n_state = T_WAIT;
            end else
                n_state = T_WAIT;
        end

        T_SAMPLE: begin
            if(bit_cnt_reg == 4'd8) // bit Counter가 7이면 8bit는 결정되고 1bit(종료bit)는 결정대기중 -> STOP_DIVISION으로 state이동
                n_state = STOP_DECISION;
            else
                n_state = DATA_DECISION;
        end

        DATA_DECISION:
            n_state = SAMPLE_CNT_RST;

        STOP_DECISION: begin
            if(catch_bit == 1'b1)
                n_state = RECEIVE_COMPLETE;
            else   
                n_state = RECEIVE_ERROR;
        end

        RECEIVE_COMPLETE:
            n_state = IDLE;

        RECEIVE_ERROR:
            n_state = IDLE;

        default: n_state = state;
    endcase
end

//sample bit
always @(posedge clk) begin
    if(state == IDLE) begin
        b0 <= 0;
        b1 <= 0;
        b2 <= 0;
    end else if (state == SAMPLE_CNT_RST) begin
        b0 <= 0;
        b1 <= 0;
        b2 <= 0;
    end else if(state == F_SAMPLE)
        b0 <= i_rx_d;
    else if(state == S_SAMPLE)
        b1 <= i_rx_d;
    else if(state == S_SAMPLE)
        b2 <= i_rx_d;
    else begin
        b0 <= b0;
        b1 <= b1;
        b2 <= b2;
    end
end 

assign catch_bit = b0&b1 | b0&b2 | b1&b2;

//output logic
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        o_rx_d <= 8'b1111_1111;
    else begin
        if(state == DATA_DECISION)
            o_rx_d[bit_cnt_reg] <= catch_bit;
        else
            o_rx_d <= o_rx_d;
    end
end

assign o_rx_complete = state == RECEIVE_COMPLETE ? 1'b1 : 1'b0;
assign o_rx_error = state == RECEIVE_ERROR ? 1'b1 : 1'b0;

//Sample counter
reg [4:0] sample_cnt;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        sample_cnt <= 0;
    else if(state == IDLE)
        sample_cnt <= 0;
    else if(state == SAMPLE_CNT_RST)
        sample_cnt <= 0;
    else begin
        if(sampling)
            sample_cnt <= sample_cnt + 1'b1;
        else
            sample_cnt <= sample_cnt;
    end
end

//bit counter
always @(posedge clk) begin
    case(state)
        IDLE:
            bit_cnt_reg <= 4'd0;
        
        DATA_DECISION:
            bit_cnt_reg <= bit_cnt_reg + 1'b1;
        
        default: 
            bit_cnt_reg <= bit_cnt_reg;

    endcase
end

endmodule
