module FSM_Module_Sobel
#(
    parameter DATA_WIDTH    = 8,
    parameter ADDR_WIDTH    = 12,
    parameter MEM_SIZE      = 4096 // 2^12 = 4096

    parameter IMAGE_WIDTH   = 279,
    parameter IMAGE_HEIGHT  = 210,

    parameter IMAGE_SIZE    = 279*210,
    parameter R_IMAGE_SIZE  = 277 * 208 //resized image after sobel filter
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
input                       i_num_cnt   ; //BRAM0에 저장 되어 있는 1frame data의 Address Width
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
    case (state)
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
    case (state)
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

//Sobel Mask 적용을 위해 3*3 행렬의 행 순으로 data의 address 값에 접근하여 read
reg [1:0] col_cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        col_cnt <= 0;
    else if(matrix_cnt == 2'd4) // 3clock(3*3행렬의 3열 3개의 data 접근 시간) + 2clock(임의로 설정) = 5clock(sobel filter total 계산 시간) -> Data를 Read하는데 소요하는 총 시간
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
            addr_cnt_read <= addr_cnt_read + IMAGE_WIDTH; // Current Address 값은 3*3 행렬 중 (1,1) address, Next address 값은 3*3 행렬 중 (2,1) address
        else if(col_cnt == 1)
            addr_cnt_read <= addr_cnt_read + 2*IMAGE_WIDTH; // Current Address 값은 3*3 행렬 중 (2,1) address, Next address 값은 3*3 행렬 중 (3,1) address
        else if(col_cnt == 2)
            addr_cnt_read <= addr_cnt_read; // Current Address 값은 3*3 행렬 중 (3,1) address, Next address 값은 3*3 행렬 중 (3,1) address
        else if(col_cnt == 3)
            addr_cnt_read <= addr_cnt_read; // Current Address 값은 3*3 행렬 중 (3,1) address, Next address 값은 3*3 행렬 중 (3,1) address
        else // col_cnt == 4
            addr_cnt_read <= addr_cnt_read - 2*IMAGE_WIDTH + 1; // Current Address 값은 3*3 행렬 중 (3,1) address, Next address 값은 3*3 행렬 중 (1,2) address
    end else
        addr_cnt_read <= addr_cnt_read;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        addr_cnt_write <= 0;
    else if(state_write == DONE)
        addr_cnt_write <= 0;
    else if(state_write == MOVE)
        addr_cnt_write <= addr_cnt_write + 1;
    else if((state_write == RUN) && b1_we1)
        addr_cnt_write <= addr_cnt_write + 1;
    else
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

//BRAM0에서 3*4행렬 4열의 3개 data를 read하여 저장하는 단계
reg [DATA_WIDTH-1:0] matrix_data [11:0];

integer i;
always @(posedge clk or negedge reset_n) begin
    if(!rst_n) begin
        matrix_data[0] <= {DATA_WIDTH{1'b0}};
        matrix_data[1] <= {DATA_WIDTH{1'b0}};
        matrix_data[2] <= {DATA_WIDTH{1'b0}};
    end else if(valid_read) begin
        for(i = 0; i < 3; i = i + 1)
		    matrix_data[i] <= b0_q1; // read data
	end
end

//BRAM0에서 3*4행렬 4열의 3개 data를 read하여 저장하기 위해 5clock 지연 시간 필요
reg [4:0] proc_delay;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        proc_delay <= 0;
    else if(proc_delay[4])
        proc_delay <= {4'b0, valid_read};
    else
        proc_delay <= {proc_delay[3:0], valid_read};
end

//5clock 이후 data shift (다음 data가 read 되기 전까지) -> proc_delay[4] = 1 일 때 4열->3열, 3열->2열, 2열->1열
genvar  idx;
generate
    for (idx = 0; idx < 3; idx = idx + 1) begin :
        always @(posedge clk or negedge reset_n) begin
            if(!rst_n)
                matrix_data[idx + 3] <= {DATA_WIDTH{1'b0}};
                matrix_data[idx + 6] <= {DATA_WIDTH{1'b0}};
                matrix_data[idx + 9] <= {DATA_WIDTH{1'b0}};
            else if(proc_delay[4])
                matrix_data[idx + 3] <= matrix_data[idx];
                matrix_data[idx + 6] <= matrix_data[idx + 3];
                matrix_data[idx + 9] <= matrix_data[idx + 6];
            else;
        end
    end
endgenerate

//5clock 동안 Sobel mask 계산 (다음 data가 shift 되기 전까지) -> proc_delay[4] = 1 일 때 o_sobel 캡처
reg [7:0] result;
wire [7:0] o_sobel

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        result <= 0;
    else if(proc_delay[4])
        result <= o_sobel;
    else
        result <= result;
end


//Write 동작은 3번째 Cycle(Read, Calculation)부터 동작해야 하므로 지연 시간 필요
reg [5:0] init_delay;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        init_delay <= 0;
    else if(proc_delay[4])
        init_delay <= {init_delay[4:0], proc_delay[4]};
    else
        init_delay <= init_delay;
end


assign b1_d1 = result;
assign b1_ce1 = proc_delay[2] && init_delay[5];
assign b1_we1 = proc_delay[2] && init_delay[5];
assign b1_addr1 = addr_cnt_write;














//////////////////////////////////////////////////////////////////////////////////////////////////
//store address count data (image size) at F/F
reg [CNT_BIT-1:0] num_cnt;
reg [CNT_BIT-1:0] r_num_cnt;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        num_cnt <= 0;
        r_num_cnt <= 0;
    end else if(i_run) begin
        num_cnt <= i_num_cnt;
        r_num_cnt <= r_i_num_cnt;
    end else if (o_done) begin
        num_cnt <= 0;
        r_num_cnt <= 0;
    end
end

reg [CNT_BIT-1:0] addr_cnt_read;
reg [CNT_BIT-1:0] addr_cnt_write;
assign is_done_read = o_read && (addr_cnt_read == num_cnt-1);
assign is_done_write = o_write && (addr_cnt_write == r_num_cnt-1);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        addr_cnt_read <= 0;
    end else if(is_done_read) begin
        addr_cnt_read <= 0;
    end else if(o_read) begin
        addr_cnt_read <= addr_cnt_read + 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        addr_cnt_write <= 0;
    end else if(is_done_write) begin
        addr_cnt_write <= 0;
    end else if(o_write && we_b1) begin
        addr_cnt_write <= addr_cnt_write + 1;
    end
end

assign addr_b0 = addr_cnt_read;
assign ce_b0 = o_read;
assign we_b0 = 1'b0;
assign d_b0 = {DATA_WIDTH{1'b0}};

// 1 cycle delay o_read signal for using data from bram
reg d_o_read;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        d_o_read <= 0;  
    end else begin
        d_o_read <= o_read;
    end
end

//Count image width & height of image
reg [31:0] cnt_image_w;
reg [31:0] cnt_image_h;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_image_w <= 31'b0;
        cnt_image_h <= 31'b0;
    end else if (d_o_read && (cnt_image_w == IMAGE_W-1) && (cnt_image_h == IMAGE_H-1)) begin
        cnt_image_h <= 31'b0;
        cnt_image_w <= 31'b0;
    end else if (d_o_read && (cnt_image_w == IMAGE_W-1)) begin
        cnt_image_w <= 31'b0;
        cnt_image_h <= cnt_image_h + 1;
    end else if (d_o_read) begin
        cnt_image_w <= cnt_image_w + 1;
    end
end

// Store image pixel data at 3 row for applying sobel filter
reg [7:0] r1 [0:IMAGE_W-1];
reg [7:0] r2 [0:IMAGE_W-1];
reg [7:0] r3 [0:IMAGE_W-1];
integer i;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<IMAGE_W; i=i+1) begin
            r1[i] <= 8'b0;
            r2[i] <= 8'b0;
            r3[i] <= 8'b0;
        end
    end else if(d_o_read) begin
        r1[cnt_image_w] <= r2[cnt_image_w];        
        r2[cnt_image_w] <= r3[cnt_image_w];
        r3[cnt_image_w] <= q_b0;
    end
end

// 1 cycle delay image address count for data stored at r1,r2,r3
reg [31:0] d_cnt_image_w;
reg [31:0] d_cnt_image_h;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        d_cnt_image_w <= 32'b0;
        d_cnt_image_h <= 32'b0;          
    end else begin
        d_cnt_image_w <= cnt_image_w;
        d_cnt_image_h <= cnt_image_h;
    end
end

// 8 pixel start to be applied for sobel filter when third row and coloum data is stored at r1,r2,r3
reg [7:0] p0, p1, p2, p3, p5, p6, p7, p8;
reg result_valid;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        result_valid = 0;
        p0 <= 0;
        p1 <= 0;
        p2 <= 0;
        p3 <= 0;
        p5 <= 0;
        p6 <= 0;
        p7 <= 0;
        p8 <= 0;
    end else if((d_cnt_image_w >= 2) && (d_cnt_image_h >= 2)) begin
        result_valid = 1;
        p0 <= r1[d_cnt_image_w-2];
        p1 <= r1[d_cnt_image_w-1];
        p2 <= r1[d_cnt_image_w];
        p3 <= r2[d_cnt_image_w-2];
        p5 <= r2[d_cnt_image_w];
        p6 <= r3[d_cnt_image_w-2];
        p7 <= r3[d_cnt_image_w-1];
        p8 <= r3[d_cnt_image_w];
    end else begin
        result_valid = 0;
        p0 <= 0;
        p1 <= 0;
        p2 <= 0;
        p3 <= 0;
        p5 <= 0;
        p6 <= 0;
        p7 <= 0;
        p8 <= 0;        
    end
end

wire [7:0] result_sobel;

sobel_filter
#(
)
u_sobel_filter(
    .p0(p0),
    .p1(p1),
    .p2(p2),
    .p3(p3),
    .p5(p5),
    .p6(p6),
    .p7(p7),
    .p8(p8),
    .o_sobel(result_sobel)
);

assign addr_b1 = addr_cnt_write;
assign ce_b1 = result_valid;
assign we_b1 = result_valid;
assign d_b1 = result_sobel;

endmodule
