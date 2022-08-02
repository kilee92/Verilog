module TB_Sobel_Edge_Detector
#(
    parameter DATA_WIDTH    = 8,
    parameter ADDR_WIDTH    = 16,
    parameter MEM_SIZE      = 65536, // 2^16

    parameter IMAGE_WIDTH   = 100,
    parameter IMAGE_HEIGHT  = 100
)
();

reg                       clk         ;
reg                       rst_n       ;
reg                       i_en        ;
reg [ADDR_WIDTH-1:0]      i_num_cnt   ;
reg                       i_run       ;

wire                      o_idle      ;
wire                      o_read      ;
wire                      o_write     ;
wire                      o_done      ;

reg                       b0_ce0      ;
reg                       b0_we0      ;
reg [DATA_WIDTH-1:0]      b0_d0       ;
reg [ADDR_WIDTH-1:0]      b0_addr0    ;

wire [DATA_WIDTH-1:0]     b0_q0       ;

reg                       b1_ce0      ;
reg                       b1_we0      ;
reg [DATA_WIDTH-1:0]      b1_d0       ;
reg [ADDR_WIDTH-1:0]      b1_addr0    ;

wire [DATA_WIDTH-1:0]     b1_q0       ;

always #5 clk = ~clk;

integer i, j;
initial begin
    clk         = 0;
    rst_n       = 1;
    i_en        = 0;
    i_num_cnt   = IMAGE_WIDTH * IMAGE_HEIGHT;
    i_run       = 0;    
    b0_ce0      = 0;
    b0_we0      = 0;
    b0_d0       = {DATA_WIDTH{1'b0}};
    b0_addr0    = {ADDR_WIDTH{1'b0}};
    b1_ce0      = 0;
    b1_we0      = 0;
    b1_d0       = {DATA_WIDTH{1'b0}};
    b1_addr0    = {ADDR_WIDTH{1'b0}};
    #100

    //Reset
    rst_n       = 0;
    #10

    rst_n       = 1;
    #10

    #100

    //BRAM0에 Image data 저장
    for(i = 0; i < i_num_cnt; i = i + 1) begin
        @(posedge clk)
        b0_ce0      = 1;
        b0_we0      = 1;
        b0_d0       = i;
        b0_addr0    = i;
    end

    //Check IDLE state
    wait(o_idle);

    //Start Image data move
    i_en = 1;
    #100

    //처음에는 data move
    //move완료 후 data sobel
    i_run = 1;

    //data move complete
    wait(o_done)

    //data sobel complete
    wait(o_done)

    #10000000

    $finish;

end

always @(*) begin
    
    //Move or sobel이 완료 되었을 경우 읽어 오기 시작
    wait(o_done);
    
    for(j = 0; j < i_num_cnt; j = j + 1) begin
        @(posedge clk)
        b1_ce0      = 1;
        b1_we0      = 0;
        b1_addr0    = j;
    end
end

Top_Sobel_Edge_Detect u0
#(
    .DATA_WIDTH     (DATA_WIDTH  ),
    .ADDR_WIDTH     (ADDR_WIDTH  ),
    .MEM_SIZE       (MEM_SIZE    ),
    .IMAGE_WIDTH    (IMAGE_WIDTH ),
    .IMAGE_HEIGHT   (IMAGE_HEIGHT)    
)
(
    .clk         (clk      ),
    .rst_n       (rst_n    ),
    .i_en        (i_en     ),
    .i_num_cnt   (i_num_cnt),
    .i_run       (i_run    ),
    .o_idle      (o_idle   ),
    .o_read      (o_read   ),
    .o_write     (o_write  ),
    .o_done      (o_done   ),
    .b0_ce0      (b0_ce0   ),
    .b0_we0      (b0_we0   ),
    .b0_d0       (b0_d0    ),
    .b0_addr0    (b0_addr0 ),
    .b0_q0       (b0_q0    ),
    .b1_ce0      (b1_ce0   ),
    .b1_we0      (b1_we0   ),
    .b1_d0       (b1_d0    ),
    .b1_addr0    (b1_addr0 ),
    .b1_q0       (b1_q0    ) 
);

endmodule
