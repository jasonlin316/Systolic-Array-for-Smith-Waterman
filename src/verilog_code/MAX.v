module MAX
(
    input clk,
    input signed[15:0] data1_in,
    input signed[15:0] data2_in,
    output signed[15:0]data_o
);

reg [15:0] op;

assign data_o = op;

  always@(*)begin
    if(data1_in > data2_in) begin
      if(data1_in>16'd0)op = data1_in;
      else op = 16'd0;
    end
    else begin
      if(data2_in>16'd0)op = data2_in;
      else op = 16'd0;
    end
  end
endmodule