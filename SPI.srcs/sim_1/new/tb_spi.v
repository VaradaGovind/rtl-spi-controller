`timescale 1ns / 1ps

module tb_spi;
    reg clk;
    reg rst;
    reg start;
    reg [7:0] master_data_in;
    wire [7:0] master_data_out;
    wire master_busy;
    
    reg [7:0] slave_data_in;
    wire [7:0] slave_data_out;
    wire slave_valid;
    
    wire sclk;
    wire cs;
    wire mosi;
    wire miso;

    spi_master u_master (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(master_data_in),
        .miso(miso),
        .sclk(sclk),
        .cs(cs),
        .mosi(mosi),
        .data_out(master_data_out),
        .busy(master_busy)
        );

    spi_slave u_slave (
            .sclk(sclk),
            .cs(cs),
            .mosi(mosi),
            .data_in(slave_data_in),
            .rst(rst),
            .miso(miso),
            .data_out(slave_data_out),
            .data_valid(slave_valid)
            );
    
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        start = 0;
        master_data_in = 8'hA5;
        slave_data_in = 8'h5A;
        
        #20 rst = 1;
        
        #20 start = 1;
        #10 start = 0;
        
        wait(master_busy == 0);
        
        #50;
        $display("Transaction Complete");
        $display("Master Sent: %h, Slave Received: %h", master_data_in, slave_data_out);
        $display("Slave Sent: %h, Master Received: %h", slave_data_in, master_data_out);
        
        $stop;
    end

endmodule
