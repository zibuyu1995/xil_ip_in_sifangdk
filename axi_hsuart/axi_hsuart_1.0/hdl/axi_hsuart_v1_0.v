
`timescale 1 ns / 1 ps

	module axi_hsuart_v1_0 #(
		// Users to add parameters here
		parameter         CLOCK_RATE         = 100_000_000,
		parameter         BAUD_RATE          = 2_500_000  ,
		// User parameters ends
		// Do not modify the parameters beyond this line
		// Parameters of Axi Slave Bus Interface S_AXI
		parameter integer C_S_AXI_DATA_WIDTH = 32         ,
		parameter integer C_S_AXI_ADDR_WIDTH = 32
) (
		// Users to add ports here
		input                                    uart_rx      ,
		output                                   uart_tx      ,
		output                                   interrupt    ,
		// User ports ends
		// Do not modify the ports beyond this line
		// Ports of Axi Slave Bus Interface S_AXI
		input  wire                              s_axi_aclk   ,
		input  wire                              s_axi_aresetn,
		input  wire [    C_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr ,
		input  wire [                       2:0] s_axi_awprot ,
		input  wire                              s_axi_awvalid,
		output wire                              s_axi_awready,
		input  wire [    C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata  ,
		input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0] s_axi_wstrb  ,
		input  wire                              s_axi_wvalid ,
		output wire                              s_axi_wready ,
		output wire [                       1:0] s_axi_bresp  ,
		output wire                              s_axi_bvalid ,
		input  wire                              s_axi_bready ,
		input  wire [    C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr ,
		input  wire [                       2:0] s_axi_arprot ,
		input  wire                              s_axi_arvalid,
		output wire                              s_axi_arready,
		output wire [    C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata  ,
		output wire [                       1:0] s_axi_rresp  ,
		output wire                              s_axi_rvalid ,
		input  wire                              s_axi_rready
	);

	wire [7:0] uart_tx_data;
	wire uart_tx_wen;
	wire uart_tx_fiforst;

	wire char_fifo_empty;
	wire char_fifo_rd_en;
	wire [7:0] char_fifo_dout;

	wire uart_tx_full;
	wire uart_tx_empty;

	wire [7:0] uart_rx_data;
	wire uart_rx_ren;
	wire uart_rx_fiforst;

	wire [7:0] rx_data;
	wire rx_data_rdy;
	wire frm_err;

	wire uart_rx_valid;
	wire uart_rx_empty;
	wire uart_rx_full;

	wire enable_intr;
	wire frm_err;
	wire frm_err_w;

	reg interrupt_r;
	reg tx_empty_r;
	reg rx_empty_r;
	wire tx_intr;
	wire rx_intr;

	reg rx_data_rdy_r;
	wire rx_data_rdy_pulse;
	reg [31:0] interrupt_pulse_r;

// Instantiation of Axi Bus Interface S_AXI
	axi_hsuart_v1_0_S_AXI #(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
	) axi_hsuart_v1_0_S_AXI_inst (
		.S_AXI_ACLK     (s_axi_aclk     ),
		.S_AXI_ARESETN  (s_axi_aresetn  ),
		.S_AXI_AWADDR   (s_axi_awaddr   ),
		.S_AXI_AWPROT   (s_axi_awprot   ),
		.S_AXI_AWVALID  (s_axi_awvalid  ),
		.S_AXI_AWREADY  (s_axi_awready  ),
		.S_AXI_WDATA    (s_axi_wdata    ),
		.S_AXI_WSTRB    (s_axi_wstrb    ),
		.S_AXI_WVALID   (s_axi_wvalid   ),
		.S_AXI_WREADY   (s_axi_wready   ),
		.S_AXI_BRESP    (s_axi_bresp    ),
		.S_AXI_BVALID   (s_axi_bvalid   ),
		.S_AXI_BREADY   (s_axi_bready   ),
		.S_AXI_ARADDR   (s_axi_araddr   ),
		.S_AXI_ARPROT   (s_axi_arprot   ),
		.S_AXI_ARVALID  (s_axi_arvalid  ),
		.S_AXI_ARREADY  (s_axi_arready  ),
		.S_AXI_RDATA    (s_axi_rdata    ),
		.S_AXI_RRESP    (s_axi_rresp    ),
		.S_AXI_RVALID   (s_axi_rvalid   ),
		.S_AXI_RREADY   (s_axi_rready   ),
		.uart_tx_fiforst(uart_tx_fiforst),
		.uart_rx_fiforst(uart_rx_fiforst),
		.enable_intr    (enable_intr    ),
		.uart_rx_data   (uart_rx_data   ),
		.uart_rx_ren    (uart_rx_ren    ),
		.uart_rx_valid  (uart_rx_valid  ),
		.uart_rx_full   (uart_rx_full   ),
		.uart_tx_data   (uart_tx_data   ),
		.uart_tx_wen    (uart_tx_wen    ),
		.uart_tx_full   (uart_tx_full   ),
		.uart_tx_empty  (uart_tx_empty  ),
		.frame_err      (frm_err_w      )
	);

	// Add user logic here
	uart_tx #(
		.BAUD_RATE (BAUD_RATE ),
		.CLOCK_RATE(CLOCK_RATE)
	) uart_tx_i0 (
		.clk_tx         (s_axi_aclk     ),
		.rst_clk_tx     (~s_axi_aresetn ),
		.char_fifo_empty(char_fifo_empty),
		.char_fifo_dout (char_fifo_dout ),
		.char_fifo_rd_en(char_fifo_rd_en),
		.txd_tx         (uart_tx        )
	);

	uart_rx #(
		.BAUD_RATE (BAUD_RATE ),
		.CLOCK_RATE(CLOCK_RATE)
	) uart_rx_i0 (
		.clk_rx     (s_axi_aclk    ),
		.rst_clk_rx (~s_axi_aresetn),
		.rxd_i      (uart_rx       ),
		.rxd_clk_rx (              ),
		.rx_data    (rx_data       ),
		.rx_data_rdy(rx_data_rdy   ),
		.frm_err    (frm_err       )
	);


	FIFO_DUALCLOCK_MACRO #(
		.DEVICE                 ("7SERIES"), // Target Device: "7SERIES"
		.ALMOST_EMPTY_OFFSET    (9'h080   ), // Sets the almost empty threshold
		.ALMOST_FULL_OFFSET     (9'h080   ), // Sets almost full threshold
		.DATA_WIDTH             (8        ), // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
		.FIFO_SIZE              ("18Kb"   ), // Target BRAM: "18Kb" or "36Kb"
		.FIRST_WORD_FALL_THROUGH("TRUE"   )  // Sets the FIFO FWFT to "TRUE" or "FALSE"
	) FIFO_DUALCLOCK_MACRO_uart_tx_i0 (
		.ALMOSTEMPTY(                                   ), // 1-bit output almost empty
		.ALMOSTFULL (                                   ), // 1-bit output almost full
		.DO         (char_fifo_dout                     ), // Output data, width defined by DATA_WIDTH parameter
		.EMPTY      (char_fifo_empty                    ), // 1-bit output empty
		.FULL       (uart_tx_full                       ), // 1-bit output full
		.RDCOUNT    (                                   ), // Output read count, width determined by FIFO depth
		.RDERR      (                                   ), // 1-bit output read error
		.WRCOUNT    (                                   ), // Output write count, width determined by FIFO depth
		.WRERR      (                                   ), // 1-bit output write error
		.RDCLK      (s_axi_aclk                         ), // 1-bit input read clock
		.WRCLK      (s_axi_aclk                         ), // 1-bit input write clock
		.DI         (uart_tx_data                       ), // Input data, width defined by DATA_WIDTH parameter
		.RDEN       (char_fifo_rd_en                    ), // 1-bit input read enable
		.RST        ((~s_axi_aresetn)||(uart_tx_fiforst)), // 1-bit input reset
		.WREN       (uart_tx_wen                        )  // 1-bit input write enable
	);

	FIFO_DUALCLOCK_MACRO #(
		.DEVICE                 ("7SERIES"), // Target Device: "7SERIES"
		.ALMOST_EMPTY_OFFSET    (9'h080   ), // Sets the almost empty threshold
		.ALMOST_FULL_OFFSET     (9'h080   ), // Sets almost full threshold
		.DATA_WIDTH             (9        ), // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
		.FIFO_SIZE              ("18Kb"   ), // Target BRAM: "18Kb" or "36Kb"
		.FIRST_WORD_FALL_THROUGH("TRUE"   )  // Sets the FIFO FWFT to "TRUE" or "FALSE"
	) FIFO_DUALCLOCK_MACRO_uart_rx_i0 (
		.ALMOSTEMPTY(                                   ), // 1-bit output almost empty
		.ALMOSTFULL (                                   ), // 1-bit output almost full
		.DO         ({frm_err_w, uart_rx_data}          ), // Output data, width defined by DATA_WIDTH parameter
		.EMPTY      (uart_rx_empty                      ), // 1-bit output empty
		.FULL       (uart_rx_full                       ), // 1-bit output full
		.RDCOUNT    (                                   ), // Output read count, width determined by FIFO depth
		.RDERR      (                                   ), // 1-bit output read error
		.WRCOUNT    (                                   ), // Output write count, width determined by FIFO depth
		.WRERR      (                                   ), // 1-bit output write error
		.RDCLK      (s_axi_aclk                         ), // 1-bit input read clock
		.WRCLK      (s_axi_aclk                         ), // 1-bit input write clock
		.DI         ({frm_err, rx_data}                 ), // Input data, width defined by DATA_WIDTH parameter
		.RDEN       (uart_rx_ren                        ), // 1-bit input read enable
		.RST        ((~s_axi_aresetn)||(uart_rx_fiforst)), // 1-bit input reset
		.WREN       (rx_data_rdy_pulse                  )  // 1-bit input write enable
	);

	always @ (posedge s_axi_aclk)
		if(!s_axi_aresetn) begin
			tx_empty_r <= 1;
			rx_empty_r <= 1;
			interrupt_r <= 0;
			interrupt_pulse_r <= 0;
		end
		else begin
			tx_empty_r <= char_fifo_empty;
			rx_empty_r <= uart_rx_empty;
			interrupt_pulse_r <= {interrupt_pulse_r[30:0], rx_intr};
			if(enable_intr==1'b1)
				interrupt_r <= |interrupt_pulse_r;
			else
				interrupt_r <= 0;
		end

	assign tx_intr = ({tx_empty_r, char_fifo_empty}==2'b01);
	assign rx_intr = ({rx_empty_r, uart_rx_empty}==2'b10);

	assign uart_tx_empty = char_fifo_empty;
	assign uart_rx_valid = ~uart_rx_empty;
	assign interrupt = interrupt_r;

	always @ (posedge s_axi_aclk)
		if(!s_axi_aresetn)
			rx_data_rdy_r <= 0;
		else
			rx_data_rdy_r <= rx_data_rdy;

	assign rx_data_rdy_pulse = ({rx_data_rdy_r, rx_data_rdy}==2'b01);

	// User logic ends

	endmodule
