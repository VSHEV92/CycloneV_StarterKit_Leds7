// топ уровень проекта
module device_top
#(
    parameter int CLK_FREQ = 50,        // тактовая частота в MHz
    parameter int BIT_RATE = 115200     // скорость данных в бит/с
)
(
	input logic clk,
	input logic resetn,
	UART_intf.device uart_rx,
	Leds_intf.device leds
);

logic [2:0] debounced_resetn;
logic [7:0] uart_data;
logic uart_data_valid;

// защита от метастабильности для resten 
always_ff @(posedge clk)
	debounced_resetn <= {debounced_resetn[1:0], resetn};

// uart rx
UART_RX_to_AXIS 
#(
    .CLK_FREQ(CLK_FREQ),
    .BIT_RATE(BIT_RATE),
    .BIT_PER_WORD(8),
    .PARITY_BIT(0),
    .STOP_BITS_NUM(1)
)
uart_inst
(
    .aclk(clk), 
    .aresetn(debounced_resetn[2]),
    .tdata(uart_data),
	.tvalid(uart_data_valid),
    .RX(uart_rx.RX)    
);

// управление светодиодами
Leds7_Control Leds7_Control_inst(.*, .resetn(debounced_resetn[2]));

endmodule