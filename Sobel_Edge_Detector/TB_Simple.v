module top_module 
#(
    parameter DATA_WIDTH    = 8,
    parameter ADDR_WIDTH    = 16,
    parameter MEM_SIZE      = 65536, // 2^16 = 4096

    parameter IMAGE_WIDTH   = 5,
    parameter IMAGE_HEIGHT  = 5 
)();

reg                       clk         ;
reg                       rst_n       ;
reg                       i_en        ;
reg [ADDR_WIDTH:0]      i_num_cnt   ;
reg                       i_run       ;

wire                      o_idle      ;
wire                      o_read      ;
wire                      o_write     ;
wire                      o_done      ;

reg                       b0_ce0      ;
reg                       b0_we0      ;
reg [DATA_WIDTH:0]      b0_d0       ;
reg [ADDR_WIDTH:0]      b0_addr0    ;

wire [DATA_WIDTH:0]     b0_q0       ;

reg                       b1_ce0      ;
reg                       b1_we0      ;
reg [DATA_WIDTH:0]      b1_d0       ;
reg [ADDR_WIDTH:0]      b1_addr0    ;

wire [DATA_WIDTH:0]     b1_q0       ;

wire [DATA_WIDTH:0]     b0_d1       ;
wire                      b0_ce1      ;
wire                      b0_we1      ;
wire [ADDR_WIDTH:0]     b0_addr1    ;
wire [DATA_WIDTH:0]     b0_q1       ;
wire [DATA_WIDTH:0]     b1_d1       ;
wire                      b1_ce1      ;
wire                      b1_we1      ;
wire [ADDR_WIDTH:0]     b1_addr1    ;
wire [DATA_WIDTH:0]     b1_q1       ;

	always #5 clk = ~clk;  // Create clock with period=10
	initial `probe_start;   // Start the timing diagram

	`probe(clk);        // Probe signal "clk"
    `probe(rst_n);
    
	// A testbench
integer i;
initial begin
    clk         = 0;
    rst_n       = 1;
    i_en        = 0;
    i_num_cnt   = 16'd25;
    i_run       = 0;    
    b0_ce0      = 0;
    b0_we0      = 0;
    b0_d0       = {DATA_WIDTH{1'b0}};
    b0_addr0    = {ADDR_WIDTH{1'b0}};
    b1_ce0      = 0;
    b1_we0      = 0;
    b1_d0       = {DATA_WIDTH{1'b0}};
    b1_addr0    = {ADDR_WIDTH{1'b0}};
    #20

    //Reset
    rst_n       = 0;
    #20

    rst_n       = 1;
    #20

    //BRAM0에 Image data 저장
    for(i = 0; i < i_num_cnt; i = i + 1) begin
        @(posedge clk)
        b0_ce0      = 1;
        b0_we0      = 1;
        b0_d0       = i+1;
        b0_addr0    = i;
    end

    //Check IDLE state
    wait(o_idle);

    //Start Image data move
    i_en = 1;
    #40

    i_en = 0;
    
    wait(o_done);
		    
    //BRAM1에 저장된 Image data 읽기
    for(i = 0; i < i_num_cnt; i = i + 1) begin
        @(posedge clk)
        b1_ce0      = 1;
        b1_we0      = 0;
        b1_addr0    = i;
    end
	/*
    #50

    //Check IDLE state
    wait(o_idle);

    //Start Image data run
    i_en = 1;
    i_run = 1;
    #10

    i_en = 0;
    wait(o_done);

    //BRAM1에 저장된 Image data 읽기
    for(i = 0; i < i_num_cnt; i = i + 1) begin
        @(posedge clk)
        b1_ce0      = 1;
        b1_we0      = 0;
        b1_addr0    = i;
    end
	*/
    #50

    $finish;
end

FSM_Module_Sobel
#(
    .DATA_WIDTH(8)      ,
    .ADDR_WIDTH(16)     ,
    .MEM_SIZE(65536)    ,
    .IMAGE_WIDTH(5)     ,
    .IMAGE_HEIGHT(5)   
)
u0(
    .clk         (clk      ),
    .rst_n       (rst_n    ),
    .i_en        (i_en     ),
    .i_num_cnt   (i_num_cnt),
    .i_run       (i_run    ),
    .b0_d1       (b0_d1    ),
    .b0_ce1      (b0_ce1   ),
    .b0_we1      (b0_we1   ),
    .b0_addr1    (b0_addr1 ),
    .b0_q1       (b0_q1    ),
    .b1_d1       (b1_d1    ),
    .b1_ce1      (b1_ce1   ),
    .b1_we1      (b1_we1   ),
    .b1_addr1    (b1_addr1 ),
    .b1_q1       (b1_q1    ),
    .o_idle      (o_idle   ),
    .o_read      (o_read   ),
    .o_write     (o_write  ),
    .o_done      (o_done   ) 
);

DPBRAM_Test
#(
    .DATA_WIDTH(8)      ,
    .ADDR_WIDTH(16)     ,
    .MEM_SIZE(65536)     
)
b0(
    .clk     (clk  ),
    .addr0   (b0_addr0),
    .ce0     (b0_ce0  ),
    .we0     (b0_we0  ),
    .d0      (b0_d0   ),
    .q0      (b0_q0   ),
    .addr1   (b0_addr1),
    .ce1     (b0_ce1  ),
    .we1     (b0_we1  ),
    .d1      (b0_d1   ),
    .q1      (b0_q1   ) 
);

DPBRAM_Test
#(
    .DATA_WIDTH(8)      ,
    .ADDR_WIDTH(16)     ,
    .MEM_SIZE(65536)     
)
b1(
    .clk     (clk  ),
    .addr0   (b1_addr0),
    .ce0     (b1_ce0  ),
    .we0     (b1_we0  ),
    .d0      (b1_d0   ),
    .q0      (b1_q0   ),
    .addr1   (b1_addr1),
    .ce1     (b1_ce1  ),
    .we1     (b1_we1  ),
    .d1      (b1_d1   ),
    .q1      (b1_q1   ) 
);

endmodule


module DPBRAM_Test
#(
    parameter DATA_WIDTH    = 8,
    parameter ADDR_WIDTH    = 16,
    parameter MEM_SIZE      = 65536 //2^16
)
(
    clk     ,
    //address, chip enable, write eanble, input data, output data
    addr0   ,
    ce0     , 
    we0     , 
    d0      , 
    q0      ,
    // dual port
    addr1   , 
    ce1     , 
    we1     , 
    d1      , 
    q1       
);
    
input                   clk;
input                   ce0, we0, ce1, we1;
input [ADDR_WIDTH-1:0]  addr0, addr1;
input [DATA_WIDTH-1:0]  d0, d1;

output reg [DATA_WIDTH-1:0] q0, q1;

reg [DATA_WIDTH-1:0] ram [MEM_SIZE-1:0];

always @(posedge clk) begin
    if(ce0) begin
        if(we0)
            ram[addr0] <= d0;
        else //chip enable일 경우 write enable = 0 일 때 자동으로 Read
            q0 <= ram[addr0];
    end
end

always @(posedge clk) begin
    if(ce1) begin
        if(we1)
            ram[addr1] <= d1;
        else
            q1 <= ram[addr1];
    end
end

endmodule














module FSM_Module_Sobel
#(
    parameter DATA_WIDTH    = 8,
    parameter ADDR_WIDTH    = 16,
    parameter MEM_SIZE      = 65536, //2^16

    parameter IMAGE_WIDTH   = 5,
    parameter IMAGE_HEIGHT  = 5
)
(
    clk         ,
    rst_n       ,
    i_en        ,
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
    o_idle      ,
    o_read      ,
    o_write     ,
    o_done       
);
    
    `probe(state_read);
    `probe(addr_cnt_read);
    `probe(b0_q1);
    `probe(o_read);
    `probe(valid_read);
    `probe(move_core_delay[0]);
    `probe(move_core_delay[1]);
    `probe(move_core_delay[2]);
    `probe(move_core_delay[3]);
    `probe(move_core_delay[4]);
	`probe(move_core_delay[5]);
    `probe(b1_d1);
    `probe(move_data[0]);
    `probe(move_data[1]);
    `probe(move_data[2]);
    `probe(move_data[3]);
    `probe(move_data[4]);
    `probe(move_data[5]);

input                       clk         ;
input                       rst_n       ;
input                       i_en  ; //BRAM0에 1frame data 저장 완료
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
            if(i_en) begin
                if(i_run)
                    n_state_read = RUN;
                else
                    n_state_read = MOVE;
            end else
                n_state_read = IDLE;
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
            if(i_en) begin
                if(i_run)
                    n_state_write = RUN;
                else
                    n_state_write = MOVE;
            end else
                n_state_write = IDLE;
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
    else if(col_cnt == 2'd2) //3행씩 접근
        col_cnt <= 0;
    else if(n_state_read == RUN)
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
    if(!rst_n) begin
        addr_cnt_write <= 0;
        addr_cnt_write_run <= 0;
    end else if(state_write == DONE) begin
        addr_cnt_write <= 0;
        addr_cnt_write_run <= 0;
    end else if((state_write == MOVE) && b1_we1)
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
    else if(i_en)
        num_cnt <= i_num_cnt;
    else
        num_cnt <= num_cnt;
end

//Output Logic
assign read_done = (addr_cnt_read == num_cnt-1) && o_read;// o_read   = (state_read == MOVE) || (state_read == RUN)
assign write_done = (addr_cnt_write == num_cnt-1) && o_write; // o_write  = (state_write == MOVE) || (state_write == RUN)

assign o_idle   = (state_read == IDLE) && (state_write == IDLE);
assign o_read   = (state_read == MOVE) || (state_read == RUN);
assign o_write  = (state_write == MOVE) || (state_write == RUN);
assign o_done   = state_write == DONE;

//BRAM0 Output Logic
assign b0_d1       = {DATA_WIDTH{1'b1}}; // No use
assign b0_ce1      = o_read; // o_read   = (state_read == MOVE) || (state_read == RUN)
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
    if(!rst_n) begin
        move_core_delay <= 0;
        run_core_delay <= 0;
    end else if(valid_read) begin
        move_core_delay <= {move_core_delay[4:0], valid_read};
        run_core_delay <= {run_core_delay[4:0], valid_read};
    end else begin
        move_core_delay <= {move_core_delay[4:0], 1'b0};
        run_core_delay <= {run_core_delay[4:0], 1'b0};
    end
end

//Read data capture
//(MOVE) - BRAM0에서 read한 data를 shift register에 capture (0cycle)
//(RUN) - BRAM0에서 read한 data(data1, data2, data3)를 shift register[0],[1],[2](3*4행렬의 4열)에 capture (0~2cycle)
reg [DATA_WIDTH-1:0] move_data [5:0];
reg [DATA_WIDTH-1:0] run_data [11:0];

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        move_data[0] <= {DATA_WIDTH{1'b0}};
        run_data[0] <= {DATA_WIDTH{1'b0}};
        run_data[1] <= {DATA_WIDTH{1'b0}};
        run_data[2] <= {DATA_WIDTH{1'b0}};
    end else if(valid_read) begin
            move_data[0] <= b0_q1;
		    run_data[0] <= b0_q1; // read data
            run_data[1] <= run_data[0];
            run_data[2] <= run_data[1];
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
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n)
                move_data[idx_move + 1] <= {DATA_WIDTH{1'b0}};
            else if(|move_core_delay)
                move_data[idx_move + 1] <= move_data[idx_move];
            else;
        end
    end
endgenerate

generate
    for (idx_run = 0; idx_run < 3; idx_run = idx_run + 1) begin : gen_run_delay
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                run_data[idx_run + 3] <= {DATA_WIDTH{1'b0}}; //3열
                run_data[idx_run + 6] <= {DATA_WIDTH{1'b0}}; //2열
                run_data[idx_run + 9] <= {DATA_WIDTH{1'b0}}; //1열
            end else if(run_core_delay[3]) begin //001111(4cycle)
                if(state_read == RUN) begin
                run_data[idx_run + 3] <= run_data[idx_run];
                run_data[idx_run + 6] <= run_data[idx_run + 3];
                run_data[idx_run + 9] <= run_data[idx_run + 6];
                end else;
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

Sobel_Mask u0(
    .p0      (p0     ),
    .p1      (p1     ),
    .p2      (p2     ),
    .p3      (p3     ),
    .p5      (p5     ),
    .p6      (p6     ),
    .p7      (p7     ),
    .p8      (p8     ),
    .o_sobel (o_sobel) 
);
endmodule

















module Sobel_Mask
(
    p0      , 
    p1      , 
    p2      , 
    p3      , 
    p5      , 
    p6      , 
    p7      , 
    p8      ,
    o_sobel  
);

input  [7:0]        p0, p1, p2, p3, p5, p6, p7, p8; //8개(3*3행렬)의 input pixels (8bit - 각 픽셀마다 0 ~ 256 value 값을 갖음)
output [7:0]        o_sobel; // 8개의 input pixels에 sobel mask를 적용하여 나온 결과값 (8bit - 0 ~ 256 value 값을 갖음)

wire signed [10:0] x_sum, y_sum; //sobel mask 적용 후 최대 11bit 값을 갖음 - 8bit*4(8bit + 2*8bit + 8bit) + 1bit(signed/unsigned bit)
wire [10:0] abs_x_sum, abs_y_sum; //Abosulte value 값을 찾기 위해 사용
wire [10:0] total_sum; // x_sum + y_sum (절대치이기 때문에 unsigned - 8bit*4 + 8bit*4)

assign x_sum = ((p2-p0) + 2*(p5-p3) + (p8-p6)); //x축 mask
assign y_sum = ((p0-p6) + 2*(p1-p7) + (p2-p8)); //y축 mask

assign abs_x_sum = (x_sum[10] ? ~x_sum+1 : x_sum);
assign abs_y_sum = (y_sum[10] ? ~y_sum+1 : y_sum);

assign total_sum = (abs_x_sum + abs_y_sum);
assign o_sobel = (|total_sum[10:8] ? 8'hff : total_sum[7:0]); //8~10번째 bit중 하나라도 1이면 255(pixel의 최대값은 255)

endmodule
