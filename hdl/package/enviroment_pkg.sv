package Enviroment_pkg;

// ------------------------
// ------ транзакция ------
// ------------------------
class Transactions;

	int unsigned max_delay; 
	rand Leds_7_pkg::leds7_t leds7;
	rand bit [3:0] value;
	rand int unsigned delay;
	rand int unsigned delay_id;

	covergroup transaction_cg();
	   	leds7: coverpoint leds7;
	   	value: coverpoint value;
	   	all: cross leds7, value; 
	endgroup : transaction_cg

	// ограничение максимальной задержки
	constraint max_delay_const {delay < max_delay; delay > 2;}
	constraint max_delay_id_const {delay_id < max_delay; delay_id > 2;}
	constraint max_value_const {value < 10;}

	function new(int unsigned max_delay = 30);
		transaction_cg = new();
		this.max_delay = max_delay;
	endfunction

	function Leds_7_pkg::leds7_t get_led7();
		return leds7;
	endfunction

	function void set_led7(Leds_7_pkg::leds7_t leds7);
		this.leds7 = leds7;
	endfunction

	function bit [3:0] get_value();
		return value;
	endfunction

	function void set_value(bit [3:0] value);
		this.value = value;
	endfunction

	function int unsigned get_delay();
		return delay;
	endfunction

	function int unsigned get_delay_id();
		return delay_id;
	endfunction

	function void print(string class_name);
		$display("%s done transaction: LED = %s, Value = %d, time = %0t", class_name, leds7.name(), value, $time);
	endfunction

	function bit [7:0] get_led7_id();
		bit [7:0] id;
		unique case(leds7)
			Leds_7_pkg::LED0: id = 8'hF0;
			Leds_7_pkg::LED1: id = 8'hF1;
			Leds_7_pkg::LED2: id = 8'hF2;
			Leds_7_pkg::LED3: id = 8'hF3;
		endcase
		return id;
	endfunction

endclass : Transactions 

// ------------------------
// ------ генератор -------
// ------------------------
class Generator;
	Enviroment_pkg::Transactions trans;	
	mailbox sc_board_mb;
	mailbox driver_mb;

	function new(ref mailbox sc_board_mb, ref mailbox driver_mb, int unsigned max_delay);
		trans = new(max_delay);
		this.sc_board_mb = sc_board_mb;
		this.driver_mb = driver_mb;
	endfunction

	task generate_transaction();
		Enviroment_pkg::Transactions temp_trans;
		trans.randomize();
		trans.transaction_cg.sample();
		temp_trans = new trans;
		sc_board_mb.put(temp_trans);
		driver_mb.put(temp_trans);
	endtask

	task run(input int runs_number);
		repeat(runs_number)
			generate_transaction();
	endtask

endclass : Generator 

// ------------------------
// ------- драйвер --------
// ------------------------
class Driver;
	Enviroment_pkg::Transactions trans;
	mailbox driver_mb;
	virtual UART_intf Uart_RX;
	
	function new(ref mailbox driver_mb);
		trans = new();
		this.driver_mb = driver_mb;
	endfunction

    task drive_transaction();
    	driver_mb.get(trans);
    	Uart_RX.put_to_uart(trans.get_led7_id(), trans.get_delay_id());
    	Uart_RX.put_to_uart(trans.get_value(), trans.get_delay());
    endtask

    task run();
    	forever drive_transaction();
    endtask

endclass : Driver

// ------------------------
// ------- монитор --------
// ------------------------
class Monitor;
	Enviroment_pkg::Transactions trans;
	mailbox sc_board_mb;
	virtual Leds_intf Leds_Interface;

	function new(ref mailbox sc_board_mb);
		this.sc_board_mb = sc_board_mb;
	endfunction

    task get_transaction();
    	int led_numb;
    	logic [3:0] bin_data;
    	trans = new();
    	
    	@(posedge Leds_Interface.led_data_valid[0], posedge Leds_Interface.led_data_valid[1], posedge Leds_Interface.led_data_valid[2], posedge Leds_Interface.led_data_valid[3]);
    	for (int i = 0; i < 4; i++)
    		if (Leds_Interface.led_data_valid[i])
    			led_numb = i;

    	bin_data = Leds_7_pkg::led7_to_bin(~Leds_Interface.leds_data[led_numb]);
    	
    	trans.set_value(bin_data);
    	unique case (led_numb)
	    	0: trans.set_led7(Leds_7_pkg::LED0);
	    	1: trans.set_led7(Leds_7_pkg::LED1);
	    	2: trans.set_led7(Leds_7_pkg::LED2);
	    	3: trans.set_led7(Leds_7_pkg::LED3);
    	endcase
    	sc_board_mb.put(trans);
    endtask

    task run();
    	forever get_transaction();
    endtask

endclass : Monitor

// --------------------------------
// ------- результат теста --------
// --------------------------------
class Scoreboard;
	bit Test_Result = 1;
	Enviroment_pkg::Transactions trans_d;
	Enviroment_pkg::Transactions trans_m;

	mailbox sc_board_d_mb;
	mailbox sc_board_m_mb;

	function new(ref mailbox sc_board_m_mb, ref mailbox sc_board_d_mb);
		trans_m = new();
		trans_d = new();
		this.sc_board_m_mb = sc_board_m_mb;
		this.sc_board_d_mb = sc_board_d_mb;
	endfunction

	task run(input int runs_number);
		for (int i = 0; i < runs_number; i++) begin
			sc_board_m_mb.get(trans_m);
			sc_board_d_mb.get(trans_d);

			if (trans_m.get_led7() != trans_d.get_led7()) begin 
				$display("Error! LED not match! Transaction number = %d", i);
				Test_Result = 0;
			end

			if (trans_m.get_value() != trans_d.get_value()) begin 
				$display("Error! VALUE not match! Transaction number = %d", i);
				Test_Result = 0;
			end
		end

		if (Test_Result) begin 
			$display("---------------------------");
			$display("-------  TEST PASS  -------");
			$display("---------------------------");
		end
		else begin 
			$display("---------------------------");
			$display("-------  TEST FAIL  -------");
			$display("---------------------------");
		end
		$stop;
	endtask

endclass : Scoreboard
// ------------------------
// ----- окружение --------
// ------------------------
class Enviroment;
	Enviroment_pkg::Generator gen;
	Enviroment_pkg::Driver driver;
	Enviroment_pkg::Monitor mon;
	Enviroment_pkg::Scoreboard score;

	virtual UART_intf Uart_RX;
	virtual Leds_intf Leds_Interface;	

	mailbox driver_mb;
	mailbox sc_board_d_mb;
	mailbox sc_board_m_mb;

	function new(int unsigned max_delay);
		driver_mb = new();
		sc_board_d_mb = new();
		sc_board_m_mb = new();
		gen = new(sc_board_d_mb, driver_mb, max_delay);
		driver = new(driver_mb);
		mon = new(sc_board_m_mb);
		score = new(sc_board_m_mb, sc_board_d_mb);
	endfunction

	task run(input int runs_number);
		driver.Uart_RX = Uart_RX;
		mon.Leds_Interface = Leds_Interface;
		fork
			gen.run(runs_number);
			driver.run();
			mon.run();
			score.run(runs_number);
		join
	endtask

endclass : Enviroment

endpackage : Enviroment_pkg