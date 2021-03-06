program test
#(
	parameter TRANS_NUMB,
	parameter MAX_DELAY
)	
(
	input logic clk,
	input logic resetn,
	UART_intf.test uart_rx,
	Leds_intf.test leds
);

Enviroment_pkg::Enviroment env;

initial begin
	env = new(MAX_DELAY);
	env.Uart_RX = uart_rx;
	env.Leds_Interface = leds;
	env.run(TRANS_NUMB);
	wait(0);
end

endprogram