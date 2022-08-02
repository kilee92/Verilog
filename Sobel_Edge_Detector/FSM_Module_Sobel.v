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
output reg [ADDR_WIDTH-1:0] b1_addr1    ;

input [DATA_WIDTH-1:0]      b1_q1       ; //No use

output                      o_idle      ;
output                      o_read      ;
output                      o_write     ;
output                      o_done      ;

//Pipeline 적용을 위해 2가지(Read/Write) FSM 사용
reg [2:0] state_read, n_state_read;
reg [2:0] state_write, n_state_write;

//State Parameter
localparam IDLE             = 3'b000;
localparam MOVE             = 3'b001; //Sobel Mask 적용 안하여 데이터 이동(단순 데이터 이동)
localparam MOVE_DONE        = 3'b010;
localparam SOBEL            = 3'b011; //Sobel Mask 적용 하여 데이터 이동
localparam SOBEL_CNT_RST    = 3'b100;
localparam SOBEL_RESIZE     = 3'b101;
localparam SOBEL_DONE       = 3'b110;

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
wire sobel_done;

    always @(*) begin
    case (state_read)
        IDLE: begin 
            if(i_en) begin
                if(i_run)
                    n_state_read = SOBEL;
                else
                    n_state_read = MOVE;
            end else
                n_state_read = IDLE;
        end

        MOVE: begin
            if(read_done)
                n_state_read = MOVE_DONE;
            else   
                n_state_read = MOVE;
        end
                
        SOBEL: begin
            if(read_done)
                n_state_read = SOBEL_DONE;
            else   
                n_state_read = SOBEL;
        end

        MOVE_DONE: n_state_read = IDLE;
        SOBEL_DONE: n_state_read = IDLE;

        default: n_state_read = IDLE;
        
    endcase
end

always @(*) begin
    case (state_write)
        IDLE: begin 
            if(i_en) begin
                if(i_run)
                    n_state_write = SOBEL;
                else
                    n_state_write = MOVE;
            end else
                n_state_write = IDLE;
        end

        MOVE: begin
            if(write_done)
                n_state_write = MOVE_DONE;
            else   
                n_state_write = MOVE;
        end
                
        SOBEL: begin
            if(sobel_done)
                n_state_write = SOBEL_CNT_RST;
            else   
                n_state_write = SOBEL;
        end

        SOBEL_CNT_RST: 
            n_state_write = SOBEL_RESIZE;

        SOBEL_RESIZE: begin
            if(write_done)
                n_state_write = SOBEL_DONE;
            else   
                n_state_write = SOBEL_RESIZE;
        end        

        MOVE_DONE: n_state_write = IDLE;
        SOBEL_DONE: n_state_write = IDLE;

        default: n_state_write = IDLE;
    endcase
end

/////////////////////////////////////////////////////READ Data from BRAM0//////////////////////////////////////////////////////////////

reg [ADDR_WIDTH-1:0] addr_cnt_read;

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

