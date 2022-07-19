module FSM_Module_SW
#(
    //Output parameter - 전역 Parameter로 외부 변경(o)
    parameter ENABLE     = 2'b00;
    parameter DISABLE    = 2'b01;
    parameter RESET      = 2'b10;  
)
(
    clk             ,
    rst_n           ,
    i_start_pause   ,
    i_stop          ,
    cnt_ctrl                      
);

input               clk             ;
input               rst_n           ;
input               i_start_pause   ;
input               i_stop          ;

output reg [1:0]    cnt_ctrl        ; //Output을 통해 Counter 동작 여부 결정

reg [1:0] state, n_state;

//State parameter 지역 parameter로 외부 변경(x)
localparam IDLE   = 2'b00;
localparam COUNT  = 2'b01;
localparam PAUSE  = 2'b10;

//State register(DFF)
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        state <= IDLE;
    end else
        state <= n_state;
end

//State logic
always @(state or i_start_pause or i_stop) begin
    case(state)
        IDLE:
            if(i_start_pause)
                n_state = COUNT;
            else
                n_state = IDLE;

        COUNT:
            if(i_start_pause)
                n_state = PAUSE;
            else if(i_stop)
                n_state = IDLE;
            else
                n_state = COUNT;

        PAUSE:
            if(i_start_pause)
                n_state <= COUNT;
            else if(i_stop)
                n_state <= IDLE;
            else
                n_state = PAUSE;

        default: n_state = IDLE;

    endcase
end

//Output logic
always @(state) begin
    case(state)
        IDLE: cnt_ctrl = RESET;

        COUNT: cnt_ctrl = ENABLE;

        RESET: cnt_ctrl = DISABLE;

        default : cnt_ctrl = RESET

    endcase
end

endmodule
