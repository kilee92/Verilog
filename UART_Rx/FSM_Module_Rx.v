//작성자: 이광일
//설계명: UART(Rx)
//설계 목표: Shift Register를 포함하는 비동기 통신 중 하나인 UART Tx Module 설계 (Baud Rate = 115200)
//참고:
//- 데이터 전송 시점을 예측할 수 없기 때문에 1/Baud Rate보다 빠른 주기로 샘플링 하여 시작 비트가 수신되었는지 감지하는 기능을 포함해야함.
//- 신호선의 무결성을 보장할 수 없으므로, 데이터 비트의 중간 지점 3부분에서 데이터를 샘플링하여 가장 많이 샘플링된 데이터 값을 저장해야함.

module FSM_Module_Rx(
    clk                 ,
    rst_n               ,
    i_rx_d              ,
    sampling            ,
    catch_bit           ,
    catch_bit_cnt       ,
    shift_rst           ,
    o_rx_complete       ,
    o_rx_error           
);

input               clk                 ;
input               rst_n               ;
input               i_rx_d              ;
input               sampling            ;

output reg          catch_bit           ;
output reg [3:0]    catch_bit_cnt       ;
output              shift_rst           ;
output              o_rx_complete       ;
output              o_rx_error          ;

reg [3:0] state, n_state;

//State parameter
localparam IDLE              = 4'd0;
localparam START_CHECK       = 4'd1;
localparam SAMPLE_CNT_RST    = 4'd2;
localparam F_WAIT            = 4'd3;
localparam F_SAMPLE          = 4'd4;
localparam S_WAIT            = 4'd5;
localparam S_SAMPLE          = 4'd6;
localparam T_WAIT            = 4'd7;
localparam T_SAMPLE          = 4'd8;
localparam DATA_DECISION     = 4'd9;
localparam STOP_DECISION     = 4'd10;
localparam RECEIVE_COMPLETE  = 4'd11;
localparam RECEIVE_ERROR     = 4'd12;

//State register
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        state <= IDLE;
    else   
        state <= n_state;
end