//Sobel Mask 적용을 위해 3*3 행렬의 행 순으로 BRAM0에 접근하여 read하기 위한 counter
reg [1:0] addr_cnt_read_check;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        addr_cnt_read_check <= 0;
    else if(addr_cnt_read_check == 2'd2) //3행씩 접근
        addr_cnt_read_check <= 0;
    else if(state_read == SOBEL)
        addr_cnt_read_check <= addr_cnt_read_check + 1;
    else
        addr_cnt_read_check <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        addr_cnt_read <= 0;
    else if(read_done)
        addr_cnt_read <= 0;
    else if(state_read == MOVE)
        addr_cnt_read <= addr_cnt_read + 1;
    else if(state_read == SOBEL) begin
        if(addr_cnt_read_check == 2)
            addr_cnt_read <= addr_cnt_read - 2*IMAGE_WIDTH + 1; // (3*3행렬) 3행까지 접근 후 1행부터 시작
        else
            addr_cnt_read <= addr_cnt_read + IMAGE_WIDTH; // SOBEL 적용을 위해 행순으로 data read
    end else
        addr_cnt_read <= addr_cnt_read;
end

assign read_done = (addr_cnt_read == num_cnt-1) && ((state_read == MOVE) || (state_read == SOBEL));

//BRAM0 Output Logic
assign b0_d1       = {DATA_WIDTH{1'b1}}; // No use
assign b0_ce1      = (state_read == MOVE) || (state_read == SOBEL);
assign b0_we1      = 1'b0; //BRAM0로 부터 읽기(Read)만 사용
assign b0_addr1    = addr_cnt_read;

//BRAM0에서 Read한 Data(b0_q1)는 1cycle 뒤에 나오므로 o_read보다 1clock 지연된 시점의 값을 얻어야함
reg valid_read;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        valid_read <= 0;
    else
        valid_read <= o_read;
end

/////////////////////////////////////////////////////Write Data to BRAM1//////////////////////////////////////////////////////////////
reg [ADDR_WIDTH-1:0] addr_cnt_write;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        addr_cnt_write <= 0;
    else if(write_done)
        addr_cnt_write <= 0;
    else if(sobel_done) //Sobel mask 적용 후 image의 edge 부분의 data를 0으로 채우기(resize) 위해 address count값 초기화
        addr_cnt_write <= 0;
    else if(((state_write == MOVE) || (state_write == SOBEL)) && b1_we1)
        addr_cnt_write <= addr_cnt_write + 1;
    else if(state_write == SOBEL_RESIZE) begin
        if((addr_cnt_write < IMAGE_WIDTH - 1) || (addr_cnt_write > (IMAGE_WIDTH * IMAGE_HEIGHT) - IMAGE_WIDTH - 1)) //image의 첫행과 마지막행 address에만 접근
            addr_cnt_write <= addr_cnt_write + 1;
        else begin //image의 1열과 마지막열 address에만 접근
            if(addr_cnt_write % IMAGE_WIDTH == 0)
                addr_cnt_write <= addr_cnt_write + (IMAGE_WIDTH - 1);
            else  
                addr_cnt_write = addr_cnt_write + 1;
        end
    end else
        addr_cnt_write <= addr_cnt_write;
end

assign sobel_done = (addr_cnt_write == IMAGE_WIDTH * (IMAGE_HEIGHT-2) - 1) && sobel_core_delay[2] && (state_write == SOBEL);
assign write_done = (addr_cnt_write == num_cnt - 1) && (state_write == MOVE || state_write == SOBEL_RESIZE);

always @(*) begin
    if(state_write == SOBEL)
        if(addr_cnt_write % IMAGE_WIDTH >= 2) //1,2 번째 data는 유효하지 않음(3*3행이 모두 채워지지 않음)
            b1_addr1 <= addr_cnt_write + IMAGE_WIDTH - 1; //Sobel mask 적용시 image의 edge 부분의 data가 없어지므로 image의 1번째 행에는 data를 채우지 않음
        else
            b1_addr1 <= addr_cnt_write;
    else if((state_write == MOVE) || (state_write == SOBEL_RESIZE))
        b1_addr1 <= addr_cnt_write;
end

//Read data capture
reg [DATA_WIDTH-1:0] move_data;
reg [DATA_WIDTH-1:0] sobel_data [8:0];

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        move_data <= {DATA_WIDTH{1'b0}};
        sobel_data[0] <= {DATA_WIDTH{1'b0}};
        sobel_data[1] <= {DATA_WIDTH{1'b0}};
        sobel_data[2] <= {DATA_WIDTH{1'b0}};
    end else if(valid_read) begin
        if((state_read == MOVE) || (state_read == MOVE_DONE))
            move_data <= b0_q1;
        else if((state_read == SOBEL) || (state_read == SOBEL_DONE)) begin
		    sobel_data[0] <= b0_q1;   
            sobel_data[1] <= sobel_data[0];
            sobel_data[2] <= sobel_data[1];
        end
    end else begin
        move_data <= {DATA_WIDTH{1'b0}};
        sobel_data[0] <= {DATA_WIDTH{1'b0}};
        sobel_data[1] <= {DATA_WIDTH{1'b0}};
        sobel_data[2] <= {DATA_WIDTH{1'b0}};
    end
end

//(SOBEL) 행렬을 채우기 위해 delay
reg move_core_delay;
reg [2:0] sobel_core_delay; 

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        sobel_core_delay <= 0;
    else if(sobel_core_delay[2])
        sobel_core_delay <= {2'b0, valid_read};
    else if(valid_read) begin
        if((state_read == MOVE) || (state_read == MOVE_DONE))
            move_core_delay <= valid_read;
        else if((state_read == SOBEL) || (state_read == SOBEL_DONE))
            sobel_core_delay <= {sobel_core_delay[1:0], valid_read};
    end else begin
        move_core_delay <= 0;
        sobel_core_delay <= 3'b0;
    end
end


//(SOBEL) 행렬(3열->2열, 2열->1열) shift
genvar idx;

generate
    for (idx = 0; idx < 3; idx = idx + 1) begin : gen_sobel_shift
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                sobel_data[idx + 3] <= {DATA_WIDTH{1'b0}}; 
                sobel_data[idx + 6] <= {DATA_WIDTH{1'b0}}; 
            end else if(sobel_core_delay[2]) begin
                sobel_data[idx + 3] <= sobel_data[idx];
                sobel_data[idx + 6] <= sobel_data[idx + 3];
            end else;
        end
    end
endgenerate

//(SOBEL) 4열을 제외한 3*3 행열 sobel mask ALU
wire [7:0] p0, p1, p2, p3, p4, p5, p6, p7, p8;
wire [7:0] o_sobel;

assign p0 = sobel_data[8];
assign p1 = sobel_data[5];
assign p2 = sobel_data[2];
assign p3 = sobel_data[7];
assign p4 = sobel_data[4];
assign p5 = sobel_data[1];
assign p6 = sobel_data[6];
assign p7 = sobel_data[3];
assign p8 = sobel_data[0];

assign b1_ce1 = move_core_delay || sobel_core_delay[0] || (state_write == SOBEL_RESIZE);
assign b1_we1 = move_core_delay || sobel_core_delay[2] || (state_write == SOBEL_RESIZE);
assign b1_d1 = move_core_delay*move_data + sobel_core_delay[2]*o_sobel;

assign o_idle   = (state_read == IDLE) && (state_write == IDLE);
assign o_read   = (state_read == MOVE) || (state_read == SOBEL);
assign o_write  = (state_write == MOVE) || (state_write == SOBEL) || (state_write == SOBEL_RESIZE);
assign o_done   = (state_write == MOVE_DONE) || (state_write == SOBEL_DONE);


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
