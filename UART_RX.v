
module UART_RX #(
parameter clk_per_bit = 87)(
input clk,
input rst_n,
input serial_in,
output [15:0] serial_out,
output rx_done
);

parameter IDLE = 3'b000;
parameter RX_START = 3'b001;
parameter RX_DATA_BITS = 3'b010;
parameter RX_STOP_BIT = 3'b011;
parameter CLEANUP = 3'b100;

reg [15:0] rx_byte_reg;
reg [7:0] clk_count;
reg [2:0] bit_idx; //8 bits total
reg [2:0] rx_state;
reg rx_data;
reg rx_done_reg;
reg rx_data_reg;

always @ (posedge clk)
begin
    rx_data_reg <= serial_in;
    rx_data <= rx_data_reg;
end


always @ (posedge clk or negedge rst_n)
begin
    if (~rst_n) begin
        rx_state <= IDLE;
        rx_data <= 1'b1;
        clk_count <= 8'd0;
        bit_idx <= 3'd7;
        rx_byte_reg <= 15'd0;
        rx_done_reg <= 1'b0;  
    end else begin
        case (rx_state)
        IDLE : begin
            if (rx_data == 0) begin
                rx_state <= RX_START;
            end
        end
        RX_START : begin
            if (clk_count == ((clk_per_bit - 1)/2)) begin
                if (rx_data == 0) begin
                    clk_count <= 8'd0;
                    rx_state <= RX_DATA_BITS;
                end else begin
                    rx_state <= IDLE;
                end
            end else begin
                clk_count <= clk_count + 8'd1;
            end
        end
        RX_DATA_BITS : begin
            if (clk_count < (clk_per_bit - 1)) begin
                clk_count <= clk_count + 8'd1;
            end else begin
                clk_count <= 8'd0;
                if (bit_idx >= 0) begin
                    bit_idx <= bit_idx - 3'd1;
                    rx_byte_reg[bit_idx] <= rx_data;
                end else begin
                    bit_idx <= 3'd7;
                    rx_state <= RX_STOP_BIT;
                end
            end
        end
        RX_STOP_BIT : begin
            if (clk_count < (clk_per_bit - 1)) begin
                clk_count <= clk_count + 1;
            end else begin
                clk_count <= 8'd0;
                rx_done_reg <= 1'b1;
                rx_state <= CLEANUP;
            end
        end
        CLEANUP : begin
            rx_state <= IDLE;
            rx_done_reg <= 1'b0;
        end
        default : begin
            rx_state <= IDLE;
        end
        endcase
    end
end

assign rx_done = rx_done_reg;
assign serial_out = rx_byte_reg;

endmodule