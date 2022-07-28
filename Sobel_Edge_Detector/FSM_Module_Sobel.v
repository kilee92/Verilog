module FSM_Module_Sobel
#(
    parameter DATA_WIDTH    = 8,
    parameter ADDR_WIDTH    = 12,
    parameter MEM_SIZE      = 4096 // 2^12 = 4096

    parameter IMAGE_WIDTH   = 100,
    parameter IMAGE_HEIGHT  = 100,
)
(
    clk         ,
    rst_n       ,
    i_complete  ,
    i_num_cnt   ,
    i_run       ,
    b0_d1       ,
    b0_ce1      ,
    b0_we1      ,
    b0_addr1    ,
    b0_q1       ,
    b1_d1       ,
    b1_ce1      ,
    b1_we1      ,
    b1_addr1    ,
    b1_q1       ,
    o_state      
);

input                       clk         ;
input                       rst_n       ;
input                       i_complete  ; //BRAM0에 1frame data 저장 완료
input [ADDR_WIDTH-1:0]      i_num_cnt   ; //BRAM0에 저장 되어 있는 1frame data의 Address Width
input                       i_run       ; //Sobel Filter 적용

output [DATA_WIDTH-1:0]     b0_d1       ; //No use
output                      b0_ce1      ;
output                      b0_we1      ;
output [ADDR_WIDTH-1:0]     b0_addr1    ;

input [DATA_WIDTH-1:0]      b0_q1       ;

output [DATA_WIDTH-1:0]     b1_d1       ;
output                      b1_ce1      ;
output                      b1_we1      ;
output [ADDR_WIDTH-1:0]     b1_addr1    ;

input [DATA_WIDTH-1:0]      b1_q1       ; //No use

output                      o_idle      ;
output                      o_read      ;
output                      o_write     ;
output                      o_done      ;

//Pipeline 적용을 위해 2가지(Read/Write) FSM 사용
reg [1:0] state_read, n_state_read;
reg [1:0] state_write, n_state_write;

//State Parameter
localparam IDLE     = 2'b00;
localparam MOVE     = 2'b01; //Sobel Mask 적용 안하여 데이터 이동(단순 데이터 이동)
localparam RUN      = 2'b10; //Sobel Mask 적용 하여 데이터 이동
localparam DONE     = 2'b11;

//State Register
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_read <= IDLE;
    end else begin
        state_read <= n_state_read;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_write <= IDLE;
    end else begin
        state_write <= n_state_write;
    end
end

//State Logic
wire read_done;
wire write_done;

always @(*) begin
    case (state_read)
        IDLE: begin 
            if(i_complete) begin
                if(i_run)
                    n_state_read = RUN;
                else
                    n_state_read = MOVE;
            end else
                n_state = IDLE;
        end

        MOVE: begin
            if(read_done)
                n_state_read = DONE;
            else   
                n_state_read = MOVE;
        end
                
        RUN: begin
            if(read_done)
                n_state_read = DONE;
            else   
                n_state_read = RUN;
        end

        DONE: n_state_read = IDLE;

        default: n_state_read = IDLE;
    endcase
end

always @(*) begin
    case (state_write)
        IDLE: begin 
            if(i_complete) begin
                if(i_run)
                    n_state_write = RUN;
                else
                    n_state_write = MOVE;
            end else
                n_state = IDLE;
        end

        MOVE: begin
            if(write_done)
                n_state_write = DONE;
            else   
                n_state_write = MOVE;
        end
                
        RUN: begin
            if(write_done)
                n_state_write = DONE;
            else   
                n_state_write = RUN;
        end

        DONE: n_state_write = IDLE;

        default: n_state_write = IDLE;
    endcase
end

//Address Counter
reg [ADDR_WIDTH-1:0] addr_cnt_read;
reg [ADDR_WIDTH-1:0] addr_cnt_write;
reg [ADDR_WIDTH-1:0] addr_cnt_write_run;

