module top_aes(
    input top_clk,
    input top_rst,
    input rdy,

    input [7:0] addr,
    input [127:0] key,          //kulcs
    input [127:0] word,         //bemeneti "szó"
    output reg [127:0] cipher   //titkosított "szó"
);

reg [7:0] top_data_out;
reg top_flag_data_sent;
reg top_flag_address_sent;

aes aes_uut(
        .clk(top_clk),
        .rst(top_rst),
        .key(key),
        .word(word),
        .cipher(cipher),
        .sbox_read(top_data_out),
        .flag_data_sent(top_flag_data_sent),
        .flag_address_sent(top_flag_address_sent)
    );

memory memory_uut(
        .addr(addr),
        .clk(top_clk),
        .rst(top_rst),
        .rdy(rdy),
        .data_out(top_data_out)
        .flag_data_sent(top_flag_data_sent),
        .flag_address_sent(top_flag_address_sent)
    );



always @(posedge clk)
begin

end