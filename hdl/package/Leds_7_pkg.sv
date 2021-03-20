package Leds_7_pkg;

	// перечисление индикаторов
	typedef enum { LED0, LED1, LED2, LED3 } leds7_t; 
	
	// проеобразование двоичного кода в код семисегментного индикатора
	function logic[6:0] bin_to_led7(logic[3:0] bin_data);
		logic[6:0] leds_data;
		unique case (bin_data)
			//                abcdefg
			0: leds_data = 7'b1111110;
			1: leds_data = 7'b0110000;
			2: leds_data = 7'b1101101;
			3: leds_data = 7'b1111001;
			4: leds_data = 7'b0110011;
			5: leds_data = 7'b1011011;
			6: leds_data = 7'b0011111;
			7: leds_data = 7'b1110000;
			8: leds_data = 7'b1111111;
			9: leds_data = 7'b1110011;
		endcase 
		return leds_data;
	endfunction

	// проеобразование кода семисегментного индикатора в двоичный код
	function logic[3:0] led7_to_bin(logic[6:0] leds_data);
		logic[6:0] bin_data;
		unique case (leds_data)
		//     abcdefg
			7'b1111110: bin_data = 0;
			7'b0110000: bin_data = 1;
			7'b1101101: bin_data = 2;
			7'b1111001: bin_data = 3;
			7'b0110011: bin_data = 4;
			7'b1011011: bin_data = 5;
			7'b0011111: bin_data = 6;
			7'b1110000: bin_data = 7;
			7'b1111111: bin_data = 8;
			7'b1110011: bin_data = 9;
		endcase 
		return bin_data;
	endfunction
 
endpackage : Leds_7_pkg

