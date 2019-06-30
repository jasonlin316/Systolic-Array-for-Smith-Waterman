module LUT
(
    input         [2:0] data1_in,
    input         [2:0] data2_in,
    output signed [15:0] data_o
);

parameter match  =   16'd6;
parameter mismatch = 16'd3;



assign data_o = ((data1_in == 3'b000)||(data2_in == 3'b000))? 15'd0 : (data1_in == data2_in)? match : (mismatch*(-1));


endmodule