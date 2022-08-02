module Top_Sobel_Edge_Detect
#(
    parameter DATA_WIDTH    = 8,
    parameter ADDR_WIDTH    = 16,
    parameter MEM_SIZE      = 65536, // 2^16

    parameter IMAGE_WIDTH   = 100,
    parameter IMAGE_HEIGHT  = 100    
)
(
    input                       clk         ,
    input                       rst_n       ,
    input                       i_en        ,
    input [ADDR_WIDTH-1:0]      i_num_cnt   ,
    input                       i_run       ,

    output                      o_idle      ,
    output                      o_read      ,
    output                      o_write     ,
    output                      o_done      ,

    input                       b0_ce0      ,
    input                       b0_we0      ,
    input [DATA_WIDTH-1:0]      b0_d0       ,
    input [ADDR_WIDTH-1:0]      b0_addr0    ,

    output [DATA_WIDTH-1:0]     b0_q0       ,

    input                       b1_ce0      ,
    input                       b1_we0      ,
    input [DATA_WIDTH-1:0]      b1_d0       ,
    input [ADDR_WIDTH-1:0]      b1_addr0    ,

    output [DATA_WIDTH-1:0]     b1_q0        
);

wire                       b0_ce1      ;
wire                       b0_we1      ;
wire [DATA_WIDTH-1:0]      b0_d1       ;
wire [ADDR_WIDTH-1:0]      b0_addr1    ;

wire [DATA_WIDTH-1:0]      b0_q1       ;

wire                       b1_ce1      ;
wire                       b1_we1      ;
wire [DATA_WIDTH-1:0]      b1_d1       ;
wire [ADDR_WIDTH-1:0]      b1_addr1    ;

wire [DATA_WIDTH-1:0]      b1_q1       ;

FSM_Module_Sobel
#(
    .DATA_WIDTH     (DATA_WIDTH  ),
    .ADDR_WIDTH     (ADDR_WIDTH  ),
    .MEM_SIZE       (MEM_SIZE    ),
    .IMAGE_WIDTH    (IMAGE_WIDTH ),
    .IMAGE_HEIGHT   (IMAGE_HEIGHT)
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

DPBRAM
#(
    .DATA_WIDTH    (DATA_WIDTH),
    .ADDR_WIDTH    (ADDR_WIDTH),
    .MEM_SIZE      (MEM_SIZE  ) 
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

DPBRAM
#(
    .DATA_WIDTH    (DATA_WIDTH),
    .ADDR_WIDTH    (ADDR_WIDTH),
    .MEM_SIZE      (MEM_SIZE  ) 
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
