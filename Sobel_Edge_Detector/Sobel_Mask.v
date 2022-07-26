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