//Sobel Mask 적용을 위해 3*3 행렬의 행 순으로 data address 값에 접근하여 read
reg [1:0] col_cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        col_cnt <= 0;
    else if(matrix_cnt == 2'd2) // 3clock(3*3행렬의 3열 3개의 data 접근 시간) + 2clock(임의로 설정) = 5clock(Data를 Read하는데 소요하는 총 시간) -> Pipeline 적용을 위해 Sobel mask 계산 시간(5clock - 임의로 설정)과 동일하게 맞춤
        col_cnt <= 0;
    else if(state == RUN)
        col_cnt <= col_cnt + 1;
    else
        col_cnt <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        addr_cnt_read <= 0;
    else if(state_read == DONE)
        addr_cnt_read <= 0;
    else if(state_read == MOVE)
        addr_cnt_read <= addr_cnt_read + 1;
    else if(state_read == RUN) begin
        if(col_cnt == 0)
            addr_cnt_read <= addr_cnt_read + IMAGE_WIDTH; // Current Address 값은 3*3 행렬 중 (1,1) address, Next address 값은 3*3 행렬 중 (1,1) address
        else if(col_cnt == 1)
            addr_cnt_read <= addr_cnt_read + 2*IMAGE_WIDTH; // Current Address 값은 3*3 행렬 중 (1,1) address, Next address 값은 3*3 행렬 중 (1,1) address
        else // col_cnt == 2
            addr_cnt_read <= addr_cnt_read - 2*IMAGE_WIDTH + 1; // Current Address 값은 3*3 행렬 중 (3,1) address, Next address 값은 3*3 행렬 중 (1,2) address
    end else
        addr_cnt_read <= addr_cnt_read;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        addr_cnt_write <= 0;
        addr_cnt_write_run <= 0;
    else if(state_write == DONE)
        addr_cnt_write <= 0;
        addr_cnt_write_run <= 0;
    else if((state_write == MOVE) && b1_we1)
        addr_cnt_write <= addr_cnt_write + 1;
    else if((state_write == RUN) && b1_we1) begin //Sobel mask 적용시 매 IMAGE_WIDTH 마다 첫 2번의 b1_d1 data는 유효하지 않음 (3*3행열의 2,3열 data만 채워져 있음)
        addr_cnt_write_run <= addr_cnt_write_run + 1;
            if(addr_cnt_write_run % IMAGE_WIDTH == 0)
                addr_cnt_write <= addr_cnt_write;
            else if(addr_cnt_write_run % IMAGE_WIDTH == 1)
                addr_cnt_write <= addr_cnt_write;
            else
                addr_cnt_write <= addr_cnt_write + 1;
    end else
        addr_cnt_write <= addr_cnt_write;
end

//Registering(Capture) count number
reg [ADDR_WIDTH-1:0] num_cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        num_cnt <= 0;
    else if(i_complete)
        num_cnt <= i_num_cnt;
    else
        num_cnt <= num_cnt;
end

//Output Logic
assign read_done = (addr_cnt_read == num_cnt) && o_read// o_read   = (state_read == MOVE) || (state_read == RUN)
assign write_done = (addr_cnt_write == num_cnt) && o_write // o_write  = (state_write == MOVE) || (state_write == RUN)

assign o_idle   = (state_read == IDLE) && (state_write == IDLE);
assign o_read   = (state_read == MOVE) || (state_read == RUN);
assign o_write  = (state_write == MOVE) || (state_write == RUN);
assign o_done   = (state_read == DONE) && (state_write == DONE);

//BRAM0 Output Logic
assign b0_d1       = {DATA_WIDTH{1'b}}; // No use
assign b0_ce1      = o_read // o_read   = (state_read == MOVE) || (state_read == RUN)
assign b0_we1      = 1'b0; //FSM은 BRAM0로 부터 읽기(Read)만 사용
assign b0_addr1    = addr_cnt_read;

//BRAM1 Output Logic

//BRAM0에서 Read한 Data(b0_q1)는 1cycle 뒤에 나오므로 o_read보다 1clock 지연된 시점의 값을 얻어야함
reg valid_read;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        valid_read <= 0;
    else
        valid_read <= o_read;
end

//(MOVE) - BRAM에서 data caputre -> shift*4(delay) -> write (total 6cycle) (RUN시간과 동일하게 맞추기 위해)
//(RUN) - BRAM0에서 data1 caputre -> data2 caputre -> data3 caputre -> data1, data2, data3 shift(delay) -> ALU -> write (total 6cycle)
reg [5:0] move_core_delay;
reg [5:0] run_core_delay; 

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        move_core_delay <= 0;
        run_core_delay <= 0;
    else if(state == MOVE)
        move_core_delay <= {move_core_delay[4:0], valid_read};
    else if(state == RUN)
        run_core_delay <= {run_core_delay[4:0], valid_read};
    else begin
        move_core_delay <= {move_core_delay[4:0], 0};
        run_core_delay <= {move_core_delay[4:0], 0};
    end
end

//Read data capture
//(MOVE) - BRAM0에서 read한 data를 shift register에 capture (1cycle)
//(RUN) - BRAM0에서 read한 data(data1, data2, data3)를 shift register[0],[1],[2](3*4행렬의 4열)에 capture (1~3cycle)
reg [DATA_WIDTH-1:0] move_data [5:0];
reg [DATA_WIDTH-1:0] run_data [11:0];

always @(posedge clk or negedge reset_n) begin
    if(!rst_n) begin
        move_data[0] <= {DATA_WIDTH{1'b0}};
        run_data[0] <= {DATA_WIDTH{1'b0}};
        run_data[1] <= {DATA_WIDTH{1'b0}};
        run_data[2] <= {DATA_WIDTH{1'b0}};
    end else if(valid_read) begin
        if(state_read == MOVE)
            move_data[0] <= b0_q1;
        else if(state_read == RUN) begin
		    run_data[0] <= b0_q1; // read data
            run_data[1] <= run_data[0];
            run_data[2] <= run_data[1];
        end else;
    end else begin
        move_data[0] <= {DATA_WIDTH{1'b0}};
        run_data[0] <= {DATA_WIDTH{1'b0}};
        run_data[1] <= {DATA_WIDTH{1'b0}};
        run_data[2] <= {DATA_WIDTH{1'b0}};
    end
end

//Capture data shift
//(MOVE) data shift (2~5cycle)
//(RUN) 행열(4열->3열, 3열->2열, 2열->1열) shift (4cycle)
genvar idx_move;
genvar idx_run;

generate
    for (idx_move = 0; idx_move < 5; idx_move = idx_move + 1) begin : gen_move_delay
        always @(posedge clk or negedge reset_n) begin
            if(!rst_n)
                move_data[idx_move + 1] <= {DATA_WIDTH{1'b0}};
            else if(|move_core_delay)
                move_data[idx_move + 1] <= move_data[idx_move]
            else;
        end
    end
endgenerate

generate
    for (idx_run = 0; idx_run < 3; idx_run = idx_run + 1) begin : gen_run_delay
        always @(posedge clk or negedge reset_n) begin
            if(!rst_n) begin
                run_data[idx_run + 3] <= {DATA_WIDTH{1'b0}}; //3열
                run_data[idx_run + 6] <= {DATA_WIDTH{1'b0}}; //2열
                run_data[idx_run + 9] <= {DATA_WIDTH{1'b0}}; //1열
            end else if(core_delay[3]) begin //001111(4cycle)
                if(state_read == RUN)
                run_data[idx_run + 3] <= matrix_data[idx_run];
                run_data[idx_run + 6] <= matrix_data[idx_run + 3];
                run_data[idx_run + 9] <= matrix_data[idx_run + 6];
            end else;
        end
    end
endgenerate

//Shift 된 행열의 ALU
//(RUN) 행열 shift 이후 4열을 제외한 3*3 행열 sobel mask 계산 (5cycle)
wire [7:0] p0, p1, p2, p3, p4, p5, p6, p7, p8;
wire [7:0] o_sobel;

assign p0 = run_data[9];
assign p1 = run_data[6];
assign p2 = run_data[3];
assign p3 = run_data[10];
assign p4 = run_data[7];
assign p5 = run_data[4];
assign p6 = run_data[11];
assign p7 = run_data[8];
assign p8 = run_data[2];

//최종 data Write
//(MOVE) 6cycle
//(RUN) 6cycle
assign b1_addr1 = addr_cnt_write;
assign b1_ce1 = move_core_delay[5] || run_core_delay[5];
assign b1_we1 = move_core_delay[5] || run_core_delay[5];
assign b1_d1 = move_core_delay[5]*move_data[5] + run_core_delay[5]*o_sobel;

// IMAGE의 Edge 부분 축소 IMAGE의 SIZE는 (IMGAE_WIDTH - 2) * (IMAGE_HEIGHT - 2)
endmodule
