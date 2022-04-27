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

    reg [255:0] sbox[0:15][0:15];
    wire rdy;

    always@(posedge clk)
    begin

        integer i, j;
        if(rst)
        begin
            for(i=0;i<16;i++)
            begin
                for(j=0; j<16; j++)
                begin
                    sbox[i][j] = 0;
                end
            end
        end

        if (rdy && en) 
        begin
            sbox[0][0]=2'h63;
            sbox[0][1]=2'h7c;
            sbox[0][2]=2'h77;
            sbox[0][3]=2'h7b;
            sbox[0][4]=2'hf2;
            sbox[0][5]=2'h6b;
            sbox[0][6]=2'h6f;
            sbox[0][7]=2'hc5;
            sbox[0][8]=2'h30;
            sbox[0][9]=2'h01;
            sbox[0][10]=2'h67;
            sbox[0][11]=2'h2b;
            sbox[0][12]=2'hfe;
            sbox[0][13]=2'hd7;
            sbox[0][14]=2'hab;
            sbox[0][15]=2'h76;
            sbox[1][0]=2'hca;
            sbox[1][1]=2'h82;
            sbox[1][2]=2'hc9;
            sbox[1][3]=2'h7d;
            sbox[1][4]=2'hfa;
            sbox[1][5]=2'h59;
            sbox[1][6]=2'h47;
            sbox[1][7]=2'hf0;
            sbox[1][8]=2'had;
            sbox[1][9]=2'hd4;
            sbox[1][10]=2'ha2;
            sbox[1][11]=2'haf;
            sbox[1][12] =2'h9c;
            sbox[1][13]=2'ha4;
            sbox[1][14]=2'h72;
            sbox[1][15]=2'hc0;
            sbox[2][0]=2'hb7;
            sbox[2][1]=2'hfd;
            sbox[2][2]=2'h93;
            sbox[2][3]=2'h26;
            sbox[2][4]=2'h36;
            sbox[2][5]=2'h3f;
            sbox[2][6]=2'hf7;
            sbox[2][7]=2'hcc;
            sbox[2][8]=2'h34;
            sbox[2][9]=2'ha5;
            sbox[2][10]=2'he5;
            sbox[2][11]=2'hf1;
            sbox[2][12]=2'h71;
            sbox[2][13]=2'hd8;
            sbox[2][14]=2'h31;
            sbox[2][15]=2'h15;
            sbox[3][0]=2'h04;
            sbox[3][1]=2'hc7;
            sbox[3][2]=2'h23;
            sbox[3][3]=2'hc3;
            sbox[3][4]=2'h18;
            sbox[3][5]=2'h96;
            sbox[3][6]=2'h05;
            sbox[3][7]=2'h9a;
            sbox[3][8]=2'h07;
            sbox[3][9]=2'h12;
            sbox[3][10]=2'h80;
            sbox[3][11]=2'he2;
            sbox[3][12]=2'heb;
            sbox[3][13]=2'h27;
            sbox[3][14]=2'hb2;
            sbox[3][15]=2'h75;
            sbox[4][0]=2'h09;
            sbox[4][1]=2'h83;
            sbox[4][2]=2'h2c;
            sbox[4][3]=2'h1a;
            sbox[4][4]=2'h1b;
            sbox[4][5]=2'h6e;
            sbox[4][6]=2'h5a;
            sbox[4][7]=2'ha0;
            sbox[4][8]=2'h52;
            sbox[4][9]=2'h3b;
            sbox[4][10]=2'hd6;
            sbox[4][11]=2'hb3;
            sbox[4][12]=2'h29;
            sbox[4][13]=2'he3;
            sbox[4][14]=2'h2f;
            sbox[4][15]=2'h84;
            sbox[5][0]=2'h53;
            sbox[5][1]=2'hd1;
            sbox[5][2]=2'h00;
            sbox[5][3]=2'hed;
            sbox[5][4]=2'h20;
            sbox[5][5]=2'hfc;
            sbox[5][6]=2'hb1;
            sbox[5][7]=2'h5b;
            sbox[5][8]=2'h6a;
            sbox[5][9]=2'hcb;
            sbox[5][10]=2'hbe;
            sbox[5][11]=2'h39;
            sbox[5][12]=2'h4a;
            sbox[5][13]=2'h4c;
            sbox[5][14]=2'h58;
            sbox[5][15]=2'hcf;
            sbox[6][0]=2'hd0;
            sbox[6][1]=2'hef;
            sbox[6][2]=2'haa;
            sbox[6][3]=2'hfb;
            sbox[6][4]=2'h43;
            sbox[6][5]=2'h4d;
            sbox[6][6]=2'h33;
            sbox[6][7]=2'h85;
            sbox[6][8]=2'h45;
            sbox[6][9]=2'hf9;
            sbox[6][10]=2'h02;
            sbox[6][11]=2'h7f;
            sbox[6][12]=2'h50;
            sbox[6][13]=2'h3c;
            sbox[6][14]=2'h9f;
            sbox[6][15]=2'ha8;
            sbox[7][0]=2'h51;
            sbox[7][1]=2'ha3;
            sbox[7][2]=2'h40;
            sbox[7][3]=2'h8f;
            sbox[7][4]=2'h92;
            sbox[7][5]=2'h9d;
            sbox[7][6]=2'h38;
            sbox[7][7]=2'hf5;
            sbox[7][8]=2'hbc;
            sbox[7][9]=2'hb6;
            sbox[7][10]=2'hda;
            sbox[7][11]=2'h21;
            sbox[7][12]=2'h10;
            sbox[7][13]=2'hff;
            sbox[7][14]=2'hf3;
            sbox[7][15]=2'hd2;
            sbox[8][0]=2'hcd;
            sbox[8][1]=2'h0c;
            sbox[8][2]=2'h13;
            sbox[8][3]=2'hec;
            sbox[8][4]=2'h5f;
            sbox[8][5]=2'h97;
            sbox[8][6]=2'h44;
            sbox[8][7]=2'h17;
            sbox[8][8]=2'hc4;
            sbox[8][9]=2'ha7;
            sbox[8][10]=2'h7e;
            sbox[8][11]=2'h3d;
            sbox[8][12]=2'h64;
            sbox[8][13]=2'h5d;
            sbox[8][14]=2'h19;
            sbox[8][15]=2'h73;
            sbox[9][0]=2'h60;
            sbox[9][1]=2'h81;
            sbox[9][2]=2'h4f;
            sbox[9][3]=2'hdc;
            sbox[9][4]=2'h22;
            sbox[9][5]=2'h2a;
            sbox[9][6]=2'h90;
            sbox[9][7]=2'h88;
            sbox[9][8]=2'h46;
            sbox[9][9]=2'hee;
            sbox[9][10]=2'hb8;
            sbox[9][11]=2'h14;
            sbox[9][12]=2'hde;
            sbox[9][13]=2'h5e;
            sbox[9][14]=2'h0b;
            sbox[9][15]=2'hdb;
            sbox[10][0]=2'he0;
            sbox[10][1]=2'h32;
            sbox[10][2]=2'h3a;
            sbox[10][3]=2'h0a;
            sbox[10][4]=2'h49;
            sbox[10][5]=2'h06;
            sbox[10][6]=2'h24;
            sbox[10][7]=2'h5c;
            sbox[10][8]=2'hc2;
            sbox[10][9]=2'hd3;
            sbox[10][10]=2'hac;
            sbox[10][11]=2'h62;
            sbox[10][12]=2'h91;
            sbox[10][13]=2'h95;
            sbox[10][14]=2'he4;
            sbox[10][15]=2'h79;
            sbox[11][0]=2'he7;
            sbox[11][1]=2'hc8;
            sbox[11][2]=2'h37;
            sbox[11][3]=2'h6d;
            sbox[11][4]=2'h8d;
            sbox[11][5]=2'hd5;
            sbox[11][6]=2'h4e;
            sbox[11][7]=2'ha9;
            sbox[11][8]=2'h6c;
            sbox[11][9]=2'h56;
            sbox[11][10]=2'hf4;
            sbox[11][11]=2'hea;
            sbox[11][12]=2'h65;
            sbox[11][13]=2'h7a;
            sbox[11][14]=2'hae;
            sbox[11][15]=2'h08;
            sbox[12][0]=2'hba;
            sbox[12][1]=2'h78;
            sbox[12][2]=2'h25;
            sbox[12][3]=2'h2e;
            sbox[12][4]=2'h1c;
            sbox[12][5]=2'ha6;
            sbox[12][6]=2'hb4;
            sbox[12][7]=2'hc6;
            sbox[12][8]=2'he8;
            sbox[12][9]=2'hdd;
            sbox[12][10]=2'h74;
            sbox[12][11]=2'h1f;
            sbox[12][12]=2'h4b;
            sbox[12][13]=2'hbd;
            sbox[12][14]=2'h8b;
            sbox[12][15]=2'h8a;
            sbox[13][0]=2'h70;
            sbox[13][1]=2'h3e;
            sbox[13][2]=2'hb5;
            sbox[13][3]=2'h66;
            sbox[13][4]=2'h48;
            sbox[13][5]=2'h03;
            sbox[13][6]=2'hf6;
            sbox[13][7]=2'h0e;
            sbox[13][8]=2'h61;
            sbox[13][9]=2'h35;
            sbox[13][10]=2'h57;
            sbox[13][11]=2'hb9;
            sbox[13][12]=2'h86;
            sbox[13][13]=2'hc1;
            sbox[13][14]=2'h1d;
            sbox[13][15]=2'h9e;
            sbox[14][0]=2'he1;
            sbox[14][1]=2'hf8;
            sbox[14][2]=2'h98;
            sbox[14][3]=2'h11;
            sbox[14][4]=2'h69;
            sbox[14][5]=2'hd9;
            sbox[14][6]=2'h8e;
            sbox[14][7]=2'h94;
            sbox[14][8]=2'h9b;
            sbox[14][9]=2'h1e;
            sbox[14][10]=2'h87;
            sbox[14][11]=2'he9;
            sbox[14][12]=2'hce;
            sbox[14][13]=2'h55;
            sbox[14][14]=2'h28;
            sbox[14][15]=2'hdf;
            sbox[15][0]=2'h8c;
            sbox[15][1]=2'ha1;
            sbox[15][2]=2'h89;
            sbox[15][3]=2'h0d;
            sbox[15][4]=2'hbf;
            sbox[15][5]=2'he6;
            sbox[15][6]=2'h42;
            sbox[15][7]=2'h68;
            sbox[15][8]=2'h41;
            sbox[15][9]=2'h99;
            sbox[15][10]=2'h2d;
            sbox[15][11]=2'h0f;
            sbox[15][12]=2'hb0;
            sbox[15][13]=2'h54;
            sbox[15][14]=2'hbb;
            sbox[15][15]=2'h16;

            rdy = 0;

        end
    end


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

    reg [3:0] L_bits;
    reg [3:0] H_bits;
    reg [7:0] Temp;

    always@(posedge clk)
    begin
        integer row;
        integer col;
        if(rdy)
        begin
            for (row=0;row<4;row++)
            begin
                for(col=0;col<4;col++)
                begin
                    Temp <= state_matrix[row][col];

                    L_bits <= Temp & 2'h0f;
                    Temp <= {Temp[3:0], Temp[7:4]};
                    H_bits <= Temp & 2'h0f;

                    state_matrix[row][col] <= sbox[H_bits][L_bits]; //?????
                end
            end
        end
    end

endmodule
