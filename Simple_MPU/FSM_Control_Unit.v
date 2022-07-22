//작성자: 이광일
//설계명: Simple MPU
//설계 목표: 기존에 설계했던 UART Rx/Tx, ALU를 이용하여 간단한 Microprocessor 설계
//참고: PC에서부터 데이터를 UART Rx 통해 받아 ALU 연산 이후 UART Tx를 통해 PC로 전송

module FSM_Control_Unit(
    clk         ,
    rst_n       ,
    rx_data     ,
    rx_complete ,
    rx_error    ,
    alu_result  ,
    txd         ,
    tx_en       ,
    a_reg       ,
    b_reg       ,
    f_reg        
);

input               clk         ;
input               rst_n       ;
input [7:0]         rx_data     ;
input               rx_complete ;
input               rx_error    ;
input [7:0]         alu_result  ;

output reg [7:0]    txd         ;
output reg          tx_en       ;
output reg [7:0]    a_reg       ;
output reg [7:0]    b_reg       ;
output reg [3:0]    f_reg       ;

//State parameter
localparam IDLE     = 3'b000;
localparam OPERAND1 = 3'b001;
localparam OPERAND2 = 3'b010;
localparam OPCODE   = 3'b011;
localparam EXE      = 3'b100;
localparam RETURN   = 3'b101;

//State Regsiter
reg [2:0] state, n_state;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        state <= IDLE;
    else
        state <= n_state;
end

//State Logic
always @(state or rx_complete) begin
    case(state)
        IDLE     : begin
            if(rx_complete)
                n_state = OPERAND1;
            else
                n_state = IDLE;
        end

        OPERAND1 : begin
            if(rx_complete)
                n_state = OPERAND2;
            else
                n_state = OPERAND1;
        end

        OPERAND2 : begin
            if(rx_complete)
                n_state = OPCODE;
            else
                n_state = OPERAND2;
        end

        OPCODE   : n_state = EXE;

        EXE      : n_state = RETURN;

        RETURN   : n_state = IDLE

        default  : n_state = IDLE;

    endcase
end

//Output state
always @(state) begin
    case(state)
        IDLE     : begin
            txd         = 8'b0000_0000;
            tx_en       = 1'b0;
            a_reg       = 8'b0000_0000;
            b_reg       = 8'b0000_0000;
            f_reg       = 4'b0000;
        end

        OPERAND1 : a_reg = rx_data;

        OPERAND2 : b_reg = rx_data;

        OPCODE   : f_reg = rx_data[3:0];

        EXE      : txd = alu_result;

        RETURN   : tx_en = 1

        default  : begin
            txd         = 8'b0000_0000;
            tx_en       = 1'b0;
            a_reg       = 8'b0000_0000;
            b_reg       = 8'b0000_0000;
            f_reg       = 4'b0000;
        end

    endcase
end

endmodule
