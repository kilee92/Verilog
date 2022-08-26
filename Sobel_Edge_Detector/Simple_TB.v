module Simple_TB_Sobel_Edge_Detector_MOVE
#(
    parameter DATA_WIDTH    = 8,
    parameter ADDR_WIDTH    = 16,
    parameter MEM_SIZE      = 65536, // 2^16

    parameter IMAGE_WIDTH   = 5,
    parameter IMAGE_HEIGHT  = 5
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

    //BRAM0에 MOVE Image data 저장
    for(i = 0; i < i_num_cnt; i = i + 1) begin
        @(posedge clk)
        b0_ce0      = 1;
        b0_we0      = 1;
        b0_d0       = i;
        b0_addr0    = i;
    end

    //Start Image data move
    i_en = 1;
    #10
    i_en = 0;

    //data move complete
    wait(o_done)
    
    //BRAM1에서 Image data 출력
    for(j = 0; j < i_num_cnt; j = j + 1) begin
        @(posedge clk)
        b1_ce0      = 1;
        b1_we0      = 0;
        b1_addr0    = j;
    end

    #1000

    //BRAM0에 SOBEL Image data 저장
    for(i = 0; i <i_num_cnt; i = i + 1) begin
        @(posedge clk)
        b0_ce0      = 1;
        b0_we0      = 1;
        if(i < IMAGE_WIDTH * 3) begin
            b0_d0       = 255;
            b0_addr0    = i;
        end else begin
            b0_d0       = 0;
            b0_addr0    = i;
        end
    end
    
    //Start Image data sobel & move
    i_en = 1;
    #10
    i_en = 0;    
    
    //data sobel & move complete
    wait(o_done)
    
    //BRAM1에서 Image data 출력
    for(j = 0; j < i_num_cnt; j = j + 1) begin
        @(posedge clk)
        b1_ce0      = 1;
        b1_we0      = 0;
        b1_addr0    = j;
    end

    #1000

    $finish;

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