//State logic
always @(state or i_rx_d or sampling or sample_cnt or bit_cnt) begin //state, i_rx_d, sampling, sample_cnt, bit_cnt 신호가 바뀔 때에만 동작(clk와 상관(X))
    case(state)
        IDLE: begin //sampling(baud rate의 16배 속도)하여 시작 비트(0)를 감지하여 다음 state로 이동
            if(sampling == 1 && i_rx_d == 0)
                n_state = START_CHECK;
            else
                n_state = IDLE;
        end

        //sample_cnt = 0일 때 1번 Sampling (IDLE state에서 1번 sampling하여 START_CHECK state로 이동했기 때문에)
        START_CHECK: begin
            if(sampling == 1 && i_rx_d == 1) //시작 비트(0) sampling 값이 1이 될 경우(Noise가 낄 경우) 다시 IDLE로 상태로 돌아가 새로운 신호 전송을 기다림
                n_state = IDLE;
            else if(sample_cnt == 8) //start 비트의 middle point+1 (9번째 sampling)까지 대기
                n_state = SAMPLE_CNT_RST;
            else
                n_state = START_CHECK;
        end

        SAMPLE_CNT_RST: n_state = F_WAIT; //sample_cnt 리셋 -> 이전 data bit의 (middle point+1)일 때 Reset되므로, sample_cnt = 0 일 때 1번 sampling

        F_WAIT: begin 
            if(sample_cnt == 14) //data bit의 middle point-1 (이전 data bit의 middle point에서 부터 15번째 sampling) 까지 대기
                n_state = F_SAMPLE; //sample_cnt = 14 이후 (1clock)
            else
                n_state = F_WAIT;
        end

        F_SAMPLE: n_state = S_WAIT; //data bit의 1번째 sample 저장 (1clock) -> sample_cnt = 14 이후 (2clock)


        S_WAIT: begin
            if(sample_cnt == 15) //data bit의 middle point(이전 data bit의 middle point에서 부터 16번째 sampling) 까지 대기
                n_state = S_SAMPLE; //sample_cnt = 15 이후 (1clock)
            else
                n_state = S_WAIT;
        end

        S_SAMPLE: n_state = T_WAIT; //data bit의 2번째 sample 저장 (1clock) -> sample_cnt = 15 이후 (2clock)

        T_WAIT: begin 
            if(sample_cnt == 16) //data bit의 middle point+1 (이전 data bit의 middle point에서 부터 17번째 sampling) 까지 대기
                n_state = T_SAMPLE; //sample_cnt = 16 이후 (1clock)
            else
                n_state = T_WAIT;
        end

        T_SAMPLE: begin //data bit의 3번째 sample 저장 (1clock) -> sample_cnt = 16 이후 (2clock)
            if(bit_cnt == 4'd8) //bit_cnt = 8일 때 stop bit까지 확인 (9번째 bit)
                n_state = STOP_DECISION;
            else //bit_cnt = 7일 때까지 (0 ~ 7 -> 8bit): data bit 저장 상태로 이동 
                n_state = DATA_DECISION;
        end

        DATA_DECISION: n_state = SAMPLE_CNT_RST; //3개의 sample bit 비교 후 register에 data bit 저장 -> sample_cnt = 16 이후 (3clock)

        STOP_DECISION: begin //Stop bit check (complete or error 결정) -> sample_cnt = 16 이후 (3clock)
            if((b0&b1) | (b0&b2) | (b1&b2) == 1'b1)
                n_state = RECEIVE_COMPLETE;
            else   
                n_state = RECEIVE_ERROR;
        end

        RECEIVE_COMPLETE: //sample_cnt = 16 이후 (4clock)
            n_state = IDLE;

        RECEIVE_ERROR:
            n_state = IDLE; //sample_cnt = 16 이후 (4clock)

        default: n_state = state;
    endcase
end

//Sample counter
//Samling 횟수를 세는 counter
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

//Bit counter
//Data bit 수를 세는 counter 
reg [3:0] bit_cnt;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        bit_cnt <= 0;
    else if(state == IDLE)
        bit_cnt <= 0;
    else if(state == DATA_DECISION)
        bit_cnt <= bit_cnt + 1'b1;
    else
        bit_cnt <= bit_cnt;
end

//Sample bit register
//신호의 무결성을 보장하기 위해 1bit 당 3개의 sample을 저장하는 Register
reg b0, b1, b2;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        b0 <= 1'b0;
        b1 <= 1'b0;
        b2 <= 1'b0;
    end else if(state == IDLE) begin
        b0 <= 1'b0;
        b1 <= 1'b0;
        b2 <= 1'b0;
    end else if(state == SAMPLE_CNT_RST) begin
        b0 <= 1'b0;
        b1 <= 1'b0;
        b2 <= 1'b0;
    end else if(state == F_SAMPLE) begin
        b0 <= i_rx_d;
    end else if(state == S_SAMPLE) begin
        b1 <= i_rx_d;
    end else if(state == T_SAMPLE) begin
        b2 <= i_rx_d;
    end else begin
        b0 <= b0;
        b1 <= b1;
        b2 <= b2;
    end
end

//Output logic
always @(state) begin  
    if(state == DATA_DECISION) begin
        catch_bit_cnt <= bit_cnt;
        catch_bit <= (b0&b1) | (b0&b2) | (b1&b2); //Karnom map을 통하여 논리식 확인
    end else begin
        catch_bit_cnt <= catch_bit_cnt;
        catch_bit <= catch_bit;
    end
end

assign shift_rst = (state == IDLE) ? 1'b1 : 1'b0;
assign o_rx_complete = (state == RECEIVE_COMPLETE) ? 1'b1 : 1'b0;
assign o_rx_error = (state == RECEIVE_ERROR) ? 1'b1 : 1'b0;

endmodule
