`timescale 1ns / 1ps

module spi_master (
    input wire clk, rst, start, miso,
    input wire [7:0] data_in,
    output reg sclk, cs, mosi, busy,
    output reg [7:0] data_out
);

    parameter CLK_DIV = 10;
    reg [4:0] count;
    reg [3:0] bit_cnt;
    
    reg [7:0] tx_shift; 
    reg [7:0] rx_shift; 
    
    reg sclk_en;
    reg [4:0] delay_cnt;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            count <= 0; sclk <= 0;
        end 
        else if (sclk_en) begin
            if (count == CLK_DIV - 1) begin
                sclk <= ~sclk;
                count <= 0;
            end 
            else count <= count + 1;
        end else begin
            sclk <= 0; count <= 0;
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cs <= 1; mosi <= 0; busy <= 0; sclk_en <= 0;
            bit_cnt <= 0; data_out <= 0; 
            tx_shift <= 0; rx_shift <= 0; delay_cnt <= 0;
        end 
        else begin
            case (busy)
                0: begin 
                    cs <= 1; sclk_en <= 0; bit_cnt <= 0;
                    if (start) begin
                        busy <= 1;
                        tx_shift <= data_in;
                        cs <= 0;
                        mosi <= data_in[7];
                        delay_cnt <= 0;
                    end
                end

                1: begin
                    if (sclk_en == 0 && bit_cnt == 0) sclk_en <= 1;

                    if (sclk_en && count == CLK_DIV-1 && sclk == 0) begin
                        rx_shift[0] <= miso; 
                    end

                    if (sclk_en && count == CLK_DIV-1 && sclk == 1) begin
                        if (bit_cnt == 7) begin
                            sclk_en <= 0;
                            data_out <= rx_shift;
                            bit_cnt <= 8;
                        end 
                        else begin
                            tx_shift <= {tx_shift[6:0], 1'b0};
                            mosi <= tx_shift[6];                            
                            rx_shift <= {rx_shift[6:0], 1'b0};
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                    
                    if (bit_cnt == 8) begin
                         if (delay_cnt == CLK_DIV) begin
                             busy <= 0; cs <= 1; bit_cnt <= 0; delay_cnt <= 0;
                         end 
                         else delay_cnt <= delay_cnt + 1;
                    end
                end
            endcase
        end
    end
endmodule
