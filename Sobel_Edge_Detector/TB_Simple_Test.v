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
    `probe(i_en);
    `probe(i_run);
    
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
	
    /*
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
	
    */
    //Check IDLE state
    wait(o_idle);
    //Start Image data run
    i_run = 1;
    #10
    i_en = 1;
    #20
    i_en = 0;
    
    #1000
    /*
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
    `probe(state_write);
    `probe(addr_cnt_read);
    `probe(b0_q1);
    `probe(o_read);
    `probe(valid_read);
    `probe(move_core_delay);
    `probe(sobel_core_delay[0]);
    `probe(sobel_core_delay[1]);
    `probe(sobel_core_delay[2]);
    `probe(b1_we1);
    `probe(b1_addr1);
    `probe(b1_d1);
    `probe(sobel_data[0]);
    `probe(sobel_data[1]);
    `probe(sobel_data[2]);
    `probe(sobel_data[3]);
    `probe(sobel_data[4]);
    `probe(sobel_data[5]);
    `probe(p0);
    `probe(p1);
    `probe(p2);
    `probe(p3);
    `probe(p4);
    `probe(p5);
    `probe(p6);
    `probe(p7);
    `probe(p8);
    `probe(o_sobel);

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

output reg[DATA_WIDTH-1:0]     b1_d1       ;
output                      b1_ce1      ;
output                      b1_we1      ;
output [ADDR_WIDTH-1:0]     b1_addr1    ;

input [DATA_WIDTH-1:0]      b1_q1       ; //No use

output                      o_idle      ;
output                      o_read      ;
output                      o_write     ;
output                      o_done      ;

//Pipeline 적용을 위해 2가지(Read/Write) FSM 사용
reg [2:0] state_read, n_state_read;
reg [2:0] state_write, n_state_write;

//State Parameter
localparam IDLE         = 3'b000;
localparam MOVE         = 3'b001; //Sobel Mask 적용 안하여 데이터 이동(단순 데이터 이동)
localparam MOVE_DONE    = 3'b010;
localparam SOBEL        = 3'b011; //Sobel Mask 적용 하여 데이터 이동
localparam SOBEL_DONE   = 3'b100;

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
            if(write_done)
                n_state_write = SOBEL_DONE;
            else   
                n_state_write = SOBEL;
        end

        MOVE_DONE: n_state_write = IDLE;
        SOBEL_DONE: n_state_write = IDLE;

        default: n_state_write = IDLE;
    endcase
end

/////////////////////////////////////////////////////READ Data from BRAM0//////////////////////////////////////////////////////////////

reg [ADDR_WIDTH-1:0] addr_cnt_read;

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

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        addr_cnt_read <= 0;
    else if((state_read == MOVE_DONE) || (state_read == SOBEL_DONE))
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

assign read_done = (addr_cnt_read == num_cnt-1) && o_read;//o_read = (state_read == MOVE) || (state_read == RUN)

//BRAM0 Output Logic
assign b0_d1       = {DATA_WIDTH{1'b1}}; // No use
assign b0_ce1      = o_read; // o_read = (state_read == MOVE) || (state_read == RUN)
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
    else if((state_write == MOVE_DONE) || (state_write == SOBEL_DONE))
        addr_cnt_write <= 0;
    else if(((state_write == MOVE) || (state_write == SOBEL)) && b1_we1)
        addr_cnt_write <= addr_cnt_write + 1;
    else
        addr_cnt_write <= addr_cnt_write;
end

assign write_done = (addr_cnt_write == num_cnt-1) && o_write; // o_write  = (state_write == MOVE) || (state_write == RUN)

//Read data capture
reg [DATA_WIDTH-1:0] move_data;
reg [DATA_WIDTH-1:0] sobel_data [11:0];

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


//(SOBEL) 행렬(4열->3열, 3열->2열, 2열->1열) shift
genvar idx;

generate
    for (idx = 0; idx < 3; idx = idx + 1) begin : gen_sobel_shift
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                sobel_data[idx + 3] <= {DATA_WIDTH{1'b0}}; //3열
                sobel_data[idx + 6] <= {DATA_WIDTH{1'b0}}; //2열
                sobel_data[idx + 9] <= {DATA_WIDTH{1'b0}}; //1열
            end else if(sobel_core_delay[2]) begin
                sobel_data[idx + 3] <= sobel_data[idx];
                sobel_data[idx + 6] <= sobel_data[idx + 3];
                sobel_data[idx + 9] <= sobel_data[idx + 6];
            end else;
        end
    end
endgenerate

//(SOBEL) 4열을 제외한 3*3 행열 sobel mask ALU
wire [7:0] p0, p1, p2, p3, p4, p5, p6, p7, p8;
wire [7:0] o_sobel;

assign p0 = sobel_data[11];
assign p1 = sobel_data[8];
assign p2 = sobel_data[5];
assign p3 = sobel_data[10];
assign p4 = sobel_data[7];
assign p5 = sobel_data[4];
assign p6 = sobel_data[9];
assign p7 = sobel_data[6];
assign p8 = sobel_data[3];
    
//유효한 data값(Shift된 후)을 계산하기 위해 delay
/*reg d_sobel_core_delay;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        d_sobel_core_delay <= 0;
    else
        d_sobel_core_delay <= sobel_core_delay[2];
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        b1_d1 <= 0;
    else if(d_run_core_delay)
        b1_d1 <= d_run_core_delay*o_sobel;
    else
        b1_d1 <= b1_d1;
end
*/    
assign b1_addr1 = addr_cnt_write;
assign b1_ce1 = move_core_delay || sobel_core_delay;
assign b1_we1 = move_core_delay || sobel_core_delay;
assign b1_d1 = move_core_delay*move_data + sobel_core_delay[2]*o_sobel;

assign o_idle   = (state_read == IDLE) && (state_write == IDLE);
assign o_read   = (state_read == MOVE) || (state_read == SOBEL);
assign o_write  = (state_write == MOVE) || (state_write == SOBEL);
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
//Output Logic


//BRAM1 Output Logic















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
