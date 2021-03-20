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

	function bit [3:0] get_value();
		return value;
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
	mailbox sc_board_mb;
	logic [6:0] leds_data[4];
	logic led_data_valid[4];
	
	function new(ref mailbox sc_board_mb, ref logic [6:0] leds_data[4], ref logic led_data_valid[4]);
		this.sc_board_mb = sc_board_mb;
		this.leds_data = leds_data;
		this.led_data_valid = led_data_valid;
	endfunction

    task get_transaction();
    	@(posedge led_data_valid.or());
    	for (int i = 0; i < 4; i++)
    		if (led_data_valid[i])
    			sc_board_mb.put(leds_data[i]);
    endtask

    task run();
    	forever get_transaction();
    endtask

endclass : Monitor


// ------------------------
// ----- окружение --------
// ------------------------
class Enviroment;
	Enviroment_pkg::Generator gen;
	Enviroment_pkg::Driver driver;

	virtual UART_intf Uart_RX;	
	mailbox driver_mb;
	mailbox sc_board_d_mb;
	mailbox sc_board_m_mb;

	function new(int unsigned max_delay, ref logic [6:0] leds_data[4], ref logic led_data_valid[4]);
		driver_mb = new();
		sc_board_d_mb = new();
		sc_board_m_mb = new();
		gen = new(sc_board_d_mb, driver_mb, max_delay);
		driver = new(driver_mb);
	endfunction

	task run(input int runs_number);
		driver.Uart_RX = Uart_RX;

		fork
			gen.run(runs_number);
			driver.run();
		join
	endtask

endclass : Enviroment

endpackage : Enviroment_pkg