module DPBRAM
#(
    parameter DATA_WIDTH    = 8,
    parameter ADDR_WIDTH    = 16,
    parameter MEM_SIZE      = 65536 // 2^16
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

//Vivado에서 인식할 수 있는 Attribute (Xilinx의 HLS에서 자동으로 dual port block ram을 자동으로 생성)
(*ram_style = "block"*) reg [DATA_WIDTH-1:0] ram [MEM_SIZE-1:0];

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
