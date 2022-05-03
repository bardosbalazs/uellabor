module aes(
    input clk,
    input rst,
    
);


reg [1:0] state=0;
reg [3:0] iter=0;

parameter START = 2'b00;
parameter PROCESS = 2'b01;
parameter FINISH = 2'b11;

always @(posedge clk)
begin
    case (state)
    START: begin 
        iter<=0;
        state<=PROCESS;
    end
        
    PROCESS: begin
        

        i<=i+1;
        if(i>15) state=FINISH;
    end
    FINISH: begin 

    end
    endcase

end