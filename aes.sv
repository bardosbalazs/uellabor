module AES256
(
    input clk,                  //órajel
    input en,                   //engedélyező jel
    input rst,                  //reset
    input [127:0] key,          //kulcs
    input [127:0] word,         //bemeneti "szó"
    output reg [127:0] cipher   //titkosított "szó"
    );

    reg [7:0] state_matrix[0:3][0:3]; //Állapot-mátrix

    always @ (posedge clk)  //szavak bitjeinek betöltése az állapot-mátrixba
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

    always @ (posedge clk)
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

    always@(posedge clk)
    begin
        integer row;
        integer col;
        begin
            for (row=0;row<4;row++)
            begin
                for(col=0;col<4;col++)
                begin
                    state_matrix[row][col] = sbox //?????
                end
            end
        end
    end







endmodule