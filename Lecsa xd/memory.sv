module memory(
    input [7:0] addr,
    input clk,
    input rst,
    input rdy,


    input flag_address_sent;
    output flag_data_sent;

    input data_ack;
    output addr_ack;
  
    output reg [7:0] data_out
    );

reg state[1:0] = 0;
parameter WRITE = 2'b00;
parameter READ = 2'b01;

always @(posedge clk) begin
    case(state)
    WRITE: begin
        
    end

    READ: begin
        
    end

end

wire [7:0] sbox [15:0][15:0];

            assign sbox[0][0]=2'h63;
            assign sbox[0][1]=2'h7c;
            assign sbox[0][2]=2'h77;
            assign sbox[0][3]=2'h7b;
            assign sbox[0][4]=2'hf2;
            assign sbox[0][5]=2'h6b;
            assign sbox[0][6]=2'h6f;
            assign sbox[0][7]=2'hc5;
            assign sbox[0][8]=2'h30;
            assign sbox[0][9]=2'h01;
            assign sbox[0][10]=2'h67;
            assign sbox[0][11]=2'h2b;
            assign sbox[0][12]=2'hfe;
            assign sbox[0][13]=2'hd7;
            assign sbox[0][14]=2'hab;
            assign sbox[0][15]=2'h76;
            assign sbox[1][0]=2'hca;
            assign sbox[1][1]=2'h82;
            assign sbox[1][2]=2'hc9;
            assign sbox[1][3]=2'h7d;
            assign sbox[1][4]=2'hfa;
            assign sbox[1][5]=2'h59;
            assign sbox[1][6]=2'h47;
            assign sbox[1][7]=2'hf0;
            assign sbox[1][8]=2'had;
            assign sbox[1][9]=2'hd4;
            assign sbox[1][10]=2'ha2;
            assign sbox[1][11]=2'haf;
            assign sbox[1][12]=2'h9c;
            assign sbox[1][13]=2'ha4;
            assign sbox[1][14]=2'h72;
            assign sbox[1][15]=2'hc0;
            assign sbox[2][0]=2'hb7;
            assign sbox[2][1]=2'hfd;
            assign sbox[2][2]=2'h93;
            assign sbox[2][3]=2'h26;
            assign sbox[2][4]=2'h36;
            assign sbox[2][5]=2'h3f;
            assign sbox[2][6]=2'hf7;
            assign sbox[2][7]=2'hcc;
            assign sbox[2][8]=2'h34;
            assign sbox[2][9]=2'ha5;
            assign sbox[2][10]=2'he5;
            assign sbox[2][11]=2'hf1;
            assign sbox[2][12]=2'h71;
            assign sbox[2][13]=2'hd8;
            assign sbox[2][14]=2'h31;
            assign sbox[2][15]=2'h15;
            assign sbox[3][0]=2'h04;
            assign sbox[3][1]=2'hc7;
            assign sbox[3][2]=2'h23;
            assign sbox[3][3]=2'hc3;
            assign sbox[3][4]=2'h18;
            assign sbox[3][5]=2'h96;
            assign sbox[3][6]=2'h05;
            assign sbox[3][7]=2'h9a;
            assign sbox[3][8]=2'h07;
            assign sbox[3][9]=2'h12;
            assign sbox[3][10]=2'h80;
            assign sbox[3][11]=2'he2;
            assign sbox[3][12]=2'heb;
            assign sbox[3][13]=2'h27;
            assign sbox[3][14]=2'hb2;
            assign sbox[3][15]=2'h75;
            assign sbox[4][0]=2'h09;
            assign sbox[4][1]=2'h83;
            assign sbox[4][2]=2'h2c;
            assign sbox[4][3]=2'h1a;
            assign sbox[4][4]=2'h1b;
            assign sbox[4][5]=2'h6e;
            assign sbox[4][6]=2'h5a;
            assign sbox[4][7]=2'ha0;
            assign sbox[4][8]=2'h52;
            assign sbox[4][9]=2'h3b;
            assign sbox[4][10]=2'hd6;
            assign sbox[4][11]=2'hb3;
            assign sbox[4][12]=2'h29;
            assign sbox[4][13]=2'he3;
            assign sbox[4][14]=2'h2f;
            assign sbox[4][15]=2'h84;
            assign sbox[5][0]=2'h53;
            assign sbox[5][1]=2'hd1;
            assign sbox[5][2]=2'h00;
            assign sbox[5][3]=2'hed;
            assign sbox[5][4]=2'h20;
            assign sbox[5][5]=2'hfc;
            assign sbox[5][6]=2'hb1;
            assign sbox[5][7]=2'h5b;
            assign sbox[5][8]=2'h6a;
            assign sbox[5][9]=2'hcb;
            assign sbox[5][10]=2'hbe;
            assign sbox[5][11]=2'h39;
            assign sbox[5][12]=2'h4a;
            assign sbox[5][13]=2'h4c;
            assign sbox[5][14]=2'h58;
            assign sbox[5][15]=2'hcf;
            assign sbox[6][0]=2'hd0;
            assign sbox[6][1]=2'hef;
            assign sbox[6][2]=2'haa;
            assign sbox[6][3]=2'hfb;
            assign sbox[6][4]=2'h43;
            assign sbox[6][5]=2'h4d;
            assign sbox[6][6]=2'h33;
            assign sbox[6][7]=2'h85;
            assign sbox[6][8]=2'h45;
            assign sbox[6][9]=2'hf9;
            assign sbox[6][10]=2'h02;
            assign sbox[6][11]=2'h7f;
            assign sbox[6][12]=2'h50;
            assign sbox[6][13]=2'h3c;
            assign sbox[6][14]=2'h9f;
            assign sbox[6][15]=2'ha8;
            assign sbox[7][0]=2'h51;
            assign sbox[7][1]=2'ha3;
            assign sbox[7][2]=2'h40;
            assign sbox[7][3]=2'h8f;
            assign sbox[7][4]=2'h92;
            assign sbox[7][5]=2'h9d;
            assign sbox[7][6]=2'h38;
            assign sbox[7][7]=2'hf5;
            assign sbox[7][8]=2'hbc;
            assign sbox[7][9]=2'hb6;
            assign sbox[7][10]=2'hda;
            assign sbox[7][11]=2'h21;
            assign sbox[7][12]=2'h10;
            assign sbox[7][13]=2'hff;
            assign sbox[7][14]=2'hf3;
            assign sbox[7][15]=2'hd2;
            assign sbox[8][0]=2'hcd;
            assign sbox[8][1]=2'h0c;
            assign sbox[8][2]=2'h13;
            assign sbox[8][3]=2'hec;
            assign sbox[8][4]=2'h5f;
            assign sbox[8][5]=2'h97;
            assign sbox[8][6]=2'h44;
            assign sbox[8][7]=2'h17;
            assign sbox[8][8]=2'hc4;
            assign sbox[8][9]=2'ha7;
            assign sbox[8][10]=2'h7e;
            assign sbox[8][11]=2'h3d;
            assign sbox[8][12]=2'h64;
            assign sbox[8][13]=2'h5d;
            assign sbox[8][14]=2'h19;
            assign sbox[8][15]=2'h73;
            assign sbox[9][0]=2'h60;
            assign sbox[9][1]=2'h81;
            assign sbox[9][2]=2'h4f;
            assign sbox[9][3]=2'hdc;
            assign sbox[9][4]=2'h22;
            assign sbox[9][5]=2'h2a;
            assign sbox[9][6]=2'h90;
            assign sbox[9][7]=2'h88;
            assign sbox[9][8]=2'h46;
            assign sbox[9][9]=2'hee;
            assign sbox[9][10]=2'hb8;
            assign sbox[9][11]=2'h14;
            assign sbox[9][12]=2'hde;
            assign sbox[9][13]=2'h5e;
            assign sbox[9][14]=2'h0b;
            assign sbox[9][15]=2'hdb;
            assign sbox[10][0]=2'he0;
            assign sbox[10][1]=2'h32;
            assign sbox[10][2]=2'h3a;
            assign sbox[10][3]=2'h0a;
            assign sbox[10][4]=2'h49;
            assign sbox[10][5]=2'h06;
            assign sbox[10][6]=2'h24;
            assign sbox[10][7]=2'h5c;
            assign sbox[10][8]=2'hc2;
            assign sbox[10][9]=2'hd3;
            assign sbox[10][10]=2'hac;
            assign sbox[10][11]=2'h62;
            assign sbox[10][12]=2'h91;
            assign sbox[10][13]=2'h95;
            assign sbox[10][14]=2'he4;
            assign sbox[10][15]=2'h79;
            assign sbox[11][0]=2'he7;
            assign sbox[11][1]=2'hc8;
            assign sbox[11][2]=2'h37;
            assign sbox[11][3]=2'h6d;
            assign sbox[11][4]=2'h8d;
            assign sbox[11][5]=2'hd5;
            assign sbox[11][6]=2'h4e;
            assign sbox[11][7]=2'ha9;
            assign sbox[11][8]=2'h6c;
            assign sbox[11][9]=2'h56;
            assign sbox[11][10]=2'hf4;
            assign sbox[11][11]=2'hea;
            assign sbox[11][12]=2'h65;
            assign sbox[11][13]=2'h7a;
            assign sbox[11][14]=2'hae;
            assign sbox[11][15]=2'h08;
            assign sbox[12][0]=2'hba;
            assign sbox[12][1]=2'h78;
            assign sbox[12][2]=2'h25;
            assign sbox[12][3]=2'h2e;
            assign sbox[12][4]=2'h1c;
            assign sbox[12][5]=2'ha6;
            assign sbox[12][6]=2'hb4;
            assign sbox[12][7]=2'hc6;
            assign sbox[12][8]=2'he8;
            assign sbox[12][9]=2'hdd;
            assign sbox[12][10]=2'h74;
            assign sbox[12][11]=2'h1f;
            assign sbox[12][12]=2'h4b;
            assign sbox[12][13]=2'hbd;
            assign sbox[12][14]=2'h8b;
            assign sbox[12][15]=2'h8a;
            assign sbox[13][0]=2'h70;
            assign sbox[13][1]=2'h3e;
            assign sbox[13][2]=2'hb5;
            assign sbox[13][3]=2'h66;
            assign sbox[13][4]=2'h48;
            assign sbox[13][5]=2'h03;
            assign sbox[13][6]=2'hf6;
            assign sbox[13][7]=2'h0e;
            assign sbox[13][8]=2'h61;
            assign sbox[13][9]=2'h35;
            assign sbox[13][10]=2'h57;
            assign sbox[13][11]=2'hb9;
            assign sbox[13][12]=2'h86;
            assign sbox[13][13]=2'hc1;
            assign sbox[13][14]=2'h1d;
            assign sbox[13][15]=2'h9e;
            assign sbox[14][0]=2'he1;
            assign sbox[14][1]=2'hf8;
            assign sbox[14][2]=2'h98;
            assign sbox[14][3]=2'h11;
            assign sbox[14][4]=2'h69;
            assign sbox[14][5]=2'hd9;
            assign sbox[14][6]=2'h8e;
            assign sbox[14][7]=2'h94;
            assign sbox[14][8]=2'h9b;
            assign sbox[14][9]=2'h1e;
            assign sbox[14][10]=2'h87;
            assign sbox[14][11]=2'he9;
            assign sbox[14][12]=2'hce;
            assign sbox[14][13]=2'h55;
            assign sbox[14][14]=2'h28;
            assign sbox[14][15]=2'hdf;
            assign sbox[15][0]=2'h8c;
            assign sbox[15][1]=2'ha1;
            assign sbox[15][2]=2'h89;
            assign sbox[15][3]=2'h0d;
            assign sbox[15][4]=2'hbf;
            assign sbox[15][5]=2'he6;
            assign sbox[15][6]=2'h42;
            assign sbox[15][7]=2'h68;
            assign sbox[15][8]=2'h41;
            assign sbox[15][9]=2'h99;
            assign sbox[15][10]=2'h2d;
            assign sbox[15][11]=2'h0f;
            assign sbox[15][12]=2'hb0;
            assign sbox[15][13]=2'h54;
            assign sbox[15][14]=2'hbb;
            assign sbox[15][15]=2'h16;

always @(posedge clk)
begin

    if(flag_address_sent & !flag_data_sent)
    begin
        data_out <= sbox[addr[7:4]][addr[3:0]];
        flag_data_sent <= 1;
    end

    if(flag_data_sent & data_ack)
    begin
        flag_data_sent <=0;
        addr_ack <=0;
    end

end 
