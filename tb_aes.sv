`timescale 1ns/1ps

module test_aes;
    reg clk,                  //órajel
    reg en,                   //engedélyező jel
    reg rst,                  //reset
    reg [127:0] key,          //kulcs
    reg [127:0] word,         //bemeneti "szó"
    reg [127:0] cipher      //titkosított "szó"
    );

    aes uut(
        .clk(clk),
        .en(en),
        .rst(rst),
        .key(key),
        .word(word),
        .cipher(cipher)
    );

initial begin
    clk=0;
    rst=0;
    en=0;
    #20
    rst=1;
    #30
    rst=0;
    en=1;
    key=128'b1001001100101100000001011010010; //dec: 1234567890
    word=128'b1001001100101100000001011011101010; //dec: 9876543210

always begin
   #10 clk = ~clk;
	end

endmodule
