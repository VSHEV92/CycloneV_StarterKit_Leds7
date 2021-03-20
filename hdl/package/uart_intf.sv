`timescale 1ns/1ps

// UART-интерфейс
  	interface UART_intf
	    #(
	        parameter int BIT_RATE = 115200    // скорость данных в бит/с
	    )
	    (
	        input logic aresetn 
	    );

	    logic RX = 1;
	    
	    modport device (
	        input  RX
	    );

	    modport test (
	        output RX,
	        import put_to_uart 
	    );
	    
	    // передача данных по uart
	    task put_to_uart(input bit [7:0] data, input int delay);
	    	parameter bit_len_in_ns = (10**9)/BIT_RATE;
    		wait (aresetn);
    		#(bit_len_in_ns*delay);      
            #bit_len_in_ns RX = 1'b0;           // старт-бит
            for (int i = 0; i<8; i++)           // данные
                #bit_len_in_ns RX = data[i];
            #bit_len_in_ns RX = 1'b1;           // стоп-бит;
            #bit_len_in_ns;   
    	endtask

	 endinterface : UART_intf