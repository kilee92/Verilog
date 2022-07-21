//작성자: 이광일
//설계명: UART(Rx)
//설계 목표: Shift Register를 포함하는 비동기 통신 중 하나인 UART Tx Module 설계
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
output reg          shift_rst           ;
output              o_rx_complete       ;
output              o_rx_error          ;

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
always @(state or i_rx_d or sampling or sample_cnt or bit_cnt) begin //state, i_rx_d, sampling, sample_cnt, bit_cnt 신호가 바뀔 때에만 동작(clk와 상관(X))
    case(state)
        IDLE: begin //sampling(baud rate의 16배 속도)하여 시작 비트(0)를 감지하여 다음 state로 이동
            if(sampling == 1 && i_rx_d == 0)
                n_state = START_CHECK;
            else
                n_state = IDLE;
        end

        START_CHECK: begin
            if(sampling == 1 && i_rx_d == 1) //시작 비트(0) sampling 값이 1이 될 경우(Noise가 낄 경우) 다시 IDLE로 상태로 돌아가 새로운 신호 전송을 기다림
                n_state = IDLE;
            else if(sample_cnt == 8) //sample_cnt = 8(sample_cnt = 7 이 끝나는 순간)일 때 8번(0 ~ 7)을 check하고 다음 클락에 state 변경 -> middle point
                n_state = SAMPLE_CNT_RST;
            else
                n_state = START_CHECK;
        end

        SAMPLE_CNT_RST: n_state = F_WAIT; //sample_cnt 리셋

        F_WAIT: begin //시작 비트(0) middle point에서 부터 data bit (middle point - 1) 까지 
            if(sample_cnt == 15) 
                n_state = F_SAMPLE; // 다음 클럭에 state 변화 (다음 sampling이 아님)
            else
                n_state = F_WAIT;
        end

        F_SAMPLE: n_state = S_WAIT; //데이터 비트의 1번째 sample 저장

        S_WAIT: begin //시작 비트(0) middle point에서 부터 data bit (middle point) 까지 
            if(sample_cnt == 16) 
                n_state = S_SAMPLE;
            else
                n_state = S_WAIT;
        end

        S_SAMPLE: n_state = T_WAIT; //데이터 비트의 2번째 sample 저장

        T_WAIT: begin //시작 비트(0) middle point에서 부터 data bit (middle point + 1) 까지 
            if(sample_cnt == 17) //sample_cnt = 16 일때 16번 check가 끝나는 시점 -> middle point
                n_state = T_SAMPLE;
            else
                n_state = T_WAIT;
        end

        T_SAMPLE: begin //데이터 비트의 3번째 sample 저장 //8개의 data 데이터 & 1개의 stop bit가 들어 왔는지 확인
            if(bit_cnt == 4'd8) //bit_cnt = 8일 때 stop bit 확인 (9번째 bit)
                n_state = STOP_DECISION;
            else //bit_cnt = 7일 때까지 (0 ~ 7 -> 8bit): data bit 저장 상태로 이동 
                n_state = DATA_DECISION;
        end

        DATA_DECISION: n_state = SAMPLE_CNT_RST; //3개의 sample bit 비교 후 register에 data bit 저장

        STOP_DECISION: begin //stop bit 확인 후 rx complete or error 결정
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

//Sample counter
//sample_cnt = 0 일 때 1회 sampling 
//sample_cnt = 1(sample_cnt = 0 이 끝나는 순간) 1번 check
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
    if(state == IDLE)
        shift_rst <= 1;
        catch_bit_cnt <= 0;
        catch_bit <= 0;
    else begin
        shift_rst <= 0;    
        if(state == DATA_DECISION) begin
            catch_bit_cnt <= bit_cnt;
            catch_bit <= (b0&b1) | (b0&b2) | (b1&b2); //Karnom map을 통하여 논리식 확인
        end else begin
            catch_bit_cnt <= catch_bit_cnt;
            catch_bit <= catch_bit;
        end
    end
end

assign o_rx_complete = (state == RECEIVE_COMPLETE) ? 1'b1 : 1'b0;
assign o_rx_error = (state == RECEIVE_ERROR) ? 1'b1 : 1'b0;


endmodule
