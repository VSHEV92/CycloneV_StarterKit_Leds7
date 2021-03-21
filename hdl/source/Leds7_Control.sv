// модуля управления семисегментными индикаторами
module Leds7_Control (
	input logic clk,    
	input logic resetn, 
	input logic [7:0] uart_data,
	input logic uart_data_valid,
	Leds_intf.device leds
);

enum {LED_NUMB, LED0_DATA, LED1_DATA, LED2_DATA, LED3_DATA} fsm_state;
logic [3:0] leds_bin_data[4];

// конечный автомат
always_ff @(posedge clk)
	if(~resetn)
		fsm_state <= LED_NUMB;
	else if(uart_data_valid) 
		unique case (fsm_state)
			// выбор светодиода
			LED_NUMB:
				unique case(uart_data)
					8'hF0: fsm_state <= LED0_DATA;
					8'hF1: fsm_state <= LED1_DATA;
					8'hF2: fsm_state <= LED2_DATA;
					8'hF3: fsm_state <= LED3_DATA;
				endcase
			// данные для светодиода
			LED0_DATA, LED1_DATA, LED2_DATA, LED3_DATA: 
				fsm_state <= LED_NUMB;
		endcase

// массив значений светодидов
always_ff @(posedge clk)
	if(~resetn)
		for (int i = 0; i < 4; i++)
			leds_bin_data[i] <= 0;
	else if(uart_data_valid) 
		case(fsm_state)
			LED0_DATA: leds_bin_data[0] <= uart_data[3:0];
			LED1_DATA: leds_bin_data[1] <= uart_data[3:0];
			LED2_DATA: leds_bin_data[2] <= uart_data[3:0];
			LED3_DATA: leds_bin_data[3] <= uart_data[3:0];
		endcase

// формирование valid сигналов
always_ff @(posedge clk)
	if(~resetn)
		for (int i = 0; i < 4; i++)
			leds.led_data_valid[i] <= 0;
	else begin
		for (int i = 0; i < 4; i++)
			leds.led_data_valid[i] <= 0;
	 	if(uart_data_valid) 
			case(fsm_state)
				LED0_DATA: leds.led_data_valid[0] <= 1;
				LED1_DATA: leds.led_data_valid[1] <= 1;
				LED2_DATA: leds.led_data_valid[2] <= 1;
				LED3_DATA: leds.led_data_valid[3] <= 1;
			endcase
	end

// преобразование в код семисегментного индикатора
always_comb
	for (int i = 0; i < 4; i++) 
		leds.leds_data[i] = ~(Leds_7_pkg::bin_to_led7(leds_bin_data[i]));



// ------------------------------------------------------------------------------------------------------
property led_value_in_LED_NUMB_state;
	@(posedge clk) disable iff (~resetn)
		(fsm_state == LED_NUMB) & uart_data_valid |-> (uart_data == 8'hF0) | (uart_data == 8'hF1) | (uart_data == 8'hF2) | (uart_data == 8'hF3);
endproperty;
assert property (led_value_in_LED_NUMB_state);
cover property (led_value_in_LED_NUMB_state);

property led_value_in_other_state;
	@(posedge clk) disable iff (~resetn)
		(fsm_state != LED_NUMB) & uart_data_valid |-> uart_data inside {[0:9]};
endproperty;
assert property (led_value_in_other_state);
cover property (led_value_in_other_state);

property LED_NUMB_state_to_Next_State;
	@(posedge clk) disable iff (~resetn)
		(fsm_state == LED_NUMB) & uart_data_valid |=> (fsm_state == LED0_DATA) | (fsm_state == LED1_DATA) | (fsm_state == LED2_DATA) | (fsm_state == LED3_DATA);
endproperty;
assert property (LED_NUMB_state_to_Next_State);
cover property (LED_NUMB_state_to_Next_State);

property other_state_to_Next_State;
	@(posedge clk) disable iff (~resetn)
		(fsm_state != LED_NUMB) & uart_data_valid |=> (fsm_state == LED_NUMB);
endproperty;
assert property (other_state_to_Next_State);
cover property (other_state_to_Next_State);

property led_number_to_valid_out_0;
	@(posedge clk) disable iff (~resetn)
		(uart_data == 8'hF0) & uart_data_valid |=> ##2 (leds.led_data_valid[0] == 0 & leds.led_data_valid[1] == 0 & leds.led_data_valid[2] == 0 & leds.led_data_valid[3] == 0) [*2:$]
												   ##1 (leds.led_data_valid[0] == 1 & leds.led_data_valid[1] == 0 & leds.led_data_valid[2] == 0 & leds.led_data_valid[3] == 0)
												   ##1 (leds.led_data_valid[0] == 0 & leds.led_data_valid[1] == 0 & leds.led_data_valid[2] == 0 & leds.led_data_valid[3] == 0);
endproperty;
assert property (led_number_to_valid_out_0);
cover property (led_number_to_valid_out_0);

property led_number_to_valid_out_1;
	@(posedge clk) disable iff (~resetn)
		(uart_data == 8'hF1) & uart_data_valid |=> ##2 (leds.led_data_valid[0] == 0 & leds.led_data_valid[1] == 0 & leds.led_data_valid[2] == 0 & leds.led_data_valid[3] == 0) [*2:$]
												   ##1 (leds.led_data_valid[0] == 0 & leds.led_data_valid[1] == 1 & leds.led_data_valid[2] == 0 & leds.led_data_valid[3] == 0)
												   ##1 (leds.led_data_valid[0] == 0 & leds.led_data_valid[1] == 0 & leds.led_data_valid[2] == 0 & leds.led_data_valid[3] == 0);
endproperty;
assert property (led_number_to_valid_out_1);
cover property (led_number_to_valid_out_1);

property led_number_to_valid_out_2;
	@(posedge clk) disable iff (~resetn)
		(uart_data == 8'hF2) & uart_data_valid |=> ##2 (leds.led_data_valid[0] == 0 & leds.led_data_valid[1] == 0 & leds.led_data_valid[2] == 0 & leds.led_data_valid[3] == 0) [*2:$]
												   ##1 (leds.led_data_valid[0] == 0 & leds.led_data_valid[1] == 0 & leds.led_data_valid[2] == 1 & leds.led_data_valid[3] == 0)
												   ##1 (leds.led_data_valid[0] == 0 & leds.led_data_valid[1] == 0 & leds.led_data_valid[2] == 0 & leds.led_data_valid[3] == 0);
endproperty;
assert property (led_number_to_valid_out_2);
cover property (led_number_to_valid_out_2);

property led_number_to_valid_out_3;
	@(posedge clk) disable iff (~resetn)
		(uart_data == 8'hF3) & uart_data_valid |=> ##2 (leds.led_data_valid[0] == 0 & leds.led_data_valid[1] == 0 & leds.led_data_valid[2] == 0 & leds.led_data_valid[3] == 0) [*2:$]
												   ##1 (leds.led_data_valid[0] == 0 & leds.led_data_valid[1] == 0 & leds.led_data_valid[2] == 0 & leds.led_data_valid[3] == 1)
												   ##1 (leds.led_data_valid[0] == 0 & leds.led_data_valid[1] == 0 & leds.led_data_valid[2] == 0 & leds.led_data_valid[3] == 0);
endproperty;
assert property (led_number_to_valid_out_3);
cover property (led_number_to_valid_out_3);

endmodule