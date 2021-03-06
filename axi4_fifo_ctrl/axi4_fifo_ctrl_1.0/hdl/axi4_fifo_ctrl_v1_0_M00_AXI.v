
`timescale 1 ns / 1 ps

	module axi4_fifo_ctrl_v1_0_M00_AXI #
	(
		// Users to add parameters here
		parameter  C_M_AXI_TARGET_SLAVE_RANGE_ADDR	= 32'h40000000,
		parameter  ALLOW_READ = "TRUE",
		// User parameters ends
		// Do not modify the parameters beyond this line

		// Base address of targeted slave
		parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
		// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
		parameter integer C_M_AXI_BURST_LEN	= 16,
		// Thread ID Width
		parameter integer C_M_AXI_ID_WIDTH	= 1,
		// Width of Address Bus
		parameter integer C_M_AXI_ADDR_WIDTH	= 32,
		// Width of Data Bus
		parameter integer C_M_AXI_DATA_WIDTH	= 32,
		// Width of User Write Address Bus
		parameter integer C_M_AXI_AWUSER_WIDTH	= 0,
		// Width of User Read Address Bus
		parameter integer C_M_AXI_ARUSER_WIDTH	= 0,
		// Width of User Write Data Bus
		parameter integer C_M_AXI_WUSER_WIDTH	= 0,
		// Width of User Read Data Bus
		parameter integer C_M_AXI_RUSER_WIDTH	= 0,
		// Width of User Response Bus
		parameter integer C_M_AXI_BUSER_WIDTH	= 0
	)
	(
		// Users to add ports here
		// fifo read ports
		output wire fifo_rden,
		input wire [C_M_AXI_DATA_WIDTH-1 : 0] fifo_rddata,
		input wire fifo_empty,
		input wire fifo_prog_empty,
		// fifo write ports
		output wire fifo_wren,
		output wire [C_M_AXI_DATA_WIDTH-1 : 0] fifo_wrdata,
		input wire fifo_full,
		input wire fifo_prog_full,
		// User ports ends
		// Do not modify the ports beyond this line

		// Initiate AXI transactions
		input wire  INIT_AXI_TXN,
		// Asserts when ERROR is detected
		output wire  ERROR,
		// Global Clock Signal.
		input wire  M_AXI_ACLK,
		// Global Reset Singal. This Signal is Active Low
		input wire  M_AXI_ARESETN,
		// Master Interface Write Address ID
		output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID,
		// Master Interface Write Address
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		output wire [7 : 0] M_AXI_AWLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		output wire [2 : 0] M_AXI_AWSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		output wire [1 : 0] M_AXI_AWBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		output wire  M_AXI_AWLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		output wire [3 : 0] M_AXI_AWCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_AWPROT,
		// Quality of Service, QoS identifier sent for each write transaction.
		output wire [3 : 0] M_AXI_AWQOS,
		// Optional User-defined signal in the write address channel.
		output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid write address and control information.
		output wire  M_AXI_AWVALID,
		// Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
		input wire  M_AXI_AWREADY,
		// Master Interface Write Data.
		output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
		// Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
		output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
		// Write last. This signal indicates the last transfer in a write burst.
		output wire  M_AXI_WLAST,
		// Optional User-defined signal in the write data channel.
		output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER,
		// Write valid. This signal indicates that valid write
    // data and strobes are available
		output wire  M_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    // can accept the write data.
		input wire  M_AXI_WREADY,
		// Master Interface Write Response.
		input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID,
		// Write response. This signal indicates the status of the write transaction.
		input wire [1 : 0] M_AXI_BRESP,
		// Optional User-defined signal in the write response channel
		input wire [C_M_AXI_BUSER_WIDTH-1 : 0] M_AXI_BUSER,
		// Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
		input wire  M_AXI_BVALID,
		// Response ready. This signal indicates that the master
    // can accept a write response.
		output wire  M_AXI_BREADY,
		// Master Interface Read Address.
		output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID,
		// Read address. This signal indicates the initial
    // address of a read burst transaction.
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		output wire [7 : 0] M_AXI_ARLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		output wire [2 : 0] M_AXI_ARSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		output wire [1 : 0] M_AXI_ARBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		output wire  M_AXI_ARLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		output wire [3 : 0] M_AXI_ARCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_ARPROT,
		// Quality of Service, QoS identifier sent for each read transaction
		output wire [3 : 0] M_AXI_ARQOS,
		// Optional User-defined signal in the read address channel.
		output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid read address and control information
		output wire  M_AXI_ARVALID,
		// Read address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
		input wire  M_AXI_ARREADY,
		// Read ID tag. This signal is the identification tag
    // for the read data group of signals generated by the slave.
		input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_RID,
		// Master Read Data
		input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
		// Read response. This signal indicates the status of the read transfer
		input wire [1 : 0] M_AXI_RRESP,
		// Read last. This signal indicates the last transfer in a read burst
		input wire  M_AXI_RLAST,
		// Optional User-defined signal in the read address channel.
		input wire [C_M_AXI_RUSER_WIDTH-1 : 0] M_AXI_RUSER,
		// Read valid. This signal indicates that the channel
    // is signaling the required read data.
		input wire  M_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    // accept the read data and response information.
		output wire  M_AXI_RREADY
	);


	// function called clogb2 that returns an integer which has the
	//value of the ceiling of the log base 2

	  // function called clogb2 that returns an integer which has the 
	  // value of the ceiling of the log base 2.                      
	  function integer clogb2 (input integer bit_depth);              
	  begin                                                           
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
	      bit_depth = bit_depth >> 1;                                 
	    end                                                           
	  endfunction                                                     

	// C_TRANSACTIONS_NUM is the width of the index counter for 
	// number of write or read transaction.
	 localparam integer C_TRANSACTIONS_NUM = clogb2(C_M_AXI_BURST_LEN-1);

	// Example State machine to initialize counter, initialize write transactions, 
	// initialize read transactions and comparison of read data with the 
	// written data words.

	localparam [1:0] WR_IDLE = 2'b00;
	localparam [1:0] WR_DATA = 2'b01;
	localparam [1:0] WR_DONE = 2'b10;

	localparam [1:0] RD_IDLE = 2'b00;
	localparam [1:0] RD_DATA = 2'b01;
	localparam [1:0] RD_DONE = 2'b10;

	localparam [1:0] FIFO_IDLE = 2'b00;
	localparam [1:0] FIFO_CACHE = 2'b01;
	localparam [1:0] FIFO_RDDONE = 2'b10;
	localparam [1:0] FIFO_RDWAIT = 2'b11;

	localparam LAST_ADDR = C_M_AXI_TARGET_SLAVE_RANGE_ADDR - (C_M_AXI_BURST_LEN*C_M_AXI_DATA_WIDTH/8);
	localparam MAX_PTR = (C_M_AXI_TARGET_SLAVE_RANGE_ADDR / (C_M_AXI_BURST_LEN*C_M_AXI_DATA_WIDTH/8))-1;
	localparam PTR_WIDTH = clogb2(MAX_PTR-1) + 1;

	// AXI4LITE signals
	//AXI4 internal temp signals
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awvalid;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
	reg  	axi_wlast;
	reg  	axi_wvalid;
	reg  	axi_bready;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arvalid;
	reg  	axi_rready;
	//write beat count in a burst
	reg [C_TRANSACTIONS_NUM : 0] 	write_index;
	//read beat count in a burst
	reg [C_TRANSACTIONS_NUM : 0] 	read_index;
	//size of C_M_AXI_BURST_LEN length burst in bytes
	wire [C_TRANSACTIONS_NUM+8 : 0] 	burst_size_bytes;
	reg  	start_single_burst_write;
	reg  	start_single_burst_read;
	reg  	error_reg;
	reg  	burst_write_active;
	reg  	burst_read_active;
	//Interface response error flags
	wire  	write_resp_error;
	wire  	read_resp_error;
	wire  	wnext;
	wire  	rnext;
	reg  	init_txn_ff;
	reg  	init_txn_ff2;
	wire  	init_txn_pulse;

	integer i;
	reg [C_M_AXI_DATA_WIDTH-1:0] rd_cache_a[C_M_AXI_BURST_LEN-1:0];		//ping-pong cache ram
	reg [C_M_AXI_DATA_WIDTH-1:0] rd_cache_b[C_M_AXI_BURST_LEN-1:0];
	reg cache_a_ready = 1'b0;
	reg cache_b_ready = 1'b0;
	reg cache_a_invalid = 1'b0;
	reg cache_b_invalid = 1'b0;
	reg cache_sel = 1'b0;
	reg cache_sel_wr = 1'b0;

	reg [C_TRANSACTIONS_NUM:0] write_cache_addr;

	wire cache_a_hit;
	wire cache_b_hit;

	reg [7:0] fifo_rdcnt = 8'd0;
	reg [1:0] mst_wr_state;
	reg [1:0] mst_rd_state;
	reg [1:0] fifo_rd_state;

	reg [PTR_WIDTH-1:0] fifo_ptr = 'd0;
	wire axi4_wr_hit;
	wire axi4_rd_hit;
	wire memory_full;
	wire memory_empty;
	wire axi4_rd_done;

	reg fifo_wren_r;
	reg [C_M_AXI_DATA_WIDTH-1:0] fifo_wrdata_r;

	(* max_fanout=2500 *)reg rst = 1'b1;

	initial begin
		for(i=0; i<C_M_AXI_BURST_LEN; i=i+1) begin
			rd_cache_a[i] = {C_M_AXI_DATA_WIDTH{1'b0}};
			rd_cache_b[i] = {C_M_AXI_DATA_WIDTH{1'b0}};
		end
	end

	// I/O Connections assignments

	//I/O Connections. Write Address (AW)
	assign M_AXI_AWID	= 'b0;
	//The AXI address is a concatenation of the target base address + active offset range
	assign M_AXI_AWADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_awaddr;
	//Burst LENgth is number of transaction beats, minus 1
	assign M_AXI_AWLEN	= C_M_AXI_BURST_LEN - 1;
	//Size should be C_M_AXI_DATA_WIDTH, in 2^SIZE bytes, otherwise narrow bursts are used
	assign M_AXI_AWSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	//INCR burst type is usually used, except for keyhole bursts
	assign M_AXI_AWBURST	= 2'b01;
	assign M_AXI_AWLOCK	= 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign M_AXI_AWCACHE	= 4'b0010;
	assign M_AXI_AWPROT	= 3'h0;
	assign M_AXI_AWQOS	= 4'h0;
	assign M_AXI_AWUSER	= 'b1;
	assign M_AXI_AWVALID	= axi_awvalid;
	//Write Data(W)
	assign M_AXI_WDATA	= axi_wdata;
	//All bursts are complete and aligned in this example
	assign M_AXI_WSTRB	= {(C_M_AXI_DATA_WIDTH/8){1'b1}};
	assign M_AXI_WLAST	= axi_wlast;
	assign M_AXI_WUSER	= 'b0;
	assign M_AXI_WVALID	= axi_wvalid;
	//Write Response (B)
	assign M_AXI_BREADY	= axi_bready;
	//Read Address (AR)
	assign M_AXI_ARID	= 'b0;
	assign M_AXI_ARADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_araddr;
	//Burst LENgth is number of transaction beats, minus 1
	assign M_AXI_ARLEN	= C_M_AXI_BURST_LEN - 1;
	//Size should be C_M_AXI_DATA_WIDTH, in 2^n bytes, otherwise narrow bursts are used
	assign M_AXI_ARSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	//INCR burst type is usually used, except for keyhole bursts
	assign M_AXI_ARBURST	= 2'b01;
	assign M_AXI_ARLOCK	= 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign M_AXI_ARCACHE	= 4'b0010;
	assign M_AXI_ARPROT	= 3'h0;
	assign M_AXI_ARQOS	= 4'h0;
	assign M_AXI_ARUSER	= 'b1;
	assign M_AXI_ARVALID	= axi_arvalid;
	//Read and Read Response (R)
	assign M_AXI_RREADY	= axi_rready;
	//Burst size in bytes
	assign burst_size_bytes	= C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;
	assign init_txn_pulse	= (!init_txn_ff2) && init_txn_ff;

	assign cache_a_hit = cache_a_ready&&(cache_sel_wr==1);
	assign cache_b_hit = cache_b_ready&&(cache_sel_wr==0);

	assign axi4_wr_hit = ({M_AXI_BVALID, axi_bready}==2'b11);
	assign axi4_rd_hit = ({(read_index == C_M_AXI_BURST_LEN-2), M_AXI_RVALID, axi_rready}==3'b111);

	assign memory_full = (fifo_ptr>=MAX_PTR);
	assign memory_empty = (fifo_ptr==0);

	assign axi4_rd_done = ({(read_index == C_M_AXI_BURST_LEN-1), M_AXI_RVALID, axi_rready}==3'b111);


	//Generate a pulse to initiate AXI transaction.
	always @(posedge M_AXI_ACLK)										      
	  begin                                                                        
	    // Initiates AXI transaction delay    
	    if (M_AXI_ARESETN == 0 )                                                   
	      begin                                                                    
	        init_txn_ff <= 1'b0;                                                   
	        init_txn_ff2 <= 1'b0;                                                   
	      end                                                                               
	    else                                                                       
	      begin  
	        init_txn_ff <= INIT_AXI_TXN;
	        init_txn_ff2 <= init_txn_ff;                                                                 
	      end                                                                      
	  end     

	always @ (posedge M_AXI_ACLK) begin
		rst <= (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 );
	end

	//--------------------
	//Write Address Channel
	//--------------------

	// The purpose of the write address channel is to request the address and 
	// command information for the entire transaction.  It is a single beat
	// of information.

	// The AXI4 Write address channel in this example will continue to initiate
	// write commands as fast as it is allowed by the slave/interconnect.
	// The address will be incremented on each accepted address transaction,
	// by burst_size_byte to point to the next address. 

	  always @(posedge M_AXI_ACLK)                                   
	  begin                                                                
	                                                                       
	    if (rst)                                           
	      begin                                                            
	        axi_awvalid <= 1'b0;                                           
	      end                                                              
	    // If previously not valid , start next transaction                
	    else if (~axi_awvalid && start_single_burst_write)                 
	      begin                                                            
	        axi_awvalid <= 1'b1;                                           
	      end                                                              
	    /* Once asserted, VALIDs cannot be deasserted, so axi_awvalid      
	    must wait until transaction is accepted */                         
	    else if (M_AXI_AWREADY && axi_awvalid)                             
	      begin                                                            
	        axi_awvalid <= 1'b0;                                           
	      end                                                              
	    else                                                               
	      axi_awvalid <= axi_awvalid;                                      
	    end                                                                
	                                                                       
	                                                                       
	// Next address after AWREADY indicates previous address acceptance    
	  always @(posedge M_AXI_ACLK)                                         
	  begin                                                                
	    if (rst)                                            
	      begin                                                            
	        axi_awaddr <= 'b0;                                             
	      end                                                              
	    else if (M_AXI_AWREADY && axi_awvalid)                             
	      begin       
	      	if(axi_awaddr>=LAST_ADDR)
	      		axi_awaddr <= 0;
	      	else
	        	axi_awaddr <= axi_awaddr + burst_size_bytes;                   
	      end                                                              
	    else                                                               
	      axi_awaddr <= axi_awaddr;                                        
	    end                                                                


	//--------------------
	//Write Data Channel
	//--------------------

	//The write data will continually try to push write data across the interface.

	//The amount of data accepted will depend on the AXI slave and the AXI
	//Interconnect settings, such as if there are FIFOs enabled in interconnect.

	//Note that there is no explicit timing relationship to the write address channel.
	//The write channel has its own throttling flag, separate from the AW channel.

	//Synchronization between the channels must be determined by the user.

	//The simpliest but lowest performance would be to only issue one address write
	//and write data burst at a time.

	//In this example they are kept in sync by using the same address increment
	//and burst sizes. Then the AW and W channels have their transactions measured
	//with threshold counters as part of the user logic, to make sure neither 
	//channel gets too far ahead of each other.

	//Forward movement occurs when the write channel is valid and ready

	  assign wnext = M_AXI_WREADY & axi_wvalid;                                   
	                                                                                    
	// WVALID logic, similar to the axi_awvalid always block above                      
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (rst)                                                        
	      begin                                                                         
	        axi_wvalid <= 1'b0;                                                         
	      end                                                                           
	    // If previously not valid, start next transaction                              
	    else if (~axi_wvalid && start_single_burst_write)                               
	      begin                                                                         
	        axi_wvalid <= 1'b1;                                                         
	      end                                                                           
	    /* If WREADY and too many writes, throttle WVALID                               
	    Once asserted, VALIDs cannot be deasserted, so WVALID                           
	    must wait until burst is complete with WLAST */                                 
	    else if (wnext && axi_wlast)                                                    
	      axi_wvalid <= 1'b0;                                                           
	    else                                                                            
	      axi_wvalid <= axi_wvalid;                                                     
	  end                                                                               
	                                                                                    
	                                                                                    
	//WLAST generation on the MSB of a counter underflow                                
	// WVALID logic, similar to the axi_awvalid always block above                      
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (rst)                                                        
	      begin                                                                         
	        axi_wlast <= 1'b0;                                                          
	      end                                                                           
	    // axi_wlast is asserted when the write index                                   
	    // count reaches the penultimate count to synchronize                           
	    // with the last write data when write_index is b1111                           
	    // else if (&(write_index[C_TRANSACTIONS_NUM-1:1])&& ~write_index[0] && wnext)  
	    else if (((write_index == C_M_AXI_BURST_LEN-2 && C_M_AXI_BURST_LEN >= 2) && wnext) || (C_M_AXI_BURST_LEN == 1 ))
	      begin                                                                         
	        axi_wlast <= 1'b1;                                                          
	      end                                                                           
	    // Deassrt axi_wlast when the last write data has been                          
	    // accepted by the slave with a valid response                                  
	    else if (wnext)                                                                 
	      axi_wlast <= 1'b0;                                                            
	    else if (axi_wlast && C_M_AXI_BURST_LEN == 1)                                   
	      axi_wlast <= 1'b0;                                                            
	    else                                                                            
	      axi_wlast <= axi_wlast;                                                       
	  end                                                                               
	                                                                                    
	                                                                                    
	/* Burst length counter. Uses extra counter register bit to indicate terminal       
	 count to reduce decode logic */                                                    
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (rst || start_single_burst_write == 1'b1)    
	      begin                                                                         
	        write_index <= 0;                                                           
	      end                                                                           
	    else if (wnext && (write_index != C_M_AXI_BURST_LEN-1))                         
	      begin                                                                         
	        write_index <= write_index + 1;                                             
	      end                                                                           
	    else                                                                            
	      write_index <= write_index;                                                   
	  end  

	                                                                                    
	/* Write Data Generator                                                             
	 Data pattern is only a simple incrementing count from 0 for each burst  */         
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (rst) begin                                                       
	      axi_wdata <= 'b0;
	      write_cache_addr <= 0;
	    end                         
		else if (wnext||(start_single_burst_write==1'b1)) begin
			if(write_index != C_M_AXI_BURST_LEN-2)
				if(write_cache_addr == C_M_AXI_BURST_LEN-1)
					write_cache_addr <= 0;
				else
					write_cache_addr <= write_cache_addr + 1'b1;
			else
				write_cache_addr <= write_cache_addr;
			if(cache_sel_wr==0)
				axi_wdata <= rd_cache_a[write_cache_addr];
			else
				axi_wdata <= rd_cache_b[write_cache_addr];
		end
	   	else begin
	   		axi_wdata <= axi_wdata;
	   	end
	end                                                                             


	//----------------------------
	//Write Response (B) Channel
	//----------------------------

	//The write response channel provides feedback that the write has committed
	//to memory. BREADY will occur when all of the data and the write address
	//has arrived and been accepted by the slave.

	//The write issuance (number of outstanding write addresses) is started by 
	//the Address Write transfer, and is completed by a BREADY/BRESP.

	//While negating BREADY will eventually throttle the AWREADY signal, 
	//it is best not to throttle the whole data channel this way.

	//The BRESP bit [1] is used indicate any errors from the interconnect or
	//slave for the entire write burst. This example will capture the error 
	//into the ERROR output. 

	  always @(posedge M_AXI_ACLK)                                     
	  begin                                                                 
	    if (rst)                                            
	      begin                                                             
	        axi_bready <= 1'b0;                                             
	      end                                                               
	    // accept/acknowledge bresp with axi_bready by the master           
	    // when M_AXI_BVALID is asserted by slave                           
	    else if (M_AXI_BVALID && ~axi_bready)                               
	      begin                                                             
	        axi_bready <= 1'b1;                                             
	      end                                                               
	    // deassert after one clock cycle                                   
	    else if (axi_bready)                                                
	      begin                                                             
	        axi_bready <= 1'b0;                                             
	      end                                                               
	    // retain the previous value                                        
	    else                                                                
	      axi_bready <= axi_bready;                                         
	  end                                                                   
	                                                                        
	                                                                        
	//Flag any write response errors                                        
	  assign write_resp_error = axi_bready & M_AXI_BVALID & M_AXI_BRESP[1]; 


	//----------------------------
	//Read Address Channel
	//----------------------------

	//The Read Address Channel (AW) provides a similar function to the
	//Write Address channel- to provide the tranfer qualifiers for the burst.

	//In this example, the read address increments in the same
	//manner as the write address channel.

	  always @(posedge M_AXI_ACLK)                                 
	  begin                                                              
	                                                                     
	    if (rst)                                         
	      begin                                                          
	        axi_arvalid <= 1'b0;                                         
	      end                                                            
	    // If previously not valid , start next transaction              
	    else if (~axi_arvalid && start_single_burst_read)                
	      begin                                                          
	        axi_arvalid <= 1'b1;                                         
	      end                                                            
	    else if (M_AXI_ARREADY && axi_arvalid)                           
	      begin                                                          
	        axi_arvalid <= 1'b0;                                         
	      end                                                            
	    else                                                             
	      axi_arvalid <= axi_arvalid;                                    
	  end                                                                
	                                                                     
	                                                                     
	// Next address after ARREADY indicates previous address acceptance  
	  always @(posedge M_AXI_ACLK)                                       
	  begin                                                              
	    if (rst)                                          
	      begin                                                          
	        axi_araddr <= 'b0;                                           
	      end                                                            
	    else if (M_AXI_ARREADY && axi_arvalid)                           
	      begin                                                          
	        if(axi_araddr>=LAST_ADDR)
	      		axi_araddr <= 0;
	      	else
	        	axi_araddr <= axi_araddr + burst_size_bytes;                     
	      end                                                            
	    else                                                             
	      axi_araddr <= axi_araddr;                                      
	  end                                                                


	//--------------------------------
	//Read Data (and Response) Channel
	//--------------------------------

	 // Forward movement occurs when the channel is valid and ready   
	  assign rnext = M_AXI_RVALID && axi_rready;                            
	                                                                        
	                                                                        
	// Burst length counter. Uses extra counter register bit to indicate    
	// terminal count to reduce decode logic                                
	  always @(posedge M_AXI_ACLK)                                          
	  begin                                                                 
	    if (rst || start_single_burst_read)                  
	      begin                                                             
	        read_index <= 0;                                                
	      end                                                               
	    else if (rnext && (read_index != C_M_AXI_BURST_LEN-1))              
	      begin                                                             
	        read_index <= read_index + 1;                                   
	      end                                                               
	    else                                                                
	      read_index <= read_index;                                         
	  end                                                                   
	                                                                        
	                                                                        
	/*                                                                      
	 The Read Data channel returns the results of the read request          
	                                                                        
	 In this example the data checker is always able to accept              
	 more data, so no need to throttle the RREADY signal                    
	 */                                                                     
	  always @(posedge M_AXI_ACLK)                                          
	  begin                                                                 
	    if (rst)                  
	      begin                                                             
	        axi_rready <= 1'b0;                                             
	      end                                                               
	    // accept/acknowledge rdata/rresp with axi_rready by the master     
	    // when M_AXI_RVALID is asserted by slave                           
	    else if (M_AXI_RVALID)                       
	      begin                                      
	         if (M_AXI_RLAST && axi_rready)          
	          begin                                  
	            axi_rready <= 1'b0;                  
	          end                                    
	         else                                    
	           begin                                 
	             axi_rready <= 1'b1;                 
	           end                                   
	      end                                        
	    // retain the previous value                 
	  end                                            
                                                                        
	//Flag any read response errors                                         
	  assign read_resp_error = axi_rready & M_AXI_RVALID & M_AXI_RRESP[1];  

	//----------------------------------
	//Example design error register
	//----------------------------------

	//Register and hold any data mismatches, or read/write interface errors 

	  always @(posedge M_AXI_ACLK)                                 
	  begin                                                              
	    if (rst)                                          
	      begin                                                          
	        error_reg <= 1'b0;                                           
	      end                                                            
	    else if (write_resp_error || read_resp_error)   
	      begin                                                          
	        error_reg <= 1'b1;                                           
	      end                                                            
	    else                                                             
	      error_reg <= error_reg;                                        
	  end                                                                


	//--------------------------------
	//Example design throttling
	//--------------------------------

	// For maximum port throughput, this user example code will try to allow
	// each channel to run as independently and as quickly as possible.

	// However, there are times when the flow of data needs to be throtted by
	// the user application. This example application requires that data is
	// not read before it is written and that the write channels do not
	// advance beyond an arbitrary threshold (say to prevent an 
	// overrun of the current read address by the write address).

	// From AXI4 Specification, 13.13.1: "If a master requires ordering between 
	// read and write transactions, it must ensure that a response is received 
	// for the previous transaction before issuing the next transaction."

	// This example accomplishes this user application throttling through:
	// -Reads wait for writes to fully complete
	// -Address writes wait when not read + issued transaction counts pass 
	// a parameterized threshold
	// -Writes wait when a not read + active data burst count pass 
	// a parameterized threshold

	                                                                                                            
	  // burst_write_active signal is asserted when there is a burst write transaction                          
	  // is initiated by the assertion of start_single_burst_write. burst_write_active                          
	  // signal remains asserted until the burst write is accepted by the slave                                 
	  always @(posedge M_AXI_ACLK)                                                                              
	  begin                                                                                                     
	    if (rst)                                                                                 
	      burst_write_active <= 1'b0;                                                                           
	                                                                                                            
	    //The burst_write_active is asserted when a write burst transaction is initiated                        
	    else if (start_single_burst_write)                                                                      
	      burst_write_active <= 1'b1;                                                                           
	    else if (M_AXI_BVALID && axi_bready)                                                                    
	      burst_write_active <= 0;                                                                              
	  end                                                                                                       
	                                                                                                            
	 // Check for last write completion.                                                                        
	                                                                                                            
	  // burst_read_active signal is asserted when there is a burst write transaction                           
	  // is initiated by the assertion of start_single_burst_write. start_single_burst_read                     
	  // signal remains asserted until the burst read is accepted by the master                                 
	  always @(posedge M_AXI_ACLK)                                                                              
	  begin                                                                                                     
	    if (rst)                                                                                 
	      burst_read_active <= 1'b0;                                                                            
	                                                                                                            
	    //The burst_write_active is asserted when a write burst transaction is initiated                        
	    else if (start_single_burst_read)                                                                       
	      burst_read_active <= 1'b1;                                                                            
	    else if (M_AXI_RVALID && axi_rready && M_AXI_RLAST)                                                     
	      burst_read_active <= 0;                                                                               
	    end                                                                                                     
	                                                                                                            
	                                                                                                            
	 // Check for last read completion.                                                                         

	// Add user logic here

	// fifo read state machine
	always @ (posedge M_AXI_ACLK)
		if(rst)
			fifo_rd_state <= FIFO_IDLE;
		else 
			case(fifo_rd_state)
				FIFO_IDLE : begin
					if(fifo_prog_empty==0)
						fifo_rd_state <= FIFO_CACHE;
					else
						fifo_rd_state <= FIFO_IDLE;
				end

				FIFO_CACHE : begin
					if(fifo_rdcnt==C_M_AXI_BURST_LEN-1)
						fifo_rd_state <= FIFO_RDDONE;
					else
						fifo_rd_state <= FIFO_CACHE;
				end

				FIFO_RDDONE : begin
					fifo_rd_state <= FIFO_RDWAIT;
				end

				FIFO_RDWAIT : begin
					if({cache_a_ready, cache_b_ready}==2'b11)
						fifo_rd_state <= FIFO_RDWAIT;
					else
						fifo_rd_state <= FIFO_IDLE;
				end
			endcase

	// fifo read control 
	assign fifo_rden = (fifo_rd_state==FIFO_CACHE);

	always @ (posedge M_AXI_ACLK)
		if(rst)
			fifo_rdcnt <= 0;
		else if(fifo_rden)
			if(fifo_rdcnt==C_M_AXI_BURST_LEN-1)
				fifo_rdcnt <= 0;
			else
				fifo_rdcnt <= fifo_rdcnt + 1'b1;
		else
			fifo_rdcnt <= fifo_rdcnt;

	// fifo cache 
	always @ (posedge M_AXI_ACLK)
		if(rst) begin
			for(i=0; i<C_M_AXI_BURST_LEN; i=i+1) begin
				rd_cache_a[i] <= {C_M_AXI_DATA_WIDTH{1'b0}};
				rd_cache_b[i] <= {C_M_AXI_DATA_WIDTH{1'b0}};
			end
		end
		else if(fifo_rden) begin
			if(cache_sel==0)
				rd_cache_a[fifo_rdcnt] <= fifo_rddata;
			else
				rd_cache_b[fifo_rdcnt] <= fifo_rddata;
		end

	// fifo cache ready & sel signal
	always @ (posedge M_AXI_ACLK)
		if(rst) begin
			cache_a_ready <= 1'b0;
			cache_b_ready <= 1'b0;
			cache_sel <= 1'b0;
		end
		else if(fifo_rd_state==FIFO_RDDONE) begin
			if(cache_sel==0) begin
				cache_a_ready <= 1'b1;
				cache_b_ready <= cache_b_invalid?1'b0:cache_b_ready;
			end
			else begin
				cache_a_ready <= cache_a_invalid?1'b0:cache_a_ready;
				cache_b_ready <= 1'b1;
			end
			cache_sel <= ~cache_sel;
		end
		else begin
			cache_sel <= cache_sel;
			if(cache_a_invalid)
				cache_a_ready <= 1'b0;
			else
				cache_a_ready <= cache_a_ready;
			if(cache_b_invalid)
				cache_b_ready <= 1'b0;
			else
				cache_b_ready <= cache_b_ready;
		end

	// cache to axi4 write
	always @ (posedge M_AXI_ACLK)
		if(rst) begin
			start_single_burst_write <= 0;
			mst_wr_state <= WR_IDLE;
		end
		else
			case(mst_wr_state)
				WR_IDLE : begin
					if((cache_a_ready==1'b1||cache_b_ready==1'b1)&&(memory_full==0)) begin
						mst_wr_state <= WR_DATA;
					end
					else begin
						mst_wr_state <= WR_IDLE;
					end
				end

				WR_DATA : begin
					if(({axi4_wr_hit, cache_a_hit, cache_b_hit}==3'b100)||({axi4_wr_hit, memory_full}==2'b11)) begin
						mst_wr_state <= WR_DONE;
					end
					else begin
						mst_wr_state <= WR_DATA;
						if({axi_awvalid, start_single_burst_write, burst_write_active}==3'b000) begin
							start_single_burst_write <= 1'b1;
						end
						else begin
							start_single_burst_write <= 1'b0;
						end
					end
				end
				default : begin
					start_single_burst_write <= 0;
					mst_wr_state <= WR_IDLE;
				end
			endcase

	always @ (posedge M_AXI_ACLK)
		if(rst) begin
			cache_a_invalid <= 0;
			cache_b_invalid <= 0;
			cache_sel_wr <= 0;
		end
		else begin
			if(M_AXI_BVALID && axi_bready) begin
				cache_sel_wr <= ~cache_sel_wr;
				if(cache_sel_wr==0) begin
					cache_a_invalid <= 1;
					cache_b_invalid <= 0;
				end
				else begin
					cache_a_invalid <= 0;
					cache_b_invalid <= 1;
				end
			end
			else begin
				cache_a_invalid <= 0;
				cache_b_invalid <= 0;
			end
		end

	generate
		if(ALLOW_READ == "TRUE") begin
			always @ (posedge M_AXI_ACLK)
				if(rst)
					fifo_ptr <= 0;
				else
					case({axi4_wr_hit, axi4_rd_hit})
						2'b00 : fifo_ptr <= fifo_ptr;
						2'b01 : if(fifo_ptr==0)
									fifo_ptr <= 0;
								else
									fifo_ptr <= fifo_ptr - 1;
						2'b10 : fifo_ptr <= fifo_ptr + 1;
						2'b11 : fifo_ptr <= fifo_ptr;
					endcase
		end
		else begin
			always @ (posedge M_AXI_ACLK)
				if(rst)
					fifo_ptr <= 0;
				else
					fifo_ptr <= 0;
		end
	endgenerate

	always @ (posedge M_AXI_ACLK)
		if(rst) begin
			start_single_burst_read <= 0;
			mst_rd_state <= RD_IDLE;
		end
		else 
			case(mst_rd_state)
				RD_IDLE : begin
					if({memory_empty, fifo_prog_full}==2'b00) begin
						mst_rd_state <= RD_DATA;
					end
					else begin
						mst_rd_state <= RD_IDLE;
					end
				end

				RD_DATA : begin
					if(((memory_empty==1)||(fifo_prog_full==1))&&(axi4_rd_done)) begin
						mst_rd_state <= RD_DONE;
					end
					else begin
						mst_rd_state <= RD_DATA;
						if({axi_arvalid, burst_read_active, start_single_burst_read}==3'b000) begin
							start_single_burst_read <= 1'b1;
						end
						else begin
							start_single_burst_read <= 1'b0;
						end
					end
				end

				default : begin
					start_single_burst_read <= 0;
					mst_rd_state <= RD_IDLE;
				end
			endcase

	always @ (posedge M_AXI_ACLK) begin
		fifo_wren_r <= (M_AXI_RVALID && axi_rready);
		fifo_wrdata_r <= M_AXI_RDATA;
	end

	assign fifo_wren = fifo_wren_r;
	assign fifo_wrdata = fifo_wrdata_r;
	assign ERROR = error_reg;

	// User logic ends

	endmodule
