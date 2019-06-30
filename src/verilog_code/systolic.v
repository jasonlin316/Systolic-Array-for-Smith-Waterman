`include"PE.v"
//`include"../Memory/sram_1024x8_t13/sram_1024x8_t13.v"

module systolic(
    input       clk,
    input       reset_i,
    input       valid_s,
    input       shift_valid_s,
    input[2:0]  S,
    input[2:0]  T,
    input[15:0] s_len_i,
    input[15:0] t_len_i,
    input       valid_t,
    output reg[15:0]max_out,
    output reg     busy,
    output reg     valid,
    output         t_valid_in//when s stops shifiting,t can come in
);

genvar    j;
integer   i;
parameter N = 64;
parameter W = 16;
parameter IDLE = 3'b000;
parameter INITAL = 3'b001;
parameter RAWB = 3'b010;
parameter BUFFER = 3'b011;
parameter RBWA = 3'b100;
parameter BUFFER2 = 3'b101;
/* =======================REG & wire================================ */

wire [2:0]  Si   [N-1:0];
wire [2:0]  So   [N-1:0];
wire [2:0]  Ti   [N-1:0];
wire [2:0]  To   [N-1:0];
wire [W-1:0]  MaxIn[N-1:0];
wire [W-1:0]  MaxOu[N-1:0];
wire [W-1:0]  Vi   [N-1:0];
wire [W-1:0]  Vo   [N-1:0];
wire [W-1:0]  Fi   [N-1:0];
wire [W-1:0]  Fo   [N-1:0];
wire InitIn      [N-1:0];
wire InitOu      [N-1:0];
wire ValSIn      [N-1:0];
wire ValSOu      [N-1:0];
wire [15:0] last_pos;
wire [7:0]  Q [0:7];
reg  [9:0]  A [0:7];
reg  [7:0]  D [0:7];
reg CEN[0:7];
reg WEN[0:7];
reg W_d1[0:7];
reg W_d2[0:7];
reg [7:0]mem_data_o[0:7];
reg busy_next;
reg pre_valid;
reg pre_valid_next;
reg valid_d1;
reg [9:0] counter,counter_next;
reg [9:0] addr,addr_next,addr_d1,addr_d2,addr_d3;
reg [9:0] addr2,addr2_next;
reg [9:0] addr3,addr3_next;
reg flag,flag_next;
reg f2,f2_next;
reg f2_d1,f2_d2;
reg f3,f3_next;
reg [15:0] max_out_next;
reg [2:0]state,state_next;
reg [W-1:0] v_reg;
reg [W-1:0] f_reg;
reg [W-1:0] max_reg;
reg [2:0] S_delay;
reg [2:0] t_shift_reg [0:3];
reg available;

/* ====================Conti Assign================== */

assign Si[0]      = S_delay;
assign Ti[0]      = T;
assign InitIn[0]  = valid_t;
assign MaxIn[0]   = max_reg;
assign Vi[0]      = v_reg;
assign Fi[0]      = f_reg;
assign t_valid_in = shift_valid_s;
assign last_pos   = ((s_len_i-16'd3) < N)? (s_len_i-16'd3) : (N-1);

generate
  for(j=1;j<N;j=j+1)begin
    assign Si[j]       = So[j-1];
    assign Vi[j]       = Vo[j-1];
    assign Fi[j]       = Fo[j-1];
    assign MaxIn[j]    = MaxOu[j-1];
    assign ValSIn[j-1] = ValSOu[j];
    assign Ti[j]       = To[j-1];
    assign InitIn[j]   = InitOu[j-1];
  end
endgenerate
/* ====================Combinational Part================== */

generate
  for( j=0 ; j < N ; j=j+1)begin
    PE P(
     .clk(clk),
     .reset_i(reset_i),
     .shift_valid_s(shift_valid_s),
     .s_in(Si[j]),
     .t_in(Ti[j]),
     .max_in(MaxIn[j]),
     .v_in(Vi[j]),
     .f_in(Fi[j]),
     .init_in(InitIn[j]),
     .valid_s_in(ValSIn[j]),
     .valid_s_out(ValSOu[j]),
     .init_out(InitOu[j]),
     .s_out(So[j]),
     .t_out(To[j]),
     .max_out(MaxOu[j]),
     .v_out(Vo[j]), 
     .f_out(Fo[j])
    );
  end
endgenerate

generate
  for( j= 0 ; j < 8 ; j=j+1)begin
    sram_1024x8_t13 sram(
      .Q(Q[j]),//data_o
      .CLK(clk),
      .CEN(CEN[j]),//chip enable,stand by if == 1
      .WEN(WEN[j]),//Write enable, 0:write;1:read
      .A(A[j]),//address
      .D(D[j])//data_i
    );
  end
endgenerate

always@(*)begin
  max_out_next = max_out;
  state_next = state;
  busy_next = busy;
  for(i=0;i<8;i=i+1) CEN[i] = 1;
  for(i=0;i<8;i=i+1) WEN[i] = 0;
  for(i=0;i<8;i=i+1) D[i]   = 0;
  for(i=0;i<8;i=i+1) A[i]   = 0;
  f3_next = f3;
  f2_next = f2;
  addr_next = addr;
  addr2_next = addr2;//for initalization, assign zero to SRAM.
  addr3_next = addr3;
  flag_next = flag;
  counter_next = counter;
  pre_valid_next = pre_valid;
  v_reg = 0;
  f_reg = 0;
  max_reg = 0;

  case(state)
    IDLE:begin
      busy_next = 1;
      addr2_next = addr2;
      state_next = INITAL;
      max_reg = 0;
    end

    INITAL:begin
      busy_next = busy;
      addr2_next = addr2 + 10'd1;
      if(addr2 < t_len_i)begin
        for(i=0;i<8;i=i+1) CEN[i] = 0;
        for(i=0;i<8;i=i+1) WEN[i] = 0;
        for(i=0;i<8;i=i+1) D[i]   = 0;
        for(i=0;i<8;i=i+1) A[i]   = addr2;
      end
      else begin 
        state_next = RAWB;
        busy_next  = 0;
      end
    end

    RAWB:begin //read A write B
        //read A
        if(Ti[0] == 3'b001)f3_next = 1;
        else if(Ti[0] == 3'b010)f3_next = 0;
             else f3_next = f3;
        
        if(f3_next)begin
          for(i=0;i<4;i=i+1) CEN[i] = 0;
          for(i=0;i<4;i=i+1) WEN[i] = 1;
          for(i=0;i<4;i=i+1) A[i] = addr3;
          v_reg = {mem_data_o[1],mem_data_o[0]};
          f_reg = {mem_data_o[3],mem_data_o[2]};
          addr3_next = addr3 + 10'd1;
        end
        else for(i=0;i<4;i=i+1) CEN[i] = 1;

        if(Ti[N-1] == 3'b001)f2_next = 1'b1;
        else begin
          if(To[N-1] == 3'b010)f2_next = 1'b0;
          else f2_next = f2;
        end
        
        //starting to write in B.
        if(f2_next && (To[N-1] != 3'b010) && (To[N-1] != 3'b000))begin
          for(i=4;i<8;i=i+1) CEN[i] = 0;
          for(i=4;i<8;i=i+1) WEN[i] = 0;
          for(i=4;i<8;i=i+1) A[i] =  addr_d2;
          D[4] = Vo[N-1][7:0];
          D[5] = Vo[N-1][15:8];
          D[6] = Fo[N-1][7:0];
          D[7] = Fo[N-1][15:8];
          addr_next  = (addr + 10'd1);
        end
        else begin
          for(i=4;i<8;i=i+1) CEN[i] = 1;
          for(i=4;i<8;i=i+1) A[i] = 0;
        end
        
        //state control
        if(S[2])busy_next = 1'b1;
        else if(pre_valid)begin
              busy_next = 1'b0;
              state_next = BUFFER;
             end 
             else busy_next = busy;

        if(Ti[last_pos]==3'b010)pre_valid_next = 1;
        else pre_valid_next = pre_valid;

        max_reg = max_out;
    end
    BUFFER:begin
      state_next = RBWA;
      counter_next = 0;
      flag_next = 0;
      f2_next = 0;
      f3_next = 0;
      pre_valid_next = 0;
      max_reg = MaxOu[0];
      addr3_next = 0;
      addr_next = 0;
      max_reg = max_out;
    end
    RBWA:begin
        //read B
        if(Ti[0] == 3'b001)f3_next = 1;
        else if(Ti[0] == 3'b010)f3_next = 0;
             else f3_next = f3;
       
        if(f3_next)begin
          for(i=4;i<8;i=i+1) CEN[i] = 0;
          for(i=4;i<8;i=i+1) WEN[i] = 1;
          for(i=4;i<8;i=i+1) A[i] = addr3_next;
          v_reg = {mem_data_o[5],mem_data_o[4]};
          f_reg = {mem_data_o[7],mem_data_o[6]};
          addr3_next = addr3 + 10'd1;
        end
        
        //write A
        if(Ti[N-1] == 3'b001)f2_next = 1'b1;
        else begin
          if(To[N-1] == 3'b010)f2_next = 1'b0;
          else f2_next = f2;
        end

        if(f2_next && (To[N-1] != 3'b010) && (To[N-1] != 3'b000))begin//starting to write in B.
          for(i=0;i<4;i=i+1) CEN[i] = 0;
          for(i=0;i<4;i=i+1) WEN[i] = 0;
          for(i=0;i<4;i=i+1) A[i] = addr_d2;
          D[0] = Vo[N-1][7:0];
          D[1] = Vo[N-1][15:8];
          D[2] = Fo[N-1][7:0];
          D[3] = Fo[N-1][15:8];
          addr_next  = (addr + 10'd1);
        end
        else begin
          for(i=0;i<4;i=i+1) CEN[i] = 1;
          for(i=0;i<4;i=i+1) A[i] = 0;
        end

        //state control
        if(S[2])busy_next = 1'b1;
        else if(pre_valid) begin
              busy_next = 1'b0;
              state_next = BUFFER2;
            end
            else busy_next = busy;

        if(Ti[last_pos]==3'b010)pre_valid_next = 1;
        else pre_valid_next = pre_valid;

        max_reg = max_out;
    end
    BUFFER2:begin
      state_next = RAWB;
      pre_valid_next = 0;
      counter_next = 0;
      flag_next = 0;
      f2_next = 0;
      f3_next = 0;
      pre_valid_next = 0;
      max_reg = MaxOu[0];
      addr3_next = 0;
      addr_next = 0;
      max_reg = max_out;
    end
  endcase
end

/* ====================Sequential Part=================== */
    always@(posedge clk or posedge reset_i)
    begin
        if (reset_i == 1'b1)
        begin
            max_out <= 0;
            counter <= 0;
            addr    <= 0;
            addr_d1 <= 0;
            addr_d2 <= 0;
            addr_d3 <= 0;
            addr2   <= 0;
            addr3   <= 0;
            busy    <= 1;
            valid_d1<= 0; 
            valid   <= 0;
            flag    <= 0;
            f2      <= 0;
            f2_d1   <= 0;
            f2_d2   <= 0;
            f3      <= 0;
            pre_valid <= 0;
            state     <= 0;
            S_delay   <= 0;
            available <= 0;
            for(i=0;i<8;i=i+1)begin
              mem_data_o[i] <=0;
            end
            for(i=0;i<4;i=i+1)t_shift_reg[i] <= 0;
        end
        else
        begin
            max_out <= (available)? MaxOu[last_pos] : max_out_next;
            counter <= counter_next;
            addr    <= addr_next;
            addr_d1 <= addr;
            addr_d2 <= addr_d1;
            addr_d3 <= addr_d2;
            addr2   <= addr2_next;
            addr3   <= addr3_next;
            busy    <= busy_next;
            valid_d1<= valid;
            valid   <= pre_valid;
            flag    <= flag_next;
            f2      <= f2_next;
            f2_d1   <= f2;
            f2_d2   <= f2_d1;
            f3      <= f3_next;
            pre_valid <= pre_valid_next;
            state     <= state_next;
            S_delay   <= S;
            available <= InitOu[last_pos];
            for(i=0;i<8;i=i+1)begin
              mem_data_o[i] <=(W_d1[i])?Q[i]:0;
              W_d1[i]       <= WEN[i];
              W_d2[i]       <= W_d1[i];
            end
            t_shift_reg[0] <= T;
            for(i=0;i<3;i=i+1)t_shift_reg[i+1] <= t_shift_reg[i];
        end
    end
  /* ====================================================== */

endmodule
