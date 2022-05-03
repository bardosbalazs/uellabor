module AES256
(
    input clk,                          //órajel
    input rst,                          //reset
    input [127:0] key,                  //kulcs
    input [127:0] word,                 //bemeneti "szó"
    input [7:0] sbox_read_data,         //sbox olvasas

    input flag_data_sent;
    output flag_address_sent;

    input addr_ack;
    output data_ack;

    output reg [7:0] sbox_rqst_addr;    //sbox cimkeres
    output reg [127:0] cipher           //titkosított "szó"
    );

    reg [7:0] state_matrix[0:3][0:3]; //Állapot-mátrix

    reg [255:0] sbox[0:15][0:15];

    always @ (posedge clk)  //szavak bitjeinek betöltése az állapot-mátrixba
    begin
    if(rst)
        begin
            integer row;
            integer col;
            for (row=0;row<4;row++)
            begin
                for(col=0;col<4;col++)
                begin
                    state_matrix[row][col] <= 0;
                end
            end
        end

    else
        begin
            state_matrix[3][3] = word[7:0];
            state_matrix[2][3] = word [15:8];
            state_matrix[1][3] = word [23:16];
            state_matrix[0][3] = word [31:24];
            state_matrix[3][2] = word [39:32];
            state_matrix[2][2] = word [47:40];
            state_matrix[1][2] = word [55:48];
            state_matrix[0][2] = word [63:56];
            state_matrix[3][1] = word [71:64];
            state_matrix[2][1] = word [79:72];
            state_matrix[1][1] = word [87:80];
            state_matrix[0][1] = word [95:88];
            state_matrix[3][0] = word [103:96];
            state_matrix[2][0] = word [111:104];
            state_matrix[1][0] = word [119:112];
            state_matrix[0][0] = word [127:120];
        end
    end

    always @ (posedge clk)
    begin
        if(rst)
            begin
                integer row;
                integer col;
                for (row=0;row<4;row++)
                begin
                    for(col=0;col<4;col++)
                    begin
                        state_matrix[row][col] <= 0;
                    end
                end
            end

        else if(en)
            begin
                state_matrix[3][3] = state_matrix[3][3] ^ key[7:0];
                state_matrix[2][3] = state_matrix[2][3] ^ key[15:8];
                state_matrix[1][3] = state_matrix[1][3] ^ key[23:16];
                state_matrix[0][3] = state_matrix[0][3] ^ key[31:24];
                state_matrix[3][2] = state_matrix[3][2] ^ key[39:32];
                state_matrix[2][2] = state_matrix[2][2] ^ key[47:40];
                state_matrix[1][2] = state_matrix[1][2] ^ key[55:48];
                state_matrix[0][2] = state_matrix[0][2] ^ key[63:56];
                state_matrix[3][1] = state_matrix[3][1] ^ key[71:64];
                state_matrix[2][1] = state_matrix[2][1] ^ key[79:72];
                state_matrix[1][1] = state_matrix[1][1] ^ key[87:80];
                state_matrix[0][1] = state_matrix[0][1] ^ key[95:88];
                state_matrix[3][0] = state_matrix[3][0] ^ key[103:96];
                state_matrix[2][0] = state_matrix[2][0] ^ key[111:104];
                state_matrix[1][0] = state_matrix[1][0] ^ key[119:112];
                state_matrix[0][0] = state_matrix[0][0] ^ key[127:120];
            end
    end

    reg [7:0] Temp;
    

    always@(posedge clk)
    begin
        reg [1:0] state=0;

        reg [1:0] row=0;
        reg [1:0] col=0;

        parameter START = 2'b00;
        parameter PROCESS = 2'b01;
        parameter FINISH = 2'b11;

        always @(posedge clk)
        begin
            case (state)
            START: begin 
                row<=0;
                col<=0;
                state <= PROCESS;
            end
                
            PROCESS: begin
                
                if(!flag_address_sent & !flag_data_sent)
                begin
                    Temp <= state_matrix[row][col]
                    sbox_rqst_addr <= Temp;
                    flag_address_sent <=1;
                end

                else if(flag_address_sent & top_flag_data_sent)
                begin
                    state_matrix[row][col] <= sbox_read_data;
                    
                    if(col<3) begin
                        col<=col+1;
                    end
                    else begin
                        col<=0;
                        row<=row+1;
                    end
                        if(row>3 & col=3) state <=FINISH;
                end

                if(flag_data_sent & addr_ack)
                begin
                    flag_address_sent <=0;
                    data_ack <= 0;
                end
                if(i>15) state=FINISH;
            end
            FINISH: begin 
                cipher[] <= state_matrix[][];
                cipher[] <= state_matrix[][];
                cipher[] <= state_matrix[][];
                cipher[] <= state_matrix[][];
                cipher[] <= state_matrix[][];
                cipher[] <= state_matrix[][];
                cipher[] <= state_matrix[][];
                cipher[] <= state_matrix[][];
                cipher[] <= state_matrix[][];
                cipher[] <= state_matrix[][];
                cipher[] <= state_matrix[][];
                cipher[] <= state_matrix[][];
                cipher[] <= state_matrix[][];
                cipher[] <= state_matrix[][];
                cipher[] <= state_matrix[][];
            endcase

    end

endmodule