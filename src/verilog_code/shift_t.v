module shift_t
(   
    input clk,
    input rst,
    input [2:0] t_in,
    output reg valid,
    output reg [2:0] t_o
);
reg valid_next;
reg [7:0] counter,counter_next;

always@(*)begin

    if(t_in == 3'b001) valid_next = 1'b1;
    else if(t_in == 3'b010)valid_next = 1'b0;
    else valid_next = valid;
    
end

    always@(posedge clk or posedge rst)begin
        if(rst)begin
            t_o         <= 3'b0;
            valid       <= 1'b0;
            counter     <= 5'b0;
        end
        else begin
            t_o         <= t_in;
            valid       <= valid_next;
            counter     <= counter_next;
        end

    end
endmodule