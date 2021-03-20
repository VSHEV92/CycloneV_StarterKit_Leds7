// UART-интерфейс
interface Leds_intf;

	logic [6:0] leds_data[4];
	logic led_data_valid[4];

	modport device (
	    output  leds_data,
	    output  led_data_valid
	);

	modport test (
	    input  leds_data,
	    input  led_data_valid
	);

endinterface : Leds_intf