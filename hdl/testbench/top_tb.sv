`timescale 1ns/1ps

module top_tb();

	parameter CLK_FREQ = 50;         // тактовая частота в МГц
	parameter RESET_DEASSIGN = 300;  // неативаный уровень стброса в нс 
	parameter SIM_TIMEOUT = 100;       // завершение симуляции по тайм-ауту
	parameter BIT_RATE = 115200;     // скорость данных в бит/с
	parameter TRANS_NUMB = 10;        // количество транзакций
	parameter MAX_DELAY = 30;       // максимальная задержка в периодах бита данных 

	logic clk = 0;
	logic resetn = 0;

	// uart интерфейс
	UART_intf
	#(
		.BIT_RATE(BIT_RATE)
	) uart_rx (
		.aresetn(resetn)
	);
	
	// программа для тестов
	test
	#(
		.TRANS_NUMB(TRANS_NUMB),
		.MAX_DELAY(MAX_DELAY)
	)
	test_program(.*);

	// сигнал сброса
	initial
		#RESET_DEASSIGN resetn = 1;

	// тактовый сигнал 
	initial
		forever #(1e3 / CLK_FREQ) clk = ~ clk;

	// завершение по тайм-ауту
	initial begin
		#(SIM_TIMEOUT * 1e6);
		$display("ERROR! Simulation Timeout");
		$stop;	
	end

endmodule : top_tb