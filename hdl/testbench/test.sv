program test
#(
	parameter TRANS_NUMB,
	parameter MAX_DELAY
)	
(
	input logic clk,
	input logic resetn,
	UART_intf.test uart_rx,
	input logic [6:0] leds_data[4],
	input logic led_data_valid[4]
);

Enviroment_pkg::Enviroment env;

initial begin
	env = new(MAX_DELAY, leds_data, led_data_valid);
	env.Uart_RX = uart_rx;
	env.run(TRANS_NUMB);
	wait(0);
end

endprogram