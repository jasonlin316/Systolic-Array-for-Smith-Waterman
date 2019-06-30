module shift_s
(   
    input clk,
    input rst,
    input [2:0] s_in,
    output reg shift_valid,
    output reg valid,
    output reg [2:0] s_o
);
reg shift_valid_next,valid_next;
reg [4:0] counter,counter_next;
reg [4:0] counter2,counter2_next;
reg flag,flag_next;
always@(*)begin
    
    if(s_in == 3'b001)begin
        shift_valid_next = 1;
        flag_next        = 0;
    end 
    else if(s_in == 3'b010)begin
        shift_valid_next = shift_valid;
        flag_next = 1;
    end 
    else begin
        shift_valid_next = shift_valid;
        flag_next        = flag;
    end
  
    if(flag)shift_valid_next = 0;
    else shift_valid_next = 1;

end

    always@(posedge clk or posedge rst)begin
        if(rst)begin
            s_o         <= 3'b0;
            shift_valid <= 1'b1;
            counter     <= 5'b0;
            counter2    <= 5'b0;
            valid       <= 1'b0;
            flag        <= 0;
        end
        else begin
            s_o         <= s_in;
            shift_valid <= shift_valid_next;
            counter     <= counter_next;
            valid       <= valid_next;
            counter2    <= counter2_next;
            flag        <= flag_next;
        end

    end
endmodule