`timescale 1ns / 1ps

module spi_slave (
    input wire sclk,
    input wire cs,
    input wire mosi,
    input wire [7:0] data_in,
    input wire rst,
    
    output reg miso,
    output reg [7:0] data_out,
    output reg data_valid
);

    reg [7:0] shift_reg;
    reg [2:0] bit_cnt;
    reg [7:0] tx_buf;

    always @(posedge cs or negedge rst) begin
        if (!rst) begin
            bit_cnt <= 0;
            data_valid <= 0;
            miso <= 1'bz;
            tx_buf <= 0;
        end 
        else begin
            bit_cnt <= 0;
            data_valid <= 0;
        end
    end
    
    always @(negedge cs) begin
        tx_buf <= data_in;
        miso <= data_in[7];
    end

    always @(posedge sclk or negedge rst) begin
        if (!rst) begin
            data_out <= 8'h00;
            shift_reg <= 0;
        end 
        else if (!cs) begin
            shift_reg <= {shift_reg[6:0], mosi};
            if (bit_cnt == 7) begin
                data_out <= {shift_reg[6:0], mosi};
                data_valid <= 1;
            end 
            else begin
                bit_cnt <= bit_cnt + 1;
            end
        end
    end

    always @(negedge sclk) begin
        if (!cs) begin
            if (bit_cnt < 8) begin
                miso <= tx_buf[7 - bit_cnt]; 
            end
        end
    end

endmodule