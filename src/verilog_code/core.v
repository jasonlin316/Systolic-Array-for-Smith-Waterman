`include"systolic.v"
`include"shift_s.v"
`include"shift_t.v"
//`include"../Memory/sram_8192x8_t13/sram_8192x8_t13.v"

module core(
    input       clk,
    input       reset_i,
    input[2:0]  S,
    input[2:0]  T,
    input[15:0] s_len_i,
    input[15:0] t_len_i,
    output      busy,
    output      valid,
    output[15:0] max_out,
    output       t_valid_in//t can come in
);

parameter N = 6'd50;

wire [2:0] shift_s_output;
wire [2:0] shift_t_output;
wire       valid_s,valid_t;
wire       shift_valid_s;


integer i;

shift_s shift_s(
    .clk(clk),
    .rst(reset_i),
    .s_in(S),
    .s_o(shift_s_output),
    .valid(valid_s),
    .shift_valid(shift_valid_s)//ctrl whether s should pass,and is ligit
);

shift_t shift_t(
    .clk(clk),
    .rst(reset_i),
    .t_in(T),
    .valid(valid_t),//that t is ligit
    .t_o(shift_t_output)
);

systolic systolic(
    .clk(clk),
    .reset_i(reset_i),
    .valid_s(valid_s),
    .shift_valid_s(shift_valid_s),
    .S(shift_s_output),
    .T(shift_t_output),
    .s_len_i(s_len_i),
    .t_len_i(t_len_i),
    .valid_t(valid_t),
    .max_out(max_out),
    .busy(busy),
    .valid(valid),
    .t_valid_in(t_valid_in)
);

endmodule

