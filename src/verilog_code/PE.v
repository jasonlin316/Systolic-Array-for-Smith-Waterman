`include"MAX.v"
`include"LUT.v"

module PE(
      input             clk,
      input             reset_i,
      input             shift_valid_s,
      input      [2:0]  s_in,
      input      [2:0]  t_in,
      input      [15:0]  max_in,
      input      [15:0]  v_in,
      input      [15:0]  f_in,
      input             init_in,
      input             valid_s_in,
      output reg        valid_s_out,
      output reg        init_out,
      output reg [2:0]  s_out,
      output reg [2:0]  t_out,
      output reg [15:0]  max_out,
      output reg [15:0]  v_out,
      output reg [15:0]  f_out
);
parameter alpha = 16'd2;
parameter beta = 16'd1;
parameter N = 16;
      
/* ======================REG & wire================================ */
      wire signed[15:0]   v_i_j1;
      wire signed  [15:0]   w1,m3_in1,m3_in2,m5_in1,m5_in2;
      wire  [2:0]   s_signal;
      wire  [2:0]   t_signal;
      wire  signed[15:0]   LUT_data_o;
      wire  signed[N-1:0]   m1_data_o;
      wire  signed[N-1:0]   m2_data_o;
      wire  signed[N-1:0]   m3_data_o;
      wire  signed[N-1:0]   m4_data_o;
      wire  signed[N-1:0]   m5_data_o;
      wire  signed[N-1:0]   m6_data_o;
      reg   signed[N-1:0]   ff1_out;
      reg   signed[N-1:0]   v_diag_o;
      reg   signed[N-1:0]   e_out;
      
 /* ====================Conti Assignment================== */
      assign w1     = ((v_diag_o + LUT_data_o)>16'd0)?(v_diag_o + LUT_data_o):0;
      assign m3_in1 = (v_i_j1 > alpha)               ? (v_i_j1 - alpha):0;
      assign m3_in2 = (e_out > beta)                 ?(e_out - beta):0;
      assign m5_in1 = (v_in > alpha)                 ?(v_in - alpha):0;
      assign m5_in2 = (f_in > beta)                  ?(f_in - beta):0;
      assign v_i_j1 = v_out;
      assign s_signal = (shift_valid_s)? s_in : s_out;
      assign t_signal = t_in;
 /* ====================Combinational Part================== */

 LUT LUT(
    .data1_in   (s_out),
    .data2_in   (t_in),
    .data_o     (LUT_data_o)
);

MAX m1(
    .data1_in   (max_in),
    .data2_in   (v_i_j1),
    .data_o     (m1_data_o),
    .clk      (clk)
);

MAX m2(
    .data1_in   (m1_data_o),
    .data2_in   (max_out),
    .data_o     (m2_data_o),
    .clk      (clk)
);

MAX m3(
    .data1_in   (m3_in1),
    .data2_in   (m3_in2),
    .data_o     (m3_data_o),
    .clk      (clk)
);

MAX m4(
    .data1_in   (m3_data_o),
    .data2_in   (m5_data_o),
    .data_o     (m4_data_o),
    .clk      (clk)
);

MAX m5(
    .data1_in   (m5_in1),
    .data2_in   (m5_in2),
    .data_o     (m5_data_o),
    .clk      (clk)
);

MAX m6(
    .data1_in   (w1),
    .data2_in   (m4_data_o),
    .data_o     (m6_data_o),
    .clk      (clk)
);

/* ====================Sequential Part=================== */
    always@(posedge clk or posedge reset_i)
    begin
        if (reset_i)
        begin
            s_out   <= 0;
            t_out   <= 0;
            v_diag_o<= 0;
            e_out   <= 0;
            v_out   <= 0;
            f_out   <= 0;
            max_out <= 0;
            init_out<= 0;
            valid_s_out<=0;
        end
        else
            if (init_out)
            begin
                s_out   <= s_signal;
                t_out   <= t_signal;
                v_diag_o<= v_in;
                e_out   <= m3_data_o;
                v_out   <= m6_data_o;
                f_out   <= m5_data_o;
                max_out <= m2_data_o;
                init_out<= init_in;
                valid_s_out<= valid_s_in;
            end
            else begin
                s_out   <= s_signal;
                t_out   <= t_signal;
                v_diag_o<= 0;
                e_out   <= 0;
                v_out   <= 0;
                f_out   <= 0;
                max_out <= 0;
                init_out<= init_in;
                valid_s_out<= valid_s_in;
            end
    end
  /* ====================================================== */
endmodule